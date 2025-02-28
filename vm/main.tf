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


  mac_address = resource.vcd_vm.vcd_vm.network[count.index].mac

  /*
  In case of DHCP binding, we need to takin into account next nuances:
  - if we are under the first creating of a VM we will get all requested DHCP bindings from the VCD regardless the fact that we do not
    have a VM yet and we do not know the MAC address of the VM
  - in case of changing the networking properties of a VM (e.g. we are about to add new network to the VM) we will faced with an issue
    that we do not have a MAC address of the network interface and we can not create a DHCP binding
  The last case (we think so) is coused by the vcd provider and could not be solved in the right way without fixing them.
  
  The workaround could be like that:
  1. We need to taint the VM resource that should to be changed
    # ./bin/terraform taint 'module.vm[0].vcd_vm.vcd_vm'
  2. We need to apply the changes (!!!the VM resource will be recreated!!!)

  OR we can use the next workaround:
  1. Manually create a DHCP binding in the VCD
  2. Import the changes to the terraform state manually
  3. Apply the changes
  */

  dns_servers = [
    data.terraform_remote_state.networking.outputs.networking[var.yaml.networks[count.index].rs_network_index].vcd_network[0].dns1,
    data.terraform_remote_state.networking.outputs.networking[var.yaml.networks[count.index].rs_network_index].vcd_network[0].dns2
  ]


  dynamic "dhcp_v4_config" {
    for_each = var.yaml.networks[count.index].gateway == "" ? toset([]) : toset([1])

    content {
      gateway_ip_address = var.yaml.networks[count.index].gateway
      hostname           = var.yaml.name
    }
  }

}
