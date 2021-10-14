## Data collection
data "vcd_nsxt_manager" "root_nsxt_mgr_envb" {
  name = "nsxt-rootmgr01-z67.sddc.lab"
}

data "vcd_nsxt_tier0_router" "t0_pod03_shared" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_shared
  ]

  name            = "t0-pod03-shared"
  nsxt_manager_id = data.vcd_nsxt_manager.root_nsxt_mgr_envb.id
}

data "vcd_nsxt_tier0_router" "t0_pod03_vrf01" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_vrf01
  ]

  name            = "t0-pod03-vrf01"
  nsxt_manager_id = data.vcd_nsxt_manager.root_nsxt_mgr_envb.id
}

data "vcd_nsxt_tier0_router" "t0_pod03_vrf02" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_vrf02
  ]

  name            = "t0-pod03-vrf02"
  nsxt_manager_id = data.vcd_nsxt_manager.root_nsxt_mgr_envb.id
}

data "vcd_nsxt_tier0_router" "t0_pod03_vrf03" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_vrf03
  ]

  name            = "t0-pod03-vrf03"
  nsxt_manager_id = data.vcd_nsxt_manager.root_nsxt_mgr_envb.id
}

data "vcd_nsxt_tier0_router" "t0_pod03_vrf04" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_vrf04
  ]

  name            = "t0-pod03-vrf04"
  nsxt_manager_id = data.vcd_nsxt_manager.root_nsxt_mgr_envb.id
}

## Resources management
# External networks
resource "vcd_external_network_v2" "ext_t_pod03_shared" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_shared
  ]

  name        = "ext-t-pod03-shared"
  description = "Tier-0 Gateway Shared - Terraform managed"

  nsxt_network {
    nsxt_manager_id      = data.vcd_nsxt_manager.root_nsxt_mgr_envb.id
    nsxt_tier0_router_id = data.vcd_nsxt_tier0_router.t0_pod03_shared.id
  }

  ip_scope {
    enabled       = true
    gateway       = "10.67.39.254"
    prefix_length = "24"

    static_ip_pool {
      start_address = "10.67.39.151"
      end_address   = "10.67.39.199"
    }
  }
}

resource "vcd_external_network_v2" "ext_t_pod03_vrf01" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_vrf01
  ]

  name        = "ext-t-pod03-vrf01"
  description = "VRF Gateway 01 - Terraform managed"

  nsxt_network {
    nsxt_manager_id      = data.vcd_nsxt_manager.root_nsxt_mgr_envb.id
    nsxt_tier0_router_id = data.vcd_nsxt_tier0_router.t0_pod03_vrf01.id
  }

  ip_scope {
    enabled       = true
    gateway       = "10.67.131.254"
    prefix_length = "24"

    static_ip_pool {
      start_address = "10.67.131.151"
      end_address   = "10.67.131.199"
    }
  }

  ip_scope {
    enabled       = true
    gateway       = "10.67.231.254"
    prefix_length = "24"

    static_ip_pool {
      start_address = "10.67.231.151"
      end_address   = "10.67.231.199"
    }
  }
}

resource "vcd_external_network_v2" "ext_t_pod03_vrf02" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_vrf02
  ]

  name        = "ext-t-pod03-vrf02"
  description = "VRF Gateway 02 - Terraform managed"

  nsxt_network {
    nsxt_manager_id      = data.vcd_nsxt_manager.root_nsxt_mgr_envb.id
    nsxt_tier0_router_id = data.vcd_nsxt_tier0_router.t0_pod03_vrf02.id
  }

  ip_scope {
    enabled       = true
    gateway       = "10.67.132.254"
    prefix_length = "24"

    static_ip_pool {
      start_address = "10.67.132.151"
      end_address   = "10.67.132.199"
    }
  }

  ip_scope {
    enabled       = true
    gateway       = "10.67.232.254"
    prefix_length = "24"

    static_ip_pool {
      start_address = "10.67.232.151"
      end_address   = "10.67.232.199"
    }
  }
}

resource "vcd_external_network_v2" "ext_t_pod03_vrf03" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_vrf03
  ]

  name        = "ext-t-pod03-vrf03"
  description = "VRF Gateway 03 - Terraform managed"

  nsxt_network {
    nsxt_manager_id      = data.vcd_nsxt_manager.root_nsxt_mgr_envb.id
    nsxt_tier0_router_id = data.vcd_nsxt_tier0_router.t0_pod03_vrf03.id
  }

  ip_scope {
    enabled       = true
    gateway       = "10.67.133.254"
    prefix_length = "24"

    static_ip_pool {
      start_address = "10.67.133.151"
      end_address   = "10.67.133.199"
    }
  }

  ip_scope {
    enabled       = true
    gateway       = "10.67.233.254"
    prefix_length = "24"

    static_ip_pool {
      start_address = "10.67.233.151"
      end_address   = "10.67.233.199"
    }
  }
}

resource "vcd_external_network_v2" "ext_t_pod03_vrf04" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_vrf04
  ]

  name        = "ext-t-pod03-vrf04"
  description = "VRF Gateway 04 - Terraform managed"

  nsxt_network {
    nsxt_manager_id      = data.vcd_nsxt_manager.root_nsxt_mgr_envb.id
    nsxt_tier0_router_id = data.vcd_nsxt_tier0_router.t0_pod03_vrf04.id
  }

  ip_scope {
    enabled       = true
    gateway       = "10.67.134.254"
    prefix_length = "24"

    static_ip_pool {
      start_address = "10.67.134.151"
      end_address   = "10.67.134.199"
    }
  }

  ip_scope {
    enabled       = true
    gateway       = "10.67.234.254"
    prefix_length = "24"

    static_ip_pool {
      start_address = "10.67.234.151"
      end_address   = "10.67.234.199"
    }
  }
}