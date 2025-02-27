resource "vcd_network_routed_v2" "network" {
  count = var.yaml.isolated ? 0 : 1

  name            = "${var.company}-${var.project}-${var.yaml.name}-network"
  org             = data.vcd_org.default.name
  edge_gateway_id = data.vcd_nsxt_edgegateway.default.id
  gateway         = var.yaml.gateway
  prefix_length   = var.yaml.prefix_length
  description     = var.yaml.description
  dns1            = var.yaml.dns1
  dns2            = var.yaml.dns2

  dynamic "static_ip_pool" {
    for_each = var.yaml.ip_pools
    content {
      end_address   = static_ip_pool.value["end_address"]
      start_address = static_ip_pool.value["start_address"]
    }
  }
}

resource "vcd_network_isolated_v2" "network" {
  count = var.yaml.isolated ? 1 : 0

  org      = data.vcd_org.default.name
  owner_id = data.vcd_org_vdc.default.id

  name        = "${var.company}-${var.project}-${var.yaml.name}-network"
  description = var.yaml.description
  dns1        = var.yaml.dns1
  dns2        = var.yaml.dns2

  gateway       = var.yaml.gateway
  prefix_length = var.yaml.prefix_length

  guest_vlan_allowed = var.yaml.guest_vlan_allowed

  dynamic "static_ip_pool" {
    for_each = var.yaml.ip_pools
    content {
      end_address   = static_ip_pool.value["end_address"]
      start_address = static_ip_pool.value["start_address"]
    }
  }
}

resource "vcd_nsxt_network_dhcp" "network_dhcp" {
  count = var.yaml.dhcp_enable ? 1 : 0

  org_network_id      = var.yaml.isolated ? vcd_network_isolated_v2.network[0].id : vcd_network_routed_v2.network[0].id
  mode                = var.yaml.dhcp_mode
  listener_ip_address = var.yaml.listener_ip_address

  dynamic "pool" {
    for_each = var.yaml.dhcp_pools
    content {
      end_address   = pool.value["end_address"]
      start_address = pool.value["start_address"]
    }
  }
}
