## Data collection
data "nsxt_policy_transport_zone" "pod03_tz_overlay01" {
  display_name = "tz-pod03-overlay01"
}

data "nsxt_policy_transport_zone" "pod03_tz_vlan01" {
  display_name = "tz-pod03-vlan01"
}

data "nsxt_policy_edge_cluster" "pod03_edgecluster_root" {
  display_name = "edgecluster-pod03-root"
}

data "nsxt_policy_edge_node" "pod03_edgecluster_root_edge01" {
  edge_cluster_path = data.nsxt_policy_edge_cluster.pod03_edgecluster_root.path
  display_name      = "nsxt-pod03-edge00"
}

data "nsxt_policy_edge_cluster" "pod03_edgecluster_shared" {
  display_name = "edgecluster-pod03-shared"
}

data "nsxt_policy_edge_node" "pod03_edgecluster_shared_edge01" {
  edge_cluster_path = data.nsxt_policy_edge_cluster.pod03_edgecluster_shared.path
  display_name      = "nsxt-pod03-edge01"
}

data "nsxt_policy_edge_node" "pod03_edgecluster_shared_edge02" {
  edge_cluster_path = data.nsxt_policy_edge_cluster.pod03_edgecluster_shared.path
  display_name      = "nsxt-pod03-edge02"
}

data "nsxt_policy_edge_cluster" "pod03_edgecluster_vrfparent" {
  display_name = "edgecluster-pod03-vrfparent"
}

data "nsxt_policy_edge_node" "pod03_edgecluster_vrfparent_edge03" {
  edge_cluster_path = data.nsxt_policy_edge_cluster.pod03_edgecluster_vrfparent.path
  display_name      = "nsxt-pod03-edge03"
}

data "nsxt_policy_edge_node" "pod03_edgecluster_vrfparent_edge04" {
  edge_cluster_path = data.nsxt_policy_edge_cluster.pod03_edgecluster_vrfparent.path
  display_name      = "nsxt-pod03-edge04"
}

## Resources management
# Common
resource "nsxt_policy_vlan_segment" "pod03_uplink_segment" {
  display_name        = "ls-uplink-pod03-vlan39"
  transport_zone_path = data.nsxt_policy_transport_zone.pod03_tz_vlan01.path
  vlan_ids            = ["39"]
}

resource "nsxt_policy_vlan_segment" "pod03_uplink_segment_vrfparent" {
  display_name        = "ls-uplink-pod03-vrfparent-vlan130"
  transport_zone_path = data.nsxt_policy_transport_zone.pod03_tz_vlan01.path
  vlan_ids            = ["130"]
}

resource "nsxt_policy_vlan_segment" "pod03_uplink_segment_vrftrunk" {
  display_name        = "ls-uplink-pod03-vrf-trunk"
  transport_zone_path = data.nsxt_policy_transport_zone.pod03_tz_vlan01.path
  vlan_ids            = ["131-139"]
}

resource "nsxt_policy_vlan_segment" "pod03_imported_vlan_example01" {
  display_name        = "ls-imported-pod03-vlan123-ex01"
  transport_zone_path = data.nsxt_policy_transport_zone.pod03_tz_vlan01.path
  vlan_ids            = ["123"]
}

resource "nsxt_policy_vlan_segment" "pod03_imported_vlan_example02" {
  display_name        = "ls-imported-pod03-vlan123-ex02"
  transport_zone_path = data.nsxt_policy_transport_zone.pod03_tz_vlan01.path
  vlan_ids            = ["123"]
}

############################################################################################################
# Tier-0 gateway: t0-pod03-root
resource "nsxt_policy_tier0_gateway" "t0_pod03_root" {
  description       = "Common tier-0 for generic services"
  display_name      = "t0-pod03-root"
  failover_mode     = "PREEMPTIVE"
  ha_mode           = "ACTIVE_STANDBY"
  edge_cluster_path = data.nsxt_policy_edge_cluster.pod03_edgecluster_root.path

  bgp_config {
    local_as_num = "65301"
  }

  redistribution_config {
    enabled = true
    rule {
      name  = "tier1-connected-int"
      types = ["TIER1_CONNECTED"]
    }
  }
}

resource "nsxt_policy_tier0_gateway_interface" "t0_pod03_root_int_edge01" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_root
  ]

  display_name   = "nsxt-t0-pod03-root-edge00-uplink01"
  type           = "EXTERNAL"
  edge_node_path = data.nsxt_policy_edge_node.pod03_edgecluster_root_edge01.path
  gateway_path   = nsxt_policy_tier0_gateway.t0_pod03_root.path
  segment_path   = nsxt_policy_vlan_segment.pod03_uplink_segment.path
  subnets        = ["10.67.39.60/24"]
}

