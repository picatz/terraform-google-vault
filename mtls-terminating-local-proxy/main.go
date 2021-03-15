package main

import (
	"crypto/tls"
	"crypto/x509"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net"
	"net/url"
	"os"
)

var (
	vaultAddr    string
	vaultCACert  string
	vaultCLICert string
	vaultCLIKey  string
)

func errorAndExit(mesg interface{}) {
	fmt.Println(mesg)
	os.Exit(1)
}

func readFileContent(file string) string {
	f, err := os.Open(file)
	if err != nil {
		errorAndExit(fmt.Errorf("%s %w", file, err))
	}
	defer f.Close()

	bytes, err := ioutil.ReadAll(f)
	if err != nil {
		errorAndExit(fmt.Errorf("%s %w", file, err))
	}
	return string(bytes)
}

func init() {
	var (
		vaultCACertFile  string
		vaultCLICertFile string
		vaultCLIKeyFile  string
	)

	flag.StringVar(&vaultAddr, "addr", os.Getenv("VAULT_ADDR"), "internal Nomad server IP")
	flag.StringVar(&vaultCACertFile, "ca-file", os.Getenv("VAULT_CACERT"), "mTLS certifcate authority file")
	flag.StringVar(&vaultCLICertFile, "cert-file", os.Getenv("VAULT_CLIENT_CERT"), "mTLS client cert file")
	flag.StringVar(&vaultCLIKeyFile, "key-file", os.Getenv("VAULT_CLIENT_KEY"), "mTLS client key file")

	flag.Parse()

	vaultCACert = readFileContent(vaultCACertFile)
	vaultCLICert = readFileContent(vaultCLICertFile)
	vaultCLIKey = readFileContent(vaultCLIKeyFile)

	log.Printf("Vault address %q", vaultAddr)
}

func main() {
	log.Println("Loading the TLS data")
	vaultCert, err := tls.X509KeyPair([]byte(vaultCLICert), []byte(vaultCLIKey))
	if err != nil {
		errorAndExit(err)
	}

	clientCAs := x509.NewCertPool()
	ok := clientCAs.AppendCertsFromPEM([]byte(vaultCACert))
	if !ok {
		errorAndExit(fmt.Errorf("failed to apppend certs from pem"))
	}

	u, err := url.Parse(vaultAddr)
	if err != nil {
		log.Fatal(err)
	}

	tlsClientConfig := &tls.Config{
		Certificates:       []tls.Certificate{vaultCert},
		MinVersion:         tls.VersionTLS12,
		InsecureSkipVerify: true, // required for custom mTLS certificate verification
		VerifyPeerCertificate: func(rawCerts [][]byte, verifiedChains [][]*x509.Certificate) error {
			if len(rawCerts) != 1 {
				return fmt.Errorf("custom verification expected 1 cert duirng peer verification from server, found %d", len(rawCerts))
			}
			peerCert, err := x509.ParseCertificate(rawCerts[0])
			if err != nil {
				return fmt.Errorf("failed to parse peer certificate: %w", err)
			}
			verifyOpts := x509.VerifyOptions{
				Roots:   clientCAs,
				DNSName: "server.global.vault",
			}
			_, err = peerCert.Verify(verifyOpts)
			if err != nil {
				return fmt.Errorf("failed to verify peer certificate: %w", err)
			}
			return nil
		},
	}

	log.Println("Starting local listener on localhost:8200")
	ln, err := net.Listen("tcp", "localhost:8200")
	if err != nil {
		errorAndExit(err)
	}

	for {
		conn, err := ln.Accept()
		if err != nil {
			log.Fatalf("failed to accept new local proxy connection: %w", err)
		}

		go func(conn net.Conn) {
			vault, err := net.Dial("tcp", u.Host)
			if err != nil {
				log.Println(err)
				return
			}

			log.Printf("forwarding connection: %v -> %v -> %v -> %v", conn.RemoteAddr(), conn.LocalAddr(), vault.LocalAddr(), vault.RemoteAddr())
			vaultWrap := tls.Client(vault, tlsClientConfig)
			err = vaultWrap.Handshake()
			if err != nil {
				log.Println(err)
				return
			}

			copyConn := func(writer, reader net.Conn) {
				defer writer.Close()
				defer reader.Close()
				io.Copy(writer, reader)
			}

			go copyConn(conn, vaultWrap)
			go copyConn(vaultWrap, conn)
		}(conn)
	}
}
