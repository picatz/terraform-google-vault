# Manage anything and everything without any safety
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}