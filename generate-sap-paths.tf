# List SAP PATHS
resource "local_file" "KIT_SAP_PATHS" {
  content = <<-DOC
${var.KIT_SAPHANA_FILE}
${var.KIT_SAPCAR_FILE}
${var.KIT_SWPM_FILE}
${var.KIT_SAPEXE_FILE}
${var.KIT_SAPEXEDB_FILE}
${var.KIT_IGSEXE_FILE}
${var.KIT_IGSHELPER_FILE}
${var.KIT_SAPHOSTAGENT_FILE}
${var.KIT_HDBCLIENT_FILE}
${var.KIT_NWABAP_EXPORT_FILE}
    DOC
  filename = "modules/precheck-ssh-exec/sap-paths-${var.DB_HOSTNAME_1 != "hanadb-1" ? var.DB_HOSTNAME_1 : lower ("${local.DB_HOSTNAME_1}")}"
}
