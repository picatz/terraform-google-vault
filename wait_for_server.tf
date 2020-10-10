resource "null_resource" "wait_for_server" {
  provisioner "local-exec" {
    command = format("until curl https://%s:443 -k 2>&1 | grep --silent -i 'bad cert'; do echo 'waiting for vault to become available...'; sleep 10; done", google_compute_global_address.vault_external.address)
    interpreter = ["/bin/bash", "-c"]
  }
}