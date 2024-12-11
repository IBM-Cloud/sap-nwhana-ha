data "ibm_is_vpc" "vpc" {
  name		= var.VPC
}

data "ibm_is_security_group" "securitygroup" {
  name		= var.SECURITY_GROUP
}

data "ibm_resource_group" "group" {
  name		= var.RESOURCE_GROUP
}

data "ibm_is_lb" "sap-alb" {
  name    = lower ("${var.SAP_ALB_NAME}-${var.SAP_SID}")
}

variable "SAP-PRIVATE-IP-VSI1" {
    type = string
    description = "SAP-PRIVATE-IP-VSI1"
}

variable "SAP-PRIVATE-IP-VSI2" {
    type = string
    description = "SAP-PRIVATE-IP-VSI2"
}


variable "SAP_SID" {
    type = string
    description = "SAP SID"
}

#ascsno
variable "SAP_ASCS" {
    type = string
    description = "SAP_ASCS"
}

#ersno
variable "SAP_ERSNO" {
    type = string
    description = "SAP_ERSNO"
}

#hanano
variable "HANA_SYSNO" {
    type = string
    description = "HANA_SYSNO"
}

variable "SAP_ALB_NAME" {
    type = string
    description = "ASCS NAME"
}

variable "SAP_HEALTH_MONITOR_PORT_PREFIX" {
    type = string
    description = "SAP_HEALTH_MONITOR_PORT_PREFIX"
}

variable "SAP_HEALTH_MONITOR_PORT_POSTFIX" {
    type = string
    description = "SAP_HEALTH_MONITOR_PORT_PREFIX"
}

variable "SAP_BACKEND_POOL_NAME" {
    type = string
    description = "SAP_BACKEND_POOL_NAME"
}

variable "SAP_PORT_LB" {
    type = string
    description = "SAP_PORT_LB"
}

resource "ibm_is_lb_pool" "sap-backend" {
  lb             = data.ibm_is_lb.sap-alb.id
  name           = "${var.SAP_BACKEND_POOL_NAME}"
  algorithm      = "least_connections"
  protocol       = "tcp"
  health_delay   = 4
  health_retries = 5
  health_timeout = 3
  health_type    = "tcp"
  proxy_protocol = "disabled"
  health_monitor_port = "${var.SAP_HEALTH_MONITOR_PORT_PREFIX}${var.SAP_HEALTH_MONITOR_PORT_POSTFIX}"
}

resource "ibm_is_lb_pool_member" "vsi-1" {
  depends_on = [ ibm_is_lb_pool.sap-backend]

  lb             = data.ibm_is_lb.sap-alb.id
  pool           = ibm_is_lb_pool.sap-backend.id
  port           = "${var.SAP_PORT_LB}"
  target_address = "${var.SAP-PRIVATE-IP-VSI1}"
}

resource "ibm_is_lb_pool_member" "vsi-2" {
  depends_on = [ ibm_is_lb_pool_member.vsi-1 ]
  lb             = data.ibm_is_lb.sap-alb.id
  pool           = ibm_is_lb_pool.sap-backend.id
  port           = "${var.SAP_PORT_LB}"
  target_address = "${var.SAP-PRIVATE-IP-VSI2}"
}

resource "ibm_is_lb_listener" "sap-frontend" {
  depends_on = [ ibm_is_lb_pool_member.vsi-2 ]
  lb           = data.ibm_is_lb.sap-alb.id
  protocol     = "tcp"
  port         = "${var.SAP_PORT_LB}"
  default_pool = ibm_is_lb_pool.sap-backend.pool_id
  idle_connection_timeout = 300
}