resource "nsxt_policy_bgp_neighbor" "t0_pod03_root_bgp_neighbor_core_1_int_vlan39" {
  display_name     = "core-1-int-vlan39"
  description      = "Terraform provisioned BGP neighbor configuration"
  bgp_path         = nsxt_policy_tier0_gateway.t0_pod03_root.bgp_config.0.path
  neighbor_address = "10.67.39.252"
  remote_as_num    = "65001"
}

resource "nsxt_policy_bgp_neighbor" "t0_pod03_root_bgp_neighbor_core_2_int_vlan39" {
  display_name     = "core-2-int-vlan39"
  description      = "Terraform provisioned BGP neighbor configuration"
  bgp_path         = nsxt_policy_tier0_gateway.t0_pod03_root.bgp_config.0.path
  neighbor_address = "10.67.39.253"
  remote_as_num    = "65001"
}

resource "nsxt_policy_dhcp_server" "dhcp_profile_avi_pod03" {
  display_name     = "dhcp-profile-mgtavi-pod03 "
  server_addresses = ["100.96.0.1/30"]
}

resource "nsxt_policy_tier1_gateway" "t1_pod03_avi_mgmt" {
  display_name              = "t1-avi-mgmt-pod03"
  description               = "Tier1 provisioned by Terraform"
  edge_cluster_path         = data.nsxt_policy_edge_cluster.pod03_edgecluster_root.path
  dhcp_config_path          = nsxt_policy_dhcp_server.dhcp_profile_avi_pod03.path
  failover_mode             = "PREEMPTIVE"
  enable_firewall           = "false"
  tier0_path                = nsxt_policy_tier0_gateway.t0_pod03_root.path
  route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED"]
  pool_allocation           = "ROUTING"
}

resource "nsxt_policy_segment" "ls_pod03_avi_mgt" {
  display_name        = "ls-avi-mgmt-pod03"
  description         = "Pod03 Avi service engines management network segment"
  connectivity_path   = nsxt_policy_tier1_gateway.t1_pod03_avi_mgmt.path
  transport_zone_path = data.nsxt_policy_transport_zone.pod03_tz_overlay01.path

  subnet {
    cidr        = "192.168.253.1/24"
    dhcp_ranges = ["192.168.253.10-192.168.253.99"]
  }
}

resource "nsxt_policy_segment" "ls_pod03_avi_vip" {
  display_name        = "ls-avi-vip-pod03"
  description         = "Pod03 dummy Avi VIP segment (to have a healthy NSX-T Cloud)"
  connectivity_path   = nsxt_policy_tier1_gateway.t1_pod03_avi_mgmt.path
  transport_zone_path = data.nsxt_policy_transport_zone.pod03_tz_overlay01.path

  subnet {
    cidr = "192.168.153.1/24"
  }
}

############################################################################################################
# Tier-0 gateway: t0-pod03-shared
resource "nsxt_policy_tier0_gateway" "t0_pod03_shared" {
  description       = "Shared internet access"
  display_name      = "t0-pod03-shared"
  failover_mode     = "PREEMPTIVE"
  ha_mode           = "ACTIVE_STANDBY"
  edge_cluster_path = data.nsxt_policy_edge_cluster.pod03_edgecluster_shared.path

  bgp_config {
    local_as_num = "65300"
  }
}

resource "nsxt_policy_tier0_gateway_interface" "t0_pod03_shared_int_edge01" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_shared
  ]

  display_name   = "nsxt-t0-pod03-shared-edge01-uplink01"
  type           = "EXTERNAL"
  edge_node_path = data.nsxt_policy_edge_node.pod03_edgecluster_shared_edge01.path
  gateway_path   = nsxt_policy_tier0_gateway.t0_pod03_shared.path
  segment_path   = nsxt_policy_vlan_segment.pod03_uplink_segment.path
  subnets        = ["10.67.39.61/24"]
}

resource "nsxt_policy_tier0_gateway_interface" "t0_pod03_shared_int_edge02" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_shared
  ]

  display_name   = "nsxt-t0-pod03-shared-edge02-uplink01"
  type           = "EXTERNAL"
  edge_node_path = data.nsxt_policy_edge_node.pod03_edgecluster_shared_edge02.path
  gateway_path   = nsxt_policy_tier0_gateway.t0_pod03_shared.path
  segment_path   = nsxt_policy_vlan_segment.pod03_uplink_segment.path
  subnets        = ["10.67.39.62/24"]
}

