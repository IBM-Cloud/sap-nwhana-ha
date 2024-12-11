########################### File Share Creation
##################################################

resource "ibm_is_share" "sap_fs" {
    access_control_mode = "security_group"
    zone    = var.zone
    resource_group = var.resource_group_id 
    size    = var.share_size
    name    = local.share_name
    profile = var.share_profile
}

resource "ibm_is_share_mount_target" "mount_target_sap_fs" {
  share = ibm_is_share.sap_fs.id
  virtual_network_interface {
    subnet = var.subnet_id
    name = local.share_name
    security_groups = ["${var.security_group_id}"]
    resource_group = var.resource_group_id
  }
  name  = local.share_name
}

data "ibm_is_share_mount_target" "data_mount_target_sap_fs" {
  depends_on = [ ibm_is_share_mount_target.mount_target_sap_fs ]
  share        = ibm_is_share.sap_fs.id
  mount_target = ibm_is_share_mount_target.mount_target_sap_fs.mount_target
}