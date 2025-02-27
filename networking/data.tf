data "vcd_org" "default" {
  name = var.org
}

data "vcd_org_vdc" "default" {
  name = var.org_vdc
  org  = data.vcd_org.default.name
}

data "vcd_nsxt_edgegateway" "default" {
  org  = data.vcd_org.default.name
  name = var.edge_gateway_default
}