output "vcd_network" {
  value = var.yaml.isolated ? resource.vcd_network_isolated_v2.network : resource.vcd_network_routed_v2.network
}

output "vcd_nsxt_network_dhcp" {
  value = var.yaml.dhcp_enable ? resource.vcd_nsxt_network_dhcp.network_dhcp : null
}