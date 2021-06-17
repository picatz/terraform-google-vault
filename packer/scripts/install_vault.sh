#!/bin/bash

set -ex

# Latest version of Vault
VAULT_VERSION=1.7.3

# Download Latest Version of Vault
mkdir -p /tmp/download-vault
cd /tmp/download-vault
curl "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip" -o vault.zip
unzip vault.zip
sudo chown root:root vault
sudo mv vault /bin
cd /tmp
rm -rf /tmp/download-vault
vault version

# Give Vault the ability to run mlock as non-root
sudo /sbin/setcap cap_ipc_lock=+ep /bin/vault

# Create user
sudo useradd --system --home /vault --shell /bin/false vault

# Setup Systemd Service
sudo touch /etc/systemd/system/vault.service
sudo mv /tmp/vault.service /etc/systemd/system/vault.service
sudo systemctl daemon-reload

# Setup Config and Data Directory
sudo mkdir -p /vault/data && sudo mkdir -p /vault/config
sudo mv /tmp/agent.hcl /vault/config/agent.hcl
sudo chown --recursive vault:vault /vault