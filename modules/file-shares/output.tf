/**
#################################################################################################################
*                                 File Share Module Output Variable Section
#################################################################################################################
**/

## Creating ansible file share vars.
resource "local_file" "file_share-vars" {
  depends_on = [ data.ibm_is_share_mount_target.data_mount_target_sap_fs ]
  file_permission = "0644"
  content = <<-DOC
 ${var.ansible_var_name}_share_name: "${local.share_name}"
 ${var.ansible_var_name}_mount_path: "${data.ibm_is_share_mount_target.data_mount_target_sap_fs.mount_path}"
    DOC
  filename = "ansible/fileshare_${local.share_name}.yml"
}