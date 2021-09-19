# Makefile argument to enable IAP
#
# $ make terraform/apply IAP_ENABLED=true
#
# https://cloud.google.com/iap/docs/tutorial-gce
IAP_ENABLED := true
#
# $ make terraform/apply IAP_ENABLED=true IAP_MEMBER_EMAILS="$EMAIL_1@gmail.com,$EMAIL_2@gmail.com"
#
IAP_MEMBER_EMAILS := ""

.PHONY: help
help: ## Print this help menu
help:
	@echo HashiCorp Vault on GCP
	@echo
	@echo Required environment variables:
	@echo "* GOOGLE_PROJECT (${GOOGLE_PROJECT})"
	@echo "* GOOGLE_APPLICATION_CREDENTIALS (${GOOGLE_APPLICATION_CREDENTIALS})"
	@echo "* VAULT_PUBLIC_DOMAIN (${VAULT_PUBLIC_DOMAIN})"
	@echo
	@echo Google Cloud IAP OAuth2 environment variables:
	@echo "* GOOGLE_CLIENT_ID (${GOOGLE_CLIENT_ID})"
	@echo "* GOOGLE_CLIENT_SECRET (<sensitive>)"
	@echo
	@echo 'Usage: make <target>'
	@echo
	@echo 'Targets:'
	@egrep '^(.+)\:\ ##\ (.+)' $(MAKEFILE_LIST) | column -t -c 2 -s ':#'

.PHONY: packer/validate
packer/validate: ## Validates the Packer config
	@cd packer && packer validate template.json

.PHONY: packer/build
packer/build: ## Forces a build with Packer
	@cd packer && time packer build \
		-force \
		-timestamp-ui \
		template.json

.PHONY: terraform/console
terraform/console: ## Starts the Terraform console
	@terraform console

.PHONY: terraform/validate
terraform/validate: ## Validates the Terraform config
	@terraform validate

.PHONY: terraform/plan
terraform/plan: ## Runs the Terraform plan command
	@terraform plan \
		-var="project=${GOOGLE_PROJECT}" \
		-var="dns_enabled=true" \
		-var="bucket_force_destroy=false" \
		-var="dns_managed_zone_dns_name=${VAULT_PUBLIC_DOMAIN}" \
		-var="dns_record_set_name_prefix=public" \
		-var="iap_enabled=${IAP_ENABLED}" \
		-var="iap_member_emails=${IAP_MEMBER_EMAILS}" \
		-var="iap_client_id=${GOOGLE_CLIENT_ID}" \
		-var="iap_client_secret=${GOOGLE_CLIENT_SECRET}" \
		-var="credentials=${GOOGLE_APPLICATION_CREDENTIALS}"

.PHONY: terraform/apply
terraform/apply: ## Runs and auto-apporves the Terraform apply command
	@terraform apply \
		-auto-approve \
		-var="project=${GOOGLE_PROJECT}" \
		-var="dns_enabled=true" \
		-var="bucket_force_destroy=false" \
		-var="dns_managed_zone_dns_name=${VAULT_PUBLIC_DOMAIN}" \
		-var="dns_record_set_name_prefix=public" \
		-var="iap_enabled=${IAP_ENABLED}" \
		-var="iap_member_emails=${IAP_MEMBER_EMAILS}" \
		-var="iap_client_id=${GOOGLE_CLIENT_ID}" \
		-var="iap_client_secret=${GOOGLE_CLIENT_SECRET}" \
		-var="credentials=${GOOGLE_APPLICATION_CREDENTIALS}"

.PHONY: terraform/destroy
terraform/destroy: ## Runs and auto-apporves the Terraform destroy command
	@terraform destroy \
		-auto-approve \
		-var="project=${GOOGLE_PROJECT}" \
		-var="dns_enabled=true" \
		-var="bucket_force_destroy=false" \
		-var="dns_managed_zone_dns_name=${VAULT_PUBLIC_DOMAIN}" \
		-var="dns_record_set_name_prefix=public" \
		-var="iap_enabled=${IAP_ENABLED}" \
		-var="iap_member_emails=${IAP_MEMBER_EMAILS}" \
		-var="iap_client_id=${GOOGLE_CLIENT_ID}" \
		-var="iap_client_secret=${GOOGLE_CLIENT_SECRET}" \
		-var="credentials=${GOOGLE_APPLICATION_CREDENTIALS}"

.PHONY: mtls/init/macos/keychain
mtls/init/macos/keychain: ## Create a new macOS keychain for Vault
	@security create-keychain -P vault

.PHONY: mtls/install/macos/keychain
mtls/install/macos/keychain: ## Install generated CA and client certificate in the macOS keychain
	@openssl pkcs12 -export -in vault-cli-cert.pem -inkey vault-cli-key.pem -out vault-cli.p12 -CAfile vault-ca.pem -name "Vault CLI"
	@security import vault-cli.p12 -k $(shell realpath ~/Library/Keychains/vault-db)
	@sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" vault-ca.pem

.PHONY: mtls/proxy
mtls/proxy: ## Runs a local mTLS terminating proxy using github.com/picatz/mtls-proxy
	@mtls-proxy -ca-file=$(realpath vault-ca.pem) -cert-file=$(realpath vault-cli-cert.pem) -key-file=$(realpath vault-cli-key.pem) -target-addr="$(shell terraform output -raw load_balancer_ip):443" -listener-addr="127.0.0.1:8200"