resource "vcd_vm" "vcd_vm" {
  name = "${var.company}-${var.project}-${var.yaml.name}"

  vapp_template_id = data.vcd_catalog_vapp_template.default.id
  power_on         = false
  computer_name    = var.yaml.name
  cpus             = var.yaml.vm_cpu
  memory           = var.yaml.vm_ram

  guest_properties = {
    "guest.hostname" = var.yaml.name
  }

  dynamic "network" {
    for_each = var.yaml.networks
    content {
      name               = data.terraform_remote_state.networking.outputs.networking[network.value["rs_network_index"]].vcd_network[0].name
      type               = "org"
      ip_allocation_mode = "MANUAL"
      ip                 = network.value["ip"]
    }
  }

  dynamic "disk" {
    for_each = var.yaml.vm_independent_disks
    content {
      name        = vcd_independent_disk.independent_disk[disk.key].name
      bus_number  = disk.key + 1
      unit_number = disk.key + 1
    }
  }
}

resource "vcd_independent_disk" "independent_disk" {
  count = length(var.yaml.vm_independent_disks)

  vdc             = data.vcd_org_vdc.default.name
  name            = "${var.company}-${var.project}-${var.yaml.name}-independent_disk-${count.index}"
  size_in_mb      = var.yaml.vm_independent_disks[count.index].vm_disk_size
  bus_type        = "SCSI"
  bus_sub_type    = "VirtualSCSI"
  storage_profile = "Hyper speed space"
}

resource "vcd_nsxt_network_dhcp_binding" "dhcp_binding" {
  count = length(var.yaml.networks)

  org = data.vcd_org.default.name

  org_network_id = data.terraform_remote_state.networking.outputs.networking[var.yaml.networks[count.index].rs_network_index].vcd_network[0].id

  name         = "${var.company}-${var.project}-${var.yaml.networks[count.index].ip}-DHCP-binding"
  description  = "DHCP binding description"
  binding_type = "IPV4"
  ip_address   = var.yaml.networks[count.index].ip
  lease_time   = 3600
  mac_address  = resource.vcd_vm.vcd_vm.network[count.index].mac
  dns_servers = [
    data.terraform_remote_state.networking.outputs.networking[var.yaml.networks[count.index].rs_network_index].vcd_network[0].dns1,
    data.terraform_remote_state.networking.outputs.networking[var.yaml.networks[count.index].rs_network_index].vcd_network[0].dns2
  ]
  /*
  dhcp_v4_config {
    gateway_ip_address = var.yaml.networks[count.index].gateway
  }
*/
}
