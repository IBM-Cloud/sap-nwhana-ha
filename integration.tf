
#############################################################
# Export Terraform variable values to an Ansible var_file.
#############################################################

#### HA Infra variables.

resource "local_file" "ha_ansible_infra-vars" {
  depends_on = [ module.db-vsi ]
  content = <<-DOC
---
# Ansible vars_file containing variable values passed from Terraform.
# Generated by "terraform plan&apply" command.

# INFRA variables
api_key: "${var.IBMCLOUD_API_KEY}"
region: "${var.REGION}"
ha_password: ${base64encode(var.HA_PASSWORD)}

hdb_iphost1: "${data.ibm_is_instance.db-vsi-1.primary_network_interface[0].primary_ip[0].address}"
hdb_iphost2: "${data.ibm_is_instance.db-vsi-2.primary_network_interface[0].primary_ip[0].address}"
hdb_hostname1: "${data.ibm_is_instance.db-vsi-1.name}"
hdb_hostname2: "${data.ibm_is_instance.db-vsi-2.name}"

app_iphost1: "${data.ibm_is_instance.app-vsi-1.primary_network_interface[0].primary_ip[0].address}"
app_iphost2: "${data.ibm_is_instance.app-vsi-2.primary_network_interface[0].primary_ip[0].address}"
app_hostname1: "${data.ibm_is_instance.app-vsi-1.name}"
app_hostname2: "${data.ibm_is_instance.app-vsi-2.name}"

app_instanceid1: "${data.ibm_is_instance.app-vsi-1.id}"
app_instanceid2: "${data.ibm_is_instance.app-vsi-2.id}"
hdb_instanceid1: "${data.ibm_is_instance.db-vsi-1.id}"
hdb_instanceid2: "${data.ibm_is_instance.db-vsi-2.id}"

alb_ascs_hostname: "${data.ibm_is_lb.alb-ascs.hostname}"
alb_ers_hostname: "${data.ibm_is_lb.alb-ers.hostname}"
alb_hana_hostname: "${data.ibm_is_lb.alb-hana.hostname}"
...
    DOC
  filename = "ansible/hainfra-vars.yml"
}


#### Ansible inventory.

resource "local_file" "ansible_inventory" {
  depends_on = [ module.db-vsi ]
  content = <<-DOC
all:
  hosts:
    hdb_iphost1:
      ansible_host: "${data.ibm_is_instance.db-vsi-1.primary_network_interface[0].primary_ip[0].address}"
    hdb_iphost2:
      ansible_host: "${data.ibm_is_instance.db-vsi-2.primary_network_interface[0].primary_ip[0].address}"
    app_iphost1:
      ansible_host: "${data.ibm_is_instance.app-vsi-1.primary_network_interface[0].primary_ip[0].address}"
    app_iphost2:
      ansible_host: "${data.ibm_is_instance.app-vsi-2.primary_network_interface[0].primary_ip[0].address}"
    DOC
  filename = "ansible/inventory.yml"
}

#### SAP-APP variables.

resource "local_file" "app_ansible_sapnwapp-vars" {
  depends_on = [ module.db-vsi ]
  content = <<-DOC
---
# Ansible vars_file containing variable values passed from Terraform.
# Generated by "terraform plan&apply" command.

# SAP system configuration
swap_disk_size: "${distinct([ for stg in module.app-vsi : stg.SWAP_DISK_SIZE ])[0]}"
app_profile: "${var.APP_PROFILE}"
sap_sid: "${var.SAP_SID}"
sap_ascs_instance_number: "${var.SAP_ASCS_INSTANCE_NUMBER}"
sap_ers_instance_number: "${var.SAP_ERS_INSTANCE_NUMBER}"
sap_ci_instance_number: "${var.SAP_CI_INSTANCE_NUMBER}"
sap_aas_instance_number: "${var.SAP_AAS_INSTANCE_NUMBER}"
sap_main_password: ${base64encode(var.SAP_MAIN_PASSWORD)}

hdb_concurrent_jobs: "${var.HDB_CONCURRENT_JOBS}"
hana_tenant: "${var.HANA_TENANT}"

# SAP S/4HANA APP Installation kit path
kit_sapcar_file: "${var.KIT_SAPCAR_FILE}"
kit_swpm_file: "${var.KIT_SWPM_FILE}"
kit_sapexe_file: "${var.KIT_SAPEXE_FILE}"
kit_sapexedb_file: "${var.KIT_SAPEXEDB_FILE}"
kit_igsexe_file: "${var.KIT_IGSEXE_FILE}"
kit_igshelper_file: "${var.KIT_IGSHELPER_FILE}"
kit_saphostagent_file: "${var.KIT_SAPHOSTAGENT_FILE}"
kit_hdbclient_file: "${var.KIT_HDBCLIENT_FILE}"
kit_nwabap_export_file: "${var.KIT_NWABAP_EXPORT_FILE}"
...
    DOC
  filename = "ansible/nwabapapp-vars.yml"
}

#### HANADB variables.

resource "local_file" "db_ansible_saphana-vars" {
  depends_on = [ module.db-vsi ]
  content = <<-DOC
---
# Ansible vars_file containing variable values passed from Terraform.
# Generated by "terraform plan&apply" command.
hana_profile: "${var.DB_PROFILE}"

# HANA DB configuration
hana_sid: "${var.HANA_SID}"
hana_sysno: "${var.HANA_SYSNO}"
hana_tenant: "${var.HANA_TENANT}"
hana_main_password: ${base64encode(var.HANA_MAIN_PASSWORD)}
hana_system_usage: "${var.HANA_SYSTEM_USAGE}"
hana_components: "${var.HANA_COMPONENTS}"

# SAP HANA Installation kit path
kit_saphana_file: "${var.KIT_SAPHANA_FILE}"
...
    DOC
  filename = "ansible/saphana-vars.yml"
}

#### Integrate all variables for sap file shares in one.

resource "null_resource" "file_shares_ansible_vars" {
  depends_on = [module.file-shares]

  provisioner "local-exec" {
    working_dir = "ansible"
    command = <<EOF
    echo -e "---\n`cat fileshare_*`\n...\n" > fileshares-vars.yml; rm -rf fileshare_*; echo done
      EOF
      }
}

# Export Terraform variable values to an Ansible var_file
resource "local_file" "tf_ansible_hana_storage_generated_file" {
  depends_on = [ module.db-vsi ]
  source = "${path.root}/modules/db-vsi/files/hana_vm_volume_layout.json"
  filename = "ansible/hana_vm_volume_layout.json"
}

# Export Terraform variable values to an Ansible var_file for APP Server
resource "local_file" "tf_ansible_vars_generated_file_app" {
  source = "${path.root}/modules/app-vsi/files/sapapp_vm_volume_layout.json"
  filename = "ansible/sapapp_vm_volume_layout.json"
}