resource "nsxt_policy_bgp_neighbor" "t0_pod03_shared_bgp_neighbor_core_1_int_vlan39" {
  display_name     = "core-1-int-vlan39"
  description      = "Terraform provisioned BGP neighbor configuration"
  bgp_path         = nsxt_policy_tier0_gateway.t0_pod03_shared.bgp_config.0.path
  neighbor_address = "10.67.39.252"
  remote_as_num    = "65001"
}

resource "nsxt_policy_bgp_neighbor" "t0_pod03_shared_bgp_neighbor_core_2_int_vlan39" {
  display_name     = "core-2-int-vlan39"
  description      = "Terraform provisioned BGP neighbor configuration"
  bgp_path         = nsxt_policy_tier0_gateway.t0_pod03_shared.bgp_config.0.path
  neighbor_address = "10.67.39.253"
  remote_as_num    = "65001"
}

############################################################################################################
# Tier-0 gateway: t0-pod03-vrfparent
resource "nsxt_policy_tier0_gateway" "t0_pod03_vrfparent" {
  description       = "Tier-0 parent for VRF"
  display_name      = "t0-pod03-vrfparent"
  failover_mode     = "NON_PREEMPTIVE"
  ha_mode           = "ACTIVE_ACTIVE"
  edge_cluster_path = data.nsxt_policy_edge_cluster.pod03_edgecluster_vrfparent.path

  bgp_config {
    local_as_num  = "65310"
    inter_sr_ibgp = true
  }
}

resource "nsxt_policy_tier0_gateway_interface" "t0_pod03_vrfparent_int_edge03" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_vrfparent
  ]

  display_name   = "nsxt-t0-pod03-vrfparent-edge03-uplink01"
  type           = "EXTERNAL"
  edge_node_path = data.nsxt_policy_edge_node.pod03_edgecluster_vrfparent_edge03.path
  gateway_path   = nsxt_policy_tier0_gateway.t0_pod03_vrfparent.path
  segment_path   = nsxt_policy_vlan_segment.pod03_uplink_segment_vrfparent.path
  subnets        = ["10.67.130.63/24"]
}

resource "nsxt_policy_tier0_gateway_interface" "t0_pod03_vrfparent_int_edge04" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_vrfparent
  ]

  display_name   = "nsxt-t0-pod03-vrfparent-edge04-uplink01"
  type           = "EXTERNAL"
  edge_node_path = data.nsxt_policy_edge_node.pod03_edgecluster_vrfparent_edge04.path
  gateway_path   = nsxt_policy_tier0_gateway.t0_pod03_vrfparent.path
  segment_path   = nsxt_policy_vlan_segment.pod03_uplink_segment_vrfparent.path
  subnets        = ["10.67.130.64/24"]
}

############################################################################################################
# Tier-0 gateway: t0-pod03-vrf01
resource "nsxt_policy_tier0_gateway" "t0_pod03_vrf01" {
  description       = "VRF Gateway 01"
  display_name      = "t0-pod03-vrf01"
  failover_mode     = "NON_PREEMPTIVE"
  edge_cluster_path = data.nsxt_policy_edge_cluster.pod03_edgecluster_vrfparent.path

  bgp_config {
  }

  vrf_config {
    gateway_path = nsxt_policy_tier0_gateway.t0_pod03_vrfparent.path
  }
}

resource "nsxt_policy_tier0_gateway_interface" "t0_pod03_vrf01_int_edge03" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_vrf01
  ]

  display_name   = "nsxt-t0-pod03-vrf01-edge03-uplink01"
  type           = "EXTERNAL"
  edge_node_path = data.nsxt_policy_edge_node.pod03_edgecluster_vrfparent_edge03.path
  gateway_path   = nsxt_policy_tier0_gateway.t0_pod03_vrf01.path
  segment_path   = nsxt_policy_vlan_segment.pod03_uplink_segment_vrftrunk.path
  access_vlan_id = 131
  subnets        = ["10.67.131.63/24"]
}

resource "nsxt_policy_tier0_gateway_interface" "t0_pod03_vrf01_int_edge04" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_vrf01
  ]

  display_name   = "nsxt-t0-pod03-vrf01-edge04-uplink01"
  type           = "EXTERNAL"
  edge_node_path = data.nsxt_policy_edge_node.pod03_edgecluster_vrfparent_edge04.path
  gateway_path   = nsxt_policy_tier0_gateway.t0_pod03_vrf01.path
  segment_path   = nsxt_policy_vlan_segment.pod03_uplink_segment_vrftrunk.path
  access_vlan_id = 131
  subnets        = ["10.67.131.64/24"]
}

