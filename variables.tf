## NSX-T
variable "nsx_manager" {}
variable "nsx_username" {}
variable "nsx_password" {}

## VCD
variable "vcd_user" {}
variable "vcd_pass" {}
variable "vcd_url" {}

variable "vcd_allow_unverified_ssl" {
  default = true
}

variable "vcd_max_retry_timeout" {
  default = 60
}