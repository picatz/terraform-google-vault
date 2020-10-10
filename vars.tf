variable "project" {
  type        = string
  description = "The Google Cloud Platform project to deploy the Vault cluster to."
}

variable "credentials" {
  type        = string
  default     = "./account.json"
  description = "The path to the valid Google Cloud Platform credentials file (in JSON format) to use."
}

variable "region" {
  type        = string
  default     = "us-east1"
  description = "The region to deploy to."
}

variable "zone" {
  type        = string
  default     = "c"
  description = "The zone to deploy to."
}

variable "cidr_range" {
  type        = string
  default     = "192.168.2.0/24"
  description = "The CIDR to deploy with."
}

variable "internal_lb_ip" {
  type        = string
  default     = "192.168.2.250"
  description = "The IP address of the internal load balancer."
}

variable "machine_type" {
  type        = string
  default     = "g1-small"
  description = "The VM machine type for the Vault servers."
}

variable "server_tags" {
  type        = list(string)
  default     = ["vault-server"]
  description = "Tags to include for the Vault servers."
}

variable "extra_tags" {
  type        = list(string)
  default     = []
  description = "Any extra tags to include for the Vault servers."
}

variable "source_image" {
  type        = string
  default     = "vault"
  description = "The VM machine image to use for the Vault servers."
}

variable "min_num_servers" {
  type        = number
  default     = 1
  description = "The total number of Nomad servers to deploy (use odd numbers)."
}

variable "max_num_servers" {
  type        = number
  default     = 5
  description = "The total number of Nomad servers to deploy (use odd numbers)."
}

variable "tls_organization" {
  type        = string
  default     = "vault-dev"
  description = "The organization name to use the TLS certificates."
}

variable "router_asn" {
  type    = string
  default = "64514"
}

variable "bucket_location" {
  type    = string
  default = "US"
}