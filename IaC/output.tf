# output "upload_file" {
#   value = "ssh ${var.admin_username}@${data.azurerm_public_ip.ds-pip.ip_address} 'bash -s' < ../scripts/config-vm.sh"
# }
output "ssh_tunnel_cmd" {
  value = "ssh -L 0.0.0.0:8888:localhost:8888 ${var.admin_username}@${data.azurerm_public_ip.ds-pip.ip_address}"
  depends_on = [ time_sleep.stall_for_pip ]
}
output "run_this_when_logged_in" {
  value = "sudo chmod +x config-vm.sh;sudo ./config-vm.sh;jupyter notebook;"
}
output "vm_password" {
  value = random_string.vm_password.result
}