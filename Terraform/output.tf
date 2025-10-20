output "admin_username" {
  description = "Local admin username used by Windows VMs"
  value       = var.admin_username  # or from azurerm_windows_virtual_machine.vm["ContosoDC1"].admin_username if defined
  sensitive   = false
}

# Map hostname -> private IP
output "vm_private_ips" {
  description = "Private IPs for lab VMs"
  value = {
    for name, nic in azurerm_network_interface.nic :
    name => nic.ip_configuration[0].private_ip_address
  }
  sensitive = false
}

# (Optional) domain_admin defaults (DO NOT expose passwords)
# output "domain_admin_user" { value = var.domain_admin_user }