resource "nsxt_policy_bgp_neighbor" "t0_pod03_vrf01_bgp_neighbor_core_1_int_vlan131" {
  display_name     = "core-1-int-vlan131"
  description      = "Terraform provisioned BGP neighbor configuration"
  bgp_path         = nsxt_policy_tier0_gateway.t0_pod03_vrf01.bgp_config.0.path
  neighbor_address = "10.67.131.252"
  remote_as_num    = "65001"
}

resource "nsxt_policy_bgp_neighbor" "t0_pod03_vrf01_bgp_neighbor_core_2_int_vlan131" {
  display_name     = "core-2-int-vlan131"
  description      = "Terraform provisioned BGP neighbor configuration"
  bgp_path         = nsxt_policy_tier0_gateway.t0_pod03_vrf01.bgp_config.0.path
  neighbor_address = "10.67.131.253"
  remote_as_num    = "65001"
}

############################################################################################################
# Tier-0 gateway: t0-pod03-vrf02
resource "nsxt_policy_tier0_gateway" "t0_pod03_vrf02" {
  description       = "VRF Gateway 02"
  display_name      = "t0-pod03-vrf02"
  failover_mode     = "NON_PREEMPTIVE"
  edge_cluster_path = data.nsxt_policy_edge_cluster.pod03_edgecluster_vrfparent.path

  bgp_config {
  }

  vrf_config {
    gateway_path = nsxt_policy_tier0_gateway.t0_pod03_vrfparent.path
  }
}

resource "nsxt_policy_tier0_gateway_interface" "t0_pod03_vrf02_int_edge03" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_vrf02
  ]

  display_name   = "nsxt-t0-pod03-vrf02-edge03-uplink01"
  type           = "EXTERNAL"
  edge_node_path = data.nsxt_policy_edge_node.pod03_edgecluster_vrfparent_edge03.path
  gateway_path   = nsxt_policy_tier0_gateway.t0_pod03_vrf02.path
  segment_path   = nsxt_policy_vlan_segment.pod03_uplink_segment_vrftrunk.path
  access_vlan_id = 132
  subnets        = ["10.67.132.63/24"]
}

resource "nsxt_policy_tier0_gateway_interface" "t0_pod03_vrf02_int_edge04" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_vrf02
  ]

  display_name   = "nsxt-t0-pod03-vrf02-edge04-uplink01"
  type           = "EXTERNAL"
  edge_node_path = data.nsxt_policy_edge_node.pod03_edgecluster_vrfparent_edge04.path
  gateway_path   = nsxt_policy_tier0_gateway.t0_pod03_vrf02.path
  segment_path   = nsxt_policy_vlan_segment.pod03_uplink_segment_vrftrunk.path
  access_vlan_id = 132
  subnets        = ["10.67.132.64/24"]
}

resource "nsxt_policy_bgp_neighbor" "t0_pod03_vrf02_bgp_neighbor_core_1_int_vlan132" {
  display_name     = "core-1-int-vlan132"
  description      = "Terraform provisioned BGP neighbor configuration"
  bgp_path         = nsxt_policy_tier0_gateway.t0_pod03_vrf02.bgp_config.0.path
  neighbor_address = "10.67.132.252"
  remote_as_num    = "65001"
}

resource "nsxt_policy_bgp_neighbor" "t0_pod03_vrf02_bgp_neighbor_core_2_int_vlan132" {
  display_name     = "core-2-int-vlan132"
  description      = "Terraform provisioned BGP neighbor configuration"
  bgp_path         = nsxt_policy_tier0_gateway.t0_pod03_vrf02.bgp_config.0.path
  neighbor_address = "10.67.132.253"
  remote_as_num    = "65001"
}

############################################################################################################
# Tier-0 gateway: t0-pod03-vrf03
resource "nsxt_policy_tier0_gateway" "t0_pod03_vrf03" {
  description       = "VRF Gateway 03"
  display_name      = "t0-pod03-vrf03"
  failover_mode     = "NON_PREEMPTIVE"
  edge_cluster_path = data.nsxt_policy_edge_cluster.pod03_edgecluster_vrfparent.path

  bgp_config {
  }

  vrf_config {
    gateway_path = nsxt_policy_tier0_gateway.t0_pod03_vrfparent.path
  }
}

resource "nsxt_policy_tier0_gateway_interface" "t0_pod03_vrf03_int_edge03" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_vrf03
  ]

  display_name   = "nsxt-t0-pod03-vrf03-edge03-uplink01"
  type           = "EXTERNAL"
  edge_node_path = data.nsxt_policy_edge_node.pod03_edgecluster_vrfparent_edge03.path
  gateway_path   = nsxt_policy_tier0_gateway.t0_pod03_vrf03.path
  segment_path   = nsxt_policy_vlan_segment.pod03_uplink_segment_vrftrunk.path
  access_vlan_id = 133
  subnets        = ["10.67.133.63/24"]
}

