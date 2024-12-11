output "HANA_DB_PRIVATE_IP_VSI1" {
  value		= "${data.ibm_is_instance.db-vsi-1.primary_network_interface[0].primary_ip[0].address}"
}

output "HANA_DB_PRIVATE_IP_VSI2" {
  value		= "${data.ibm_is_instance.db-vsi-2.primary_network_interface[0].primary_ip[0].address}"
}

output "HANA_STORAGE_LAYOUT" {
  value = distinct([
    for stg in module.db-vsi : stg.STORAGE-LAYOUT
  ])[0]
}

output "SAP_APP_PRIVATE_IP_VSI1" {
  value		= "${data.ibm_is_instance.app-vsi-1.primary_network_interface[0].primary_ip[0].address}"
}

output "SAP_APP_PRIVATE_IP_VSI2" {
  value		= "${data.ibm_is_instance.app-vsi-2.primary_network_interface[0].primary_ip[0].address}"
}

output "APP_STORAGE_LAYOUT" {
  value = distinct([
    for stg in module.app-vsi : stg.STORAGE-LAYOUT
  ])[0]
}

output "DOMAIN_NAME" {
  value = var.DOMAIN_NAME
}

output FQDN_ALB_ASCS {
 value		= "${data.ibm_is_lb.alb-ascs.hostname}" 
}

output FQDN_LB_ERS {
 value		= "${data.ibm_is_lb.alb-ers.hostname}"
}

output FQDN_ALB_HANA {
 value		= "${data.ibm_is_lb.alb-hana.hostname}"
}