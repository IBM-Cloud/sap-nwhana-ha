data "ibm_is_vpc" "vpc" {
  name		= var.VPC
}

data "ibm_is_placement_group" "pg" {
  name = var.PLACEMENT_GROUP
}

data "ibm_is_security_group" "securitygroup" {
  name		= var.SECURITY_GROUP
}

data "ibm_is_subnet" "subnet" {
  name		= var.SUBNET
}

data "ibm_is_image" "image" {
  name		= var.IMAGE
}

data "ibm_resource_group" "group" {
  name		= var.RESOURCE_GROUP
}

resource "ibm_is_instance" "vsi" {
  tags = [ "wes-sap-automation" ]
  vpc		= data.ibm_is_vpc.vpc.id
  zone		= var.ZONE
  resource_group = data.ibm_resource_group.group.id
  placement_group = data.ibm_is_placement_group.pg.id
  keys		= var.SSH_KEYS
  name		=  var.APP-HOSTNAME != "${var.INPUT-DEFAULT-HOSTNAME}" ? var.APP-HOSTNAME : var.FINAL-DEFAULT-HOSTNAME
  profile	= var.PROFILE
  image		= data.ibm_is_image.image.id
  primary_network_interface {
    subnet          = data.ibm_is_subnet.subnet.id
    security_groups = [data.ibm_is_security_group.securitygroup.id]
  }
  volumes = ibm_is_volume.vol[*].id
}
