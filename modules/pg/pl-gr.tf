data "ibm_resource_group" "group" {
  name		= var.RESOURCE_GROUP
}

resource "ibm_is_placement_group" "sapha-pg" {
  strategy = "power_spread"
  name     = lower ("sapha-${var.SAP_SID}")
  resource_group = data.ibm_resource_group.group.id
}
