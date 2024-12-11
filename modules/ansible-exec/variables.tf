variable "PLAYBOOK" {
    type = string
    description = "Path to the Ansible Playbook"
}

variable "BASTION_FLOATING_IP" {
    type = string
    description = "IP used to execute the remote script"
}

variable "IP" {
    type = string
    description = "IP used by ansible"
}

variable "private_ssh_key" {
    type = string
    description = "Private ssh key"
}

variable "ID_RSA_FILE_PATH" {
    nullable = false
    description = "Input your id_rsa private key file path in OpenSSH format."
}

# Developer settings:
locals {

SAP_DEPLOYMENT = "sap_nw_abap_hana_ha"
SCHEMATICS_TIMEOUT = 55         #(Max 55 Minutes). It is multiplied by 7 on Schematics deployments and it is relying on the ansible-logs number.

}
