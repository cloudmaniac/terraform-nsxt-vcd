## Main config
terraform {
  required_version = ">= 0.13"

  required_providers {
    nsxt = {
      source  = "vmware/nsxt"
      version = "3.2.4"
    }
    vcd = {
      source  = "vmware/vcd"
      version = "3.4.0"
    }
  }
}

## Providers definition
provider "nsxt" {
  host                  = var.nsx_manager
  username              = var.nsx_username
  password              = var.nsx_password
  allow_unverified_ssl  = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
  retry_on_status_codes = [429]
}

provider "vcd" {
  user                 = var.vcd_user
  password             = var.vcd_pass
  org                  = "System"
  url                  = var.vcd_url
  max_retry_timeout    = var.vcd_max_retry_timeout
  allow_unverified_ssl = var.vcd_allow_unverified_ssl
}