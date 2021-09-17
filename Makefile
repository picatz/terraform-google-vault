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
	@echo 'Usage: make <target>'
	@echo
	@echo 'Targets:'
	@egrep '^(.+)\:\ ##\ (.+)' $(MAKEFILE_LIST) | column -t -c 2 -s ':#'

.PHONY: packer/validate
packer/validate: ## Validates the Packer config
	cd packer && packer validate template.json

.PHONY: packer/build
packer/build: ## Forces a build with Packer
	cd packer && time packer build \
		-force \
		-timestamp-ui \
		template.json

.PHONY: terraform/console
terraform/console: ## Starts the Terraform console
	terraform console

.PHONY: terraform/validate
terraform/validate: ## Validates the Terraform config
	terraform validate

.PHONY: terraform/plan
terraform/plan: ## Runs the Terraform plan command
	terraform plan \
		-var="project=${GOOGLE_PROJECT}" \
		-var="dns_enabled=true" \
		-var="bucket_force_destroy=false" \
		-var="dns_managed_zone_dns_name=${VAULT_PUBLIC_DOMAIN}" \
		-var="dns_record_set_name_prefix=public" \
		-var="credentials=${GOOGLE_APPLICATION_CREDENTIALS}"

.PHONY: terraform/apply
terraform/apply: ## Runs and auto-apporves the Terraform apply command
	terraform apply \
		-auto-approve \
		-var="project=${GOOGLE_PROJECT}" \
		-var="dns_enabled=true" \
		-var="bucket_force_destroy=false" \
		-var="dns_managed_zone_dns_name=${VAULT_PUBLIC_DOMAIN}" \
		-var="dns_record_set_name_prefix=public" \
		-var="credentials=${GOOGLE_APPLICATION_CREDENTIALS}"

.PHONY: terraform/destroy
terraform/destroy: ## Runs and auto-apporves the Terraform destroy command
	terraform destroy \
		-auto-approve \
		-var="project=${GOOGLE_PROJECT}" \
		-var="dns_enabled=true" \
		-var="bucket_force_destroy=false" \
		-var="dns_managed_zone_dns_name=${VAULT_PUBLIC_DOMAIN}" \
		-var="dns_record_set_name_prefix=public" \
		-var="credentials=${GOOGLE_APPLICATION_CREDENTIALS}"

.PHONY: mtls/proxy
mtls/proxy: ## Runs a local mTLS terminating proxy using github.com/picatz/mtls-proxy
	@mtls-proxy -ca-file=$(realpath vault-ca.pem) -cert-file=$(realpath vault-cli-cert.pem) -key-file=$(realpath vault-cli-key.pem) -target-addr="$(shell terraform output -raw load_balancer_ip):443" -listener-addr="127.0.0.1:8200"