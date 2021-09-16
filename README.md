# Vault Cluster

[Terraform](https://www.terraform.io/) Module for [Vault](https://www.vaultproject.io/) clusters on [GCP](https://cloud.google.com/).

## Module Developer Workflow

```console
$ gcloud services enable compute.googleapis.com
...
```

```console
$ gcloud services enable iam.googleapis.com
...
```

```console
$ export GOOGLE_PROJECT="..."
$ export GOOGLE_APPLICATION_CREDENTIALS="$(realpath ...)"
$ make packer/validate
...
$ make packer/build
...
$ make terraform/validate
...
$ make terraform/plan
...
$ make terraform/apply
...
wait 3-5 minutes for everything to be ready
...

Apply complete! Resources: 31 added, 0 changed, 0 destroyed.

Outputs:

load_balancer_ip = "<public_ip>"
vault_backend_bucket = "<bucket_name>"
vault_ca_cert = <sensitive>
vault_cli_cert = <sensitive>
vault_cli_key = <sensitive>
$ export VAULT_ADDR="https://$(terraform output -raw load_balancer_ip):443"
$ export VAULT_CACERT="$(realpath vault-ca.pem)"
$ export VAULT_CLIENT_CERT="$(realpath vault-cli-cert.pem)"
$ export VAULT_CLIENT_KEY="$(realpath vault-cli-key.pem)"
$ vault status
Key                Value
---                -----
Seal Type          shamir
Initialized        false
Sealed             true
Total Shares       0
Threshold          0
Unseal Progress    0/0
Unseal Nonce       n/a
Version            n/a
HA Enabled         true
$ vault operator init
Unseal Key 1: 3XCK7VkEw1TeGvEJW7QQtFw+3+HY8xlIRz5JEcY/CAom
Unseal Key 2: AceqBe9GaOhkBAkeaMEqVrMzgW7paC7YvUrmS6hYatFK
Unseal Key 3: /c6+8CEItwKFk7q9yFr6qQBWTjq9+QmlDokC82zy3mgr
Unseal Key 4: raxKXKh2qCNLP5GiUc4iURIgS1wCDgx+I3fWwNzdIGx0
Unseal Key 5: 2PC7LdgF9UYd624BAx1FvD3QI3TQ9pE9NcXHn7yXRW3a

Initial Root Token: s.SZTm4Z4jYUUeeyZzNTfgpGOc

Vault initialized with 5 key shares and a key threshold of 3. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 3 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated master key. Without at least 3 key to
reconstruct the master key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.
$ export VAULT_TOKEN="s.SZTm4Z4jYUUeeyZzNTfgpGOc"
$ vault status
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    0/3
Unseal Nonce       n/a
Version            1.5.0
HA Enabled         true
$ vault operator unseal
Unseal Key (will be hidden):
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    1/3
Unseal Nonce       87cdd42f-a3f1-544f-f805-c836271540e8
Version            1.5.0
HA Enabled         true
$ vault operator unseal
Unseal Key (will be hidden):
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    2/3
Unseal Nonce       87cdd42f-a3f1-544f-f805-c836271540e8
Version            1.5.0
HA Enabled         true
$ vault operator unseal
Unseal Key (will be hidden):
Key                    Value
---                    -----
Seal Type              shamir
Initialized            true
Sealed                 false
Total Shares           5
Threshold              3
Version                1.5.0
Cluster Name           vault-cluster-3aa19181
Cluster ID             6e8e8376-76d4-26b4-ff0a-6a7283defb15
HA Enabled             true
HA Cluster             n/a
HA Mode                standby
Active Node Address    <none>
$ vault auth enable ...
```

## Admin Policy

```console
$ vault policy write admin policies/admin/policy.hcl
Success! Uploaded policy: admin
```

## GitHub Authn

```console
$ export GITHUB_ORG="..."
$ export GITHUB_TOKEN="..."
$ vault auth enable github
...
$ vault write auth/github/config organization=$GITHUB_ORG
...
$ vault read auth/github/config
Key                        Value
---                        -----
base_url                   n/a
organization               ...
token_bound_cidrs          []
token_explicit_max_ttl     0s
token_max_ttl              0s
token_no_default_policy    false
token_num_uses             0
token_period               0s
token_policies             []
token_ttl                  0s
token_type                 default
$ curl --key vault_cli_key.pem --cert vault_cli_cert.pem  --cacert vault_ca_cert.pem --header "X-Vault-Token: $VAULT_TOKEN" "$VAULT_ADDR/v1/auth/github/config"
{
  "request_id": "1280fb3d-a650-168d-049e-055a2e17ffc2",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data": {
    "base_url": "",
    "organization": "...",
    "token_bound_cidrs": [],
    "token_explicit_max_ttl": 0,
    "token_max_ttl": 0,
    "token_no_default_policy": false,
    "token_num_uses": 0,
    "token_period": 0,
    "token_policies": [],
    "token_ttl": 0,
    "token_type": "default"
  },
  "wrap_info": null,
  "warnings": null,
  "auth": null
}
$ vault login -method=github token=$GITHUB_TOKEN
...
Key                    Value
---                    -----
token                  s.JFo4k2okFKOWFWK34592eS
token_accessor         KRFJWWJFOFDMKCMVNodf3400
token_duration         768h
token_renewable        true
token_policies         ["default"]
identity_policies      []
policies               ["default"]
token_meta_org         whatever-it-is
token_meta_username    whoever-it-is
$ export VAULT_TOKEN="s.JFo4k2okFKOWFWK34592eS"
```

## OIDC Authn using Google OAuth with Gmail Login

```console
$ export VAULT_ADDR="https://$VAULT_DOMAIN_OR_IP_ADDRESS:$VAULT_PORT"
$ export OIDC_CLIENT_ID="..."
$ export OIDC_CLIENT_SECRET="..."
$ vault auth enable oidc
$ vault write auth/oidc/config \
    oidc_discovery_url="https://accounts.google.com" \
    oidc_client_id="$OIDC_CLIENT_ID" \
    oidc_client_secret="$OIDC_CLIENT_SECRET" \
    default_role="gmail"
$ vault write auth/oidc/role/gmail -<<EOF
{
  "allowed_redirect_uris": ["$VAULT_ADDR/ui/vault/auth/oidc/oidc/callback","http://localhost:8250/oidc/callback"],
  "policies":"default",
  "user_claim": "sub",
  "oidc_scopes": ["openid", "https://www.googleapis.com/auth/userinfo.profile", "https://www.googleapis.com/auth/userinfo.email"],
  "bound_audiences": "$OIDC_CLIENT_ID",
  "bound_claims": {
    "email": ["$YOUR_GMAIL_HERE@gmail.com"],
    "email_verified": true
  }
}
EOF
$ vault login -method=oidc role=gmail
```

Read more about this authentication method [here](https://github.com/hashicorp/vault-guides/tree/master/identity/oidc-auth#configure-vault).

### Secrets Engines

#### Nomad

```console
$ vault secrets enable nomad
$ vault write nomad/config/access \
    address=$NOMAD_ADDR \
    token=$NOMAD_TOKEN \
    ca_cert="$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $NOMAD_CA)" \
    client_cert="$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $NOMAD_CERT)" \
    client_cert="$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $NOMAD_KEY)"
...
$ vault write nomad/role/monitoring policies=readonly
...
$ vault read nomad/creds/monitoring
Key              Value
---              -----
lease_id         nomad/creds/monitoring/78ec3ef3-c806-1022-4aa8-1dbae39c760c
lease_duration   768h0m0s
lease_renewable  true
accessor_id      a715994d-f5fd-1194-73df-ae9dad616307
secret_id        b31fb56c-0936-5428-8c5f-ed010431aba9
$ nomad acl token info a715994d-f5fd-1194-73df-ae9dad616307
Accessor ID  = a715994d-f5fd-1194-73df-ae9dad616307
Secret ID    = b31fb56c-0936-5428-8c5f-ed010431aba9
Name         = Vault example root 1505945527022465593
Type         = client
Global       = false
Policies     = [readonly]
Create Time  = 2017-09-20 22:12:07.023455379 +0000 UTC
Create Index = 138
Modify Index = 138
```

Nomad access configuration options listed [here](https://www.vaultproject.io/api/secret/nomad#nomad-secret-backend-http-api).

#### TOTP

```console
$ vault secrets enable totp
...
```

To use Vault as a generator (like Google Authenticator):

```console
$ vault write totp/keys/my-key url="otpauth://totp/Vault:test@test.com?secret=Y64VEVMBTSXCYIWRSHRNDZW62MPGVU2G&issuer=Vault"
...
$ vault read totp/code/my-key
Key     Value
---     -----
code    260610
```

To use Vault as a provider (for your own service to support TOTP):

```console
$ vault secrets enable totp
...
$ vault write totp/keys/my-user \
    generate=true \
    issuer=Vault \
    account_name=user@test.com
Key        Value
---        -----
barcode    iVBORw0KGgoAAAANSUhEUgAAAMgAAADIEAAAAADYoy0BA...
url        otpauth://totp/Vault:user@test.com?algorithm=SHA1&digits=6&issuer=Vault&period=30&secret=V7MBSK324I7KF6KVW34NDFH2GYHIF6JY
$ vault write totp/code/my-user code=886531
Key      Value
---      -----
valid    true
```
