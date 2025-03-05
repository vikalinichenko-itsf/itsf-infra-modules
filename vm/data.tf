data "vcd_catalog" "default" {
  org  = var.org
  name = var.catalog_name
}

data "vcd_catalog_vapp_template" "default" {
  org        = var.org
  catalog_id = data.vcd_catalog.default.id
  name       = var.yaml.vm_template
}

data "vcd_org" "default" {
  name = var.org
}

data "vcd_org_vdc" "default" {
  name = var.org_vdc
  org  = data.vcd_org.default.name
}

data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket     = var.s3_rs_bucket
    key        = var.s3_rs_key
    secret_key = var.s3_rs_secret_key
    access_key = var.s3_rs_access_key
    endpoints = {
      s3 = "https://minio.itsmartflex.internal"
    }
    region                      = "main"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
    insecure                    = true
  }
}