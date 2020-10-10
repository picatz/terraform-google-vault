#!/bin/bash

# VAULT CONFIGURATION

# Add the Vault CA PEM
cat > /tmp/vault-ca.pem << EOF
${vault_ca_cert}
EOF
sudo mv /tmp/vault-ca.pem /vault/config/vault-ca.pem

# Add the vault Server PEM
cat > /tmp/server.pem << EOF
${vault_server_cert}
EOF
sudo mv /tmp/server.pem /vault/config/server.pem

# Add the vault Server Private Key PEM
cat > /tmp/server-key.pem << EOF
${vault_server_private_key}
EOF
sudo mv /tmp/server-key.pem /vault/config/server-key.pem

# Update the {PRIVATE-IPV4} ad-hoc template var
IP=$(curl -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip)
sed -i -e "s/{PRIVATE-IPV4}/$${IP}/g" /vault/config/agent.hcl

# Update the {BUCKET} ad-hoc template var
sed -i -e "s/{BUCKET}/${bucket}/g" /vault/config/agent.hcl

# Enable and start vault
systemctl enable vault
systemctl start vault