resource "nsxt_policy_tier0_gateway_interface" "t0_pod03_vrf03_int_edge04" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_vrf03
  ]

  display_name   = "nsxt-t0-pod03-vrf03-edge04-uplink01"
  type           = "EXTERNAL"
  edge_node_path = data.nsxt_policy_edge_node.pod03_edgecluster_vrfparent_edge04.path
  gateway_path   = nsxt_policy_tier0_gateway.t0_pod03_vrf03.path
  segment_path   = nsxt_policy_vlan_segment.pod03_uplink_segment_vrftrunk.path
  access_vlan_id = 133
  subnets        = ["10.67.133.64/24"]
}

resource "nsxt_policy_bgp_neighbor" "t0_pod03_vrf03_bgp_neighbor_core_1_int_vlan133" {
  display_name     = "core-1-int-vlan133"
  description      = "Terraform provisioned BGP neighbor configuration"
  bgp_path         = nsxt_policy_tier0_gateway.t0_pod03_vrf03.bgp_config.0.path
  neighbor_address = "10.67.133.252"
  remote_as_num    = "65001"
}

resource "nsxt_policy_bgp_neighbor" "t0_pod03_vrf03_bgp_neighbor_core_2_int_vlan133" {
  display_name     = "core-2-int-vlan133"
  description      = "Terraform provisioned BGP neighbor configuration"
  bgp_path         = nsxt_policy_tier0_gateway.t0_pod03_vrf03.bgp_config.0.path
  neighbor_address = "10.67.133.253"
  remote_as_num    = "65001"
}

############################################################################################################
# Tier-0 gateway: t0-pod03-vrf04
resource "nsxt_policy_tier0_gateway" "t0_pod03_vrf04" {
  description       = "VRF Gateway 04"
  display_name      = "t0-pod03-vrf04"
  failover_mode     = "NON_PREEMPTIVE"
  edge_cluster_path = data.nsxt_policy_edge_cluster.pod03_edgecluster_vrfparent.path

  bgp_config {
  }

  vrf_config {
    gateway_path = nsxt_policy_tier0_gateway.t0_pod03_vrfparent.path
  }
}

resource "nsxt_policy_tier0_gateway_interface" "t0_pod03_vrf04_int_edge03" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_vrf04
  ]

  display_name   = "nsxt-t0-pod03-vrf04-edge03-uplink01"
  type           = "EXTERNAL"
  edge_node_path = data.nsxt_policy_edge_node.pod03_edgecluster_vrfparent_edge03.path
  gateway_path   = nsxt_policy_tier0_gateway.t0_pod03_vrf04.path
  segment_path   = nsxt_policy_vlan_segment.pod03_uplink_segment_vrftrunk.path
  access_vlan_id = 134
  subnets        = ["10.67.134.63/24"]
}

resource "nsxt_policy_tier0_gateway_interface" "t0_pod03_vrf04_int_edge04" {
  depends_on = [
    nsxt_policy_tier0_gateway.t0_pod03_vrf04
  ]

  display_name   = "nsxt-t0-pod03-vrf04-edge04-uplink01"
  type           = "EXTERNAL"
  edge_node_path = data.nsxt_policy_edge_node.pod03_edgecluster_vrfparent_edge04.path
  gateway_path   = nsxt_policy_tier0_gateway.t0_pod03_vrf04.path
  segment_path   = nsxt_policy_vlan_segment.pod03_uplink_segment_vrftrunk.path
  access_vlan_id = 134
  subnets        = ["10.67.134.64/24"]
}

resource "nsxt_policy_bgp_neighbor" "t0_pod03_vrf04_bgp_neighbor_core_1_int_vlan134" {
  display_name     = "core-1-int-vlan134"
  description      = "Terraform provisioned BGP neighbor configuration"
  bgp_path         = nsxt_policy_tier0_gateway.t0_pod03_vrf04.bgp_config.0.path
  neighbor_address = "10.67.134.252"
  remote_as_num    = "65001"
}

resource "nsxt_policy_bgp_neighbor" "t0_pod03_vrf04_bgp_neighbor_core_2_int_vlan134" {
  display_name     = "core-2-int-vlan134"
  description      = "Terraform provisioned BGP neighbor configuration"
  bgp_path         = nsxt_policy_tier0_gateway.t0_pod03_vrf04.bgp_config.0.path
  neighbor_address = "10.67.134.253"
  remote_as_num    = "65001"
}