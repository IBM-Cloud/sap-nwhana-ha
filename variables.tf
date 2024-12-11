############################################################
# The variables and data sources used in VPC infra Modules. 
############################################################

variable "PRIVATE_SSH_KEY" {
	type		= string
	description = "id_rsa private key content in OpenSSH format (Sensitive value). This private key should be used only during the terraform provisioning and it is recommended to be changed after the SAP deployment."
	nullable = false
	validation {
	condition = length(var.PRIVATE_SSH_KEY) >= 64 && var.PRIVATE_SSH_KEY != null && length(var.PRIVATE_SSH_KEY) != 0 || contains(["n.a"], var.PRIVATE_SSH_KEY )
	error_message = "The content for private_ssh_key variable must be in OpenSSH format."
    }
}

variable "ID_RSA_FILE_PATH" {
    default = "ansible/id_rsa"
    nullable = false
    description = "File path for PRIVATE_SSH_KEY. It will be automatically generated. If it is changed, it must contain the relative path from git repo folders. Example: ansible/id_rsa_ha"
}

variable "SSH_KEYS" {
	type		= list(string)
	description = "List of SSH Keys UUIDs that are allowed to connect via SSH, as root, to the VSI. Can contain one or more IDs. The list of SSH Keys is available here: https://cloud.ibm.com/vpc-ext/compute/sshKeys."
	validation {
		condition     = var.SSH_KEYS == [] ? false : true && var.SSH_KEYS == [""] ? false : true
		error_message = "At least one SSH KEY is needed to be able to access the VSI."
	}
}

variable "BASTION_FLOATING_IP" {
	type		= string
	description = "The BASTION FLOATING IP. It can be found at the end of the Bastion Server deployment log, in \"Outputs\", before \"Command finished successfully\" message. "
	nullable = false
	validation {
        condition = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",var.BASTION_FLOATING_IP)) || contains(["localhost"], var.BASTION_FLOATING_IP ) && var.BASTION_FLOATING_IP!= null
        error_message = "Incorrect format for variable: BASTION_FLOATING_IP."
      }
}

variable "RESOURCE_GROUP" {
  type        = string
  description = "The name of an EXISTING Resource Group. The list of Resource Groups is available here: https://cloud.ibm.com/account/resource-groups"
  default     = "Default"
}

variable "REGION" {
	type		= string
	description	= "The cloud region where to deploy the solution. The regions and zones for VPC are available here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. Supported locations in IBM Cloud Schematics: https://cloud.ibm.com/docs/schematics?topic=schematics-locations."
	validation {
		condition     = contains(["eu-de", "eu-gb", "us-south", "us-east", "ca-tor", "au-syd", "jp-osa", "jp-tok", "eu-es", "br-sao"], var.REGION )
		error_message = "The REGION must be one of: eu-de, eu-gb, us-south, us-east, ca-tor, au-syd, jp-osa, jp-tok, eu-es, br-sao."
	}
}

variable "VPC" {
	type		= string
	description = "The name of an EXISTING VPC. Must be in the same region as the solution to be deployed. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.VPC)) > 0
		error_message = "The VPC name is not valid."
	}
}

variable "ZONE_1" {
	type		= string
	description	= "Availability zone for DB_HOSTNAME_1 and APP_HOSTNAME_1 VSIs, in the same VPC. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc"
	validation {
		condition     = length(regexall("^(eu-de|eu-gb|us-south|us-east|ca-tor|au-syd|jp-osa|jp-tok|eu-es|br-sao)-(1|2|3)$", var.ZONE_1)) > 0
		error_message = "The ZONE is not valid."
	}
}

variable "SUBNET_1" {
	type		= string
	description = "The name of an EXISTING Subnet, in the same VPC, ZONE_1, where DB_HOSTNAME_1 and APP_HOSTNAME_1 VSIs will be created. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets"
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SUBNET_1)) > 0
		error_message = "The SUBNET name is not valid."
	}
}

variable "ZONE_2" {
	type		= string
	description	= "Availability zone for DB_HOSTNAME_2 and APP_HOSTNAME_2 VSIs, in the same VPC. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. If the same value as for ZONE_1 is used, and the value for SUBNET_1 is the same with the value for SUBNET_2, the deployment will be done in a single zone. If the values for ZONE_1, SUBNET_1 are different than the ones for ZONE_2, SUBNET_2 then an SAP Multizone deployment will be done."
	validation {
		condition     = length(regexall("^(eu-de|eu-gb|us-south|us-east|ca-tor|au-syd|jp-osa|jp-tok|eu-es|br-sao)-(1|2|3)$", var.ZONE_2)) > 0
		error_message = "The ZONE is not valid."
	}
}

variable "SUBNET_2" {
	type		= string
	description = "The name of an EXISTING Subnet, in the same VPC, ZONE_2, where DB_HOSTNAME_2 and APP_HOSTNAME_2 VSIs will be created. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets. If the same value as for SUBNET_1 is used, and the value for ZONE_1 is the same with the value for ZONE_2, the deployment will be done in a single zone. If the values for ZONE_1, SUBNET_1 are different than the ones for ZONE_2, SUBNET_2 then it an SAP Multizone deployment will be done."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SUBNET_2)) > 0
		error_message = "The SUBNET name is not valid."
	}
}

variable "SECURITY_GROUP" {
	type		= string
	description = "The name of an EXISTING Security group for the same VPC. It can be found at the end of the Bastion Server deployment log, in \"Outputs\", before \"Command finished successfully\" message. The list of Security Groups is available here: https://cloud.ibm.com/vpc-ext/network/securityGroups."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SECURITY_GROUP)) > 0
		error_message = "The SECURITY_GROUP name is not valid."
	}
}

variable "DOMAIN_NAME" {
	type		= string
	description	= "The Domain Name used for DNS and ALB. Duplicates are not allowed. The list with DNS resources can be found here: https://cloud.ibm.com/resources."
	nullable = false
	default = "ha.mzexample.com"
	validation {
		condition     =  length(var.DOMAIN_NAME) > 2  && length (regex("^[a-z]*||^[0-9]*||\\.||\\-", var.DOMAIN_NAME)) > 0  && length (regex("[\\.]", var.DOMAIN_NAME)) > 0  && length (regexall("[\\&]|[\\%]|[\\!]|[\\@]|[\\#]|[\\*]|[\\^]", var.DOMAIN_NAME)) == 0
		error_message = "The DOMAIN_NAME variable should not be empty and must contain at least one \".\" as a separator and no special chars are allowed."
	}
}

locals {
	ASCS_VIRT_HOSTNAME = "sap${var.SAP_SID}ascs"
	ERS_VIRT_HOSTNAME = "sap${var.SAP_SID}ers"
	HANA_VIRT_HOSTNAME = "db${var.HANA_SID}hana"
}

variable "ASCS_VIRT_HOSTNAME" {
	type		= string
	description	= "ASCS Virtual hostname. Obs: When the default value is used, the virtual hostname will automatically be changed based on <SAP_SID> to \"sap<sap_sid>ascs\"."
	nullable = false
	default = "sapascs"
	validation {
		condition     =  length(var.ASCS_VIRT_HOSTNAME) > 2  && length (regex("^[a-z]*||^[0-9]*", var.ASCS_VIRT_HOSTNAME)) > 0  && length (regexall("[\\&]|[\\%]|[\\!]|[\\@]|[\\#]|[\\*]|[\\^]", var.ASCS_VIRT_HOSTNAME)) == 0
		error_message = "The ASCS_VIRT_HOSTNAME variable should not be empty and no special chars are allowed."
	}
}

output VIRT_HOSTNAME_ASCS {
  value = var.ASCS_VIRT_HOSTNAME != "sapascs" ? var.ASCS_VIRT_HOSTNAME : lower ("${local.ASCS_VIRT_HOSTNAME}")
}

variable "ERS_VIRT_HOSTNAME" {
	type		= string
	description	= "ERS Virtual hostname. Obs: When the default value is used, the virtual hostname will automatically be changed based on <SAP_SID> to \"sap<sap_sid>ers\""
	nullable = false
	default = "sapers"
	validation {
		condition     =  length(var.ERS_VIRT_HOSTNAME) > 2  && length (regex("^[a-z]*||^[0-9]*", var.ERS_VIRT_HOSTNAME)) > 0 && length (regexall("[\\&]|[\\%]|[\\!]|[\\@]|[\\#]|[\\*]|[\\^]", var.ERS_VIRT_HOSTNAME)) == 0
		error_message = "The ERS_VIRT_HOSTNAME variable should not be empty and no special chars are allowed."
	}
}

output VIRT_HOSTNAME_ERS {
  value = var.ERS_VIRT_HOSTNAME != "sapers" ? var.ERS_VIRT_HOSTNAME : lower ("${local.ERS_VIRT_HOSTNAME}")
}

variable "HANA_VIRT_HOSTNAME" {
	type		= string
	description	= "HANA Virtual hostname. Obs: When the default value is used, the virtual hostname will automatically be changed based on <HANA_SID> to \"db<hana_sid>hana\""
	nullable = false
	default = "dbhana"
	validation {
		condition     =  length(var.HANA_VIRT_HOSTNAME) > 2  && length (regex("^[a-z]*||^[0-9]*", var.HANA_VIRT_HOSTNAME)) > 0  && length (regexall("[\\&]|[\\%]|[\\!]|[\\@]|[\\#]|[\\*]|[\\^]", var.HANA_VIRT_HOSTNAME)) == 0
		error_message = "The HANA_VIRT_HOSTNAME variable should not be empty and no special chars are allowed."
	}
}

output VIRT_HOSTNAME_HANA {
  value = var.HANA_VIRT_HOSTNAME != "dbhana" ? var.HANA_VIRT_HOSTNAME : lower ("${local.HANA_VIRT_HOSTNAME}")
}

locals {
	DB_HOSTNAME_1 = "hanadb-${var.HANA_SID}-1"
	DB_HOSTNAME_2 = "hanadb-${var.HANA_SID}-2"
	APP_HOSTNAME_1 = "sapapp-${var.SAP_SID}-1"
	APP_HOSTNAME_2 = "sapapp-${var.SAP_SID}-2"
	
}

variable "DB_PROFILE" {
	type		= string
	description = "DB VSI Profile. The certified profiles for SAP HANA in IBM VPC: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc"
	default		= "mx2-16x128"
	validation {
		condition     = contains(keys(jsondecode(file("modules/db-vsi/files/hana_vm_volume_layout.json")).profiles), "${var.DB_PROFILE}")
		error_message = "The chosen storage PROFILE for HANA VSI \"${var.DB_PROFILE}\" is not a certified storage profile. Please, chose the appropriate certified storage PROFILE for the HANA VSI from  https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc . Make sure the selected PROFILE is certified for the selected OS type and for the proceesing type (SAP Business One, OLTP, OLAP)"
	}
}

variable "DB_IMAGE" {
	type		= string
	description = "The OS image for the HANA VSI. You must use the Red Hat Enterprise Linux 8 for SAP HANA (amd64) image for all VMs as this image contains the required SAP and HA subscriptions. A list of images is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images."
	default		= "ibm-redhat-8-6-amd64-sap-hana-6"
}

variable "DB_HOSTNAME_1" {
	type		= string
	description = "HANA DB VSI HOSTNAME 1 in SAP HANA Cluster. The hostname should be up to 13 characters. Obs: When the default value is used, the virtual hostname will automatically be changed based on <HANA_SID> to \"hanadb-<hana_sid>-1\""
	default = "hanadb-1"
	validation {
		condition     = length(var.DB_HOSTNAME_1) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.DB_HOSTNAME_1)) > 0
		error_message = "The DB_HOSTNAME is not valid."
	}
}

output HANA_DB_HOSTNAME_VSI1 {
  value = var.DB_HOSTNAME_1 != "hanadb-1" ? var.DB_HOSTNAME_1 : lower ("${local.DB_HOSTNAME_1}")
}

variable "DB_HOSTNAME_2" {
	type		= string
	description = "HANA DB VSI HOSTNAME 2 in SAP HANA Cluster. The hostname should be up to 13 characters. Obs: When the default value is used, the virtual hostname will automatically be changed based on <HANA_SID> to \"hanadb-<hana_sid>-2\""
	default = "hanadb-2"
	nullable = true
	validation {
		condition     = length(var.DB_HOSTNAME_2) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.DB_HOSTNAME_2)) > 0
		error_message = "The DB_HOSTNAME is not valid."
	}
}

output HANA_DB_HOSTNAME_VSI2 {
  value = var.DB_HOSTNAME_2 != "hanadb-2" ? var.DB_HOSTNAME_2 : lower ("${local.DB_HOSTNAME_2}")
}

variable "APP_PROFILE" {
	type		= string
	description = "The profile for the APP VSI. A list of profiles is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles. For more information, check SAP Note 2927211: \"SAP Applications on IBM Virtual Private Cloud\"."
	default		= "bx2-4x16"
}

variable "APP_IMAGE" {
	type		= string
	description = "The OS image for the APP VSI. You must use the Red Hat Enterprise Linux 8 for SAP HANA (amd64) image for all VMs as this image contains the required SAP and HA subscriptions. A list of images is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images."
	default		= "ibm-redhat-8-6-amd64-sap-hana-6"
}

variable "APP_HOSTNAME_1" {
	type		= string
	description = "APP VSI HOSTNAME 1 in SAP APP Cluster. The hostname should be up to 13 characters. Obs: When the default value is used, the virtual hostname will automatically be changed based on <SAP_SID> to \"sapapp-<sap_sid>-1\""
	default = "sapapp-1"
	validation {
		condition     = length(var.APP_HOSTNAME_1) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.APP_HOSTNAME_1)) > 0
		error_message = "The APP_HOSTNAME is not valid."
	}
}

output SAP_APP_HOSTNAME_VSI1 {
  value = var.APP_HOSTNAME_1 != "sapapp-1" ? var.APP_HOSTNAME_1 : lower ("${local.APP_HOSTNAME_1}")
}

variable "APP_HOSTNAME_2" {
	type		= string
	description = "APP VSI HOSTNAME 2 in SAP APP Cluster. The hostname should be up to 13 characters. Obs: When the default value is used, the virtual hostname will automatically be changed based on <SAP_SID> to \"sapapp-<sap_sid>-2\""
	default = "sapapp-2"
	nullable = true
	validation {
		condition     = length(var.APP_HOSTNAME_2) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.APP_HOSTNAME_2)) > 0
		error_message = "The APP_HOSTNAME is not valid."
	}
}

output SAP_APP_HOSTNAME_VSI2 {
  value = var.APP_HOSTNAME_2 != "sapapp-2" ? var.APP_HOSTNAME_2 : lower ("${local.APP_HOSTNAME_2}")
}

locals {
  SAP-ALB-ASCS = "sap-alb-ascs"
  SAP-ALB-ERS = "sap-alb-ers"
  DB-ALB-HANA = "db-alb-hana"
}

data "ibm_is_lb" "alb-ascs" {
  depends_on = [module.alb-prereq]
  name    = lower ("${local.SAP-ALB-ASCS}-${var.SAP_SID}")
}

data "ibm_is_lb" "alb-ers" {
  depends_on = [module.alb-prereq]
  name    = lower ("${local.SAP-ALB-ERS}-${var.SAP_SID}")
}

data "ibm_is_lb" "alb-hana" {
  depends_on = [module.alb-prereq]
  name    = lower ("${local.DB-ALB-HANA}-${var.HANA_SID}")
}

data "ibm_is_instance" "app-vsi-1" {
  depends_on = [module.app-vsi]
  name    =  var.APP_HOSTNAME_1 != "sapapp-1" ? var.APP_HOSTNAME_1 : lower ("${local.APP_HOSTNAME_1}")
}

data "ibm_is_instance" "app-vsi-2" {
  depends_on = [module.app-vsi]
  name    = var.APP_HOSTNAME_2 != "sapapp-2" ? var.APP_HOSTNAME_2 : lower ("${local.APP_HOSTNAME_2}")
}

data "ibm_is_instance" "db-vsi-1" {
  depends_on = [module.db-vsi]
  name    =  var.DB_HOSTNAME_1 != "hanadb-1" ? var.DB_HOSTNAME_1 : lower ("${local.DB_HOSTNAME_1}")
}

data "ibm_is_instance" "db-vsi-2" {
  depends_on = [module.db-vsi]
  name    = var.DB_HOSTNAME_2 != "hanadb-2" ? var.DB_HOSTNAME_2 : lower ("${local.DB_HOSTNAME_2}")
}

############################################################
# The variables and data sources used in File_Share Module. 
############################################################

data "ibm_is_vpc" "vpc" {
  name		= var.VPC
}

data "ibm_resource_group" "group" {
  name		= var.RESOURCE_GROUP
}

data "ibm_is_subnet" "subnet_id" {
  name		=	var.SUBNET_1
}

data "ibm_is_security_group" "security_group_id" {
  name = var.SECURITY_GROUP
}

variable "SHARE_PROFILE" {
  description = "The Storage Profile for the File Share. For more details see: https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#dp2-profile."
  type        = string
  default     = "dp2"
}

variable "USRSAP_AS1" {
  description = "File Share Size for USRSAP_AS1, in GB"
  type        = number
  default = 20
}

variable "USRSAP_AS2" {
  description = "File Share Size for USRSAP_AS2, in GB"
  type        = number
  default = 20
}

variable "USRSAP_SAPASCS" {
  description = "File Share Size for USRSAP_SAPASCS, in GB"
  type        = number
  default = 20
}

variable "USRSAP_SAPERS" {
  description = "File Share Size for USRSAP_SAPERS, in GB"
  type        = number
  default = 20
}

variable "USRSAP_SAPMNT" {
  description = "File Share Size for USRSAP_SAPMNT, in GB"
  type        = number
  default = 20
}

variable "USRSAP_SAPSYS" {
  description = "File Share Size for USRSAP_SAPSYS, in GB"
  type        = number
  default = 20
}

variable "USRSAP_TRANS" {
  description = "File Share Size for USRSAP_TRANS, in GB"
  type        = number
  default = 80
}

##############################################################
# The variables and data sources used in SAP Ansible Modules.
##############################################################

variable "HANA_SID" {
	type		= string
	description = "The SAP system ID identifies the SAP HANA system. Consists of three alphanumeric characters and the first character must be a letter. Does not include any of the reserved IDs listed in SAP Note 1979280"
	default		= "HDB"
	validation {
		condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.HANA_SID)) > 0  && !contains(["ADD", "ALL", "AMD", "AND", "ANY", "ARE", "ASC", "AUX", "AVG", "BIT", "CDC", "COM", "CON", "DBA", "END", "EPS", "FOR", "GET", "GID", "IBM", "INT", "KEY", "LOG", "LPT", "MAP", "MAX", "MIN", "MON", "NIX", "NOT", "NUL", "OFF", "OLD", "OMS", "OUT", "PAD", "PRN", "RAW", "REF", "ROW", "SAP", "SET", "SGA", "SHG", "SID", "SQL", "SUM", "SYS", "TMP", "TOP", "UID", "USE", "USR", "VAR"], var.HANA_SID)
		error_message = "The HANA_SID is not valid."
	}
}

variable "HANA_TENANT" {
	type		= string
	description = "The name of the SAP HANA tenant."
	default		= "NWA"
	validation {
		condition     = length(regexall("^[A-Za-z0-9-_]+$", var.HANA_TENANT)) > 0  && !contains(["ADD", "ALL", "AMD", "AND", "ANY", "ARE", "ASC", "AUX", "AVG", "BIT", "CDC", "COM", "CON", "DBA", "END", "EPS", "FOR", "GET", "GID", "IBM", "INT", "KEY", "LOG", "LPT", "MAP", "MAX", "MIN", "MON", "NIX", "NOT", "NUL", "OFF", "OLD", "OMS", "OUT", "PAD", "PRN", "RAW", "REF", "ROW", "SAP", "SET", "SGA", "SHG", "SID", "SQL", "SUM", "SYS", "TMP", "TOP", "UID", "USE", "USR", "VAR"], var.HANA_TENANT)
		error_message = "The name of SAP HANA tenant HANA_TENANT is not valid."
	}
}

variable "SAP_ASCS_INSTANCE_NUMBER" {
	type		= string
	description = "The central ABAP service instance number. Technical identifier for internal processes of ASCS. Consists of a two-digit number from 00 to 97. Must be unique on a host. Must follow the SAP rules for instance number naming."
	default		= "00"
	validation {
		condition     = var.SAP_ASCS_INSTANCE_NUMBER >= 0 && var.SAP_ASCS_INSTANCE_NUMBER <=97
		error_message = "The SAP_ASCS_INSTANCE_NUMBER is not valid."
	}
}

variable "SAP_ERS_INSTANCE_NUMBER" {
	type		= string
	description = "The enqueue replication server instance number. Technical identifier for internal processes of ERS. Consists of a two-digit number from 00 to 97. Must be unique on a host. Must follow the SAP rules for instance number naming."
	default		= "01"
	validation {
		condition     = var.SAP_ERS_INSTANCE_NUMBER >= 00 && var.SAP_ERS_INSTANCE_NUMBER <=99
		error_message = "The SAP_ERS_INSTANCE_NUMBER is not valid."
	}
}

variable "SAP_CI_INSTANCE_NUMBER" {
	type		= string
	description = "The SAP central instance number. Technical identifier for internal processes of PAS. Consists of a two-digit number from 00 to 97. Must be unique on a host. Must follow the SAP rules for instance number naming"
	default		= "10"
	validation {
		condition     = var.SAP_CI_INSTANCE_NUMBER >= 00 && var.SAP_CI_INSTANCE_NUMBER <=99
		error_message = "The SAP_CI_INSTANCE_NUMBER is not valid."
	}
}

variable "SAP_AAS_INSTANCE_NUMBER" {
	type		= string
	description = "The SAP additional application server instance number. Technical identifier for internal processes of AAS. Consists of a two-digit number from 00 to 97. Must be unique on a host. Must follow the SAP rules for instance number naming"
	default		= "20"
	validation {
		condition     = var.SAP_AAS_INSTANCE_NUMBER >= 00 && var.SAP_AAS_INSTANCE_NUMBER <=99
		error_message = "The SAP_AAS_INSTANCE_NUMBER is not valid."
	}
}

variable "HANA_SYSNO" {
	type		= string
	description = "The instance number of the SAP HANA system."
	default		= "00"
	validation {
		condition     = var.HANA_SYSNO >= 0 && var.HANA_SYSNO <=97
		error_message = "The HANA_SYSNO is not valid."
	}
}

variable "HANA_MAIN_PASSWORD" {
	type        = string
	sensitive   = true
	description = "The SAP HANA MAIN Password. It must be 15 to 30 characters long. It must contain at least: one digit (0-9), one lowercase letter (a-z), one uppercase letter (A-Z). It may contain one of the following special characters: !, #, _, @, $. It must start with a lowercase letter (a-z) or with an uppercase letter (A-Z)."
	validation {
		condition 		= length(var.HANA_MAIN_PASSWORD) >= 15 && length(var.HANA_MAIN_PASSWORD) <= 30 && length(regexall("[0-9]",  var.HANA_MAIN_PASSWORD)) > 0 && length(regexall("[a-z]",  var.HANA_MAIN_PASSWORD)) > 0 && length(regexall("[A-Z]",  var.HANA_MAIN_PASSWORD)) > 0 && can(regex("^[a-zA-Z0-9!#_@$]*$", var.HANA_MAIN_PASSWORD)) && length(regexall("^([a-z]|[A-Z])", var.HANA_MAIN_PASSWORD)) > 0
	  error_message 	= "The HANA_MAIN_PASSWORD is not valid. It must be 15 to 30 characters long. It must contain at least: one digit (0-9), one lowercase letter (a-z), one uppercase letter (A-Z). It may contain one of the following special characters: !, #, _, @, $. It must start with a lowercase letter (a-z) or with an uppercase letter (A-Z)."
	}
  }


variable "HANA_SYSTEM_USAGE" {
	type		= string
	description = "System Usage. Default: \"custom\". Valid values: \"production\", \"test\", \"development\", \"custom\"."
	default		= "custom"
	validation {
		condition		= contains(["production", "test", "development", "custom" ], var.HANA_SYSTEM_USAGE )
		error_message	= "The HANA_SYSTEM_USAGE must be one of: production, test, development, custom."
	}
}

variable "HANA_COMPONENTS" {
	type		= string
	description = "SAP HANA Components. Default: \"server\". Valid values: \"all\", \"client\", \"es\", \"ets\", \"lcapps\", \"server\", \"smartda\", \"streaming\", \"rdsync\", \"xs\", \"studio\", \"afl\", \"sca\", \"sop\", \"eml\", \"rme\", \"rtl\", \"trp\"."
	default		= "server"
	validation {
		condition     = contains(["all", "client", "es", "ets", "lcapps", "server", "smartda", "streaming", "rdsync", "xs", "studio", "afl", "sca", "sop", "eml", "rme", "rtl", "trp" ], var.HANA_COMPONENTS )
		error_message = "The HANA_COMPONENTS must be one of: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp."
	}
}

variable "KIT_SAPHANA_FILE" {
	type		= string
	description = "Path to SAP HANA ZIP file, as downloaded from SAP Support Portal."
	default		= "/storage/HANADB/SP07/Rev73/51057281.ZIP"
}

variable "SAP_SID" {
	type		= string
	description = "The SAP system ID identifies the entire SAP system. Consists of three alphanumeric characters and the first character must be a letter. Does not include any of the reserved IDs listed in SAP Note 1979280"
	default		= "NWA"
	validation {
		condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.SAP_SID)) > 0 && !contains(["ADD", "ALL", "AMD", "AND", "ANY", "ARE", "ASC", "AUX", "AVG", "BIT", "CDC", "COM", "CON", "DBA", "END", "EPS", "FOR", "GET", "GID", "IBM", "INT", "KEY", "LOG", "LPT", "MAP", "MAX", "MIN", "MON", "NIX", "NOT", "NUL", "OFF", "OLD", "OMS", "OUT", "PAD", "PRN", "RAW", "REF", "ROW", "SAP", "SET", "SGA", "SHG", "SID", "SQL", "SUM", "SYS", "TMP", "TOP", "UID", "USE", "USR", "VAR"], var.SAP_SID)
		error_message = "The SAP_SID is not valid."
	}
}

variable "SAP_MAIN_PASSWORD" {
	type		= string
	sensitive = true
	description = "The SAP MAIN Password. Common password for all users that are created during the installation. It must be 15 to 30 characters long. It must contain at least: one digit (0-9), one lowercase letter (a-z) and one uppercase letter (A-Z). It may contain one of the following special characters: !, #, $, &, , +, ,, -, ., /, :, =>, @, ^, _, |, ~. It must start with a lowercase letter (a-z) or with an uppercase letter (A-Z)."
	validation {
		condition = length(var.SAP_MAIN_PASSWORD) >= 15 && length(var.SAP_MAIN_PASSWORD) <= 30 && length(regexall("[0-9]",  var.SAP_MAIN_PASSWORD)) > 0 && length(regexall("[a-z]",  var.SAP_MAIN_PASSWORD)) > 0 && length(regexall("[A-Z]",  var.SAP_MAIN_PASSWORD)) > 0 && can(regex("^[a-zA-Z0-9!#$&*+,-./:=>@^_|~]*$", var.SAP_MAIN_PASSWORD)) && length(regexall("^([a-z]|[A-Z])", var.SAP_MAIN_PASSWORD)) > 0
		error_message = "The SAP_MAIN_PASSWORD is not valid. It must be 15 to 30 characters long. It must contain at least: one digit (0-9), one lowercase letter (a-z) and one uppercase letter (A-Z). It may contain one of the following special characters: !, #, $, &, , +, ,, -, ., /, :, =>, @, ^, _, |, ~. It must start with a lowercase letter (a-z) or with an uppercase letter (A-Z)."
	}
}

variable "HA_PASSWORD" {
	type		= string
	sensitive = true
	description = "The HA Cluster Password. It must be 15 to 30 characters long. It must contain at least: one digit (0-9), one lowercase letter (a-z), one uppercase letter (A-Z) and one of the following special characters: !, #, $, %, &, (, ), *, +, ,, -, ., /, :, =, >, @, [, ], ^, _, {, |, }, ~. It must start with a lowercase letter (a-z) or with an uppercase letter (A-Z)."
	validation {
		condition = length(var.HA_PASSWORD) >= 15 && length(var.HA_PASSWORD) <= 30 && length(regexall("[0-9]",  var.HA_PASSWORD)) > 0 && length(regexall("[a-z]",  var.HA_PASSWORD)) > 0 && length(regexall("[A-Z]",  var.HA_PASSWORD)) > 0 && can(regex("^[a-zA-Z0-9!#$%&()*+,-./:=>@\\[\\]^_{|}~]*$", var.HA_PASSWORD)) && can(regex("([!#$%&()*+,-./:=>@\\[\\]^_{|}])", var.HA_PASSWORD)) && length(regexall("^([a-z]|[A-Z])", var.HA_PASSWORD)) > 0
		error_message = "The HA_PASSWORD is not valid. It must be 15 to 30 characters long. It must contain at least: one digit (0-9), one lowercase letter (a-z), one uppercase letter (A-Z) and one of the following special characters: !, #, $, %, &, (, ), *, +, ,, -, ., /, :, =, >, @, [, ], ^, _, {, |, }, ~. It must start with a lowercase letter (a-z) or with an uppercase letter (A-Z)."
	}
}

variable "HDB_CONCURRENT_JOBS" {
	type		= string
	description = "Number of concurrent jobs used to load and/or extract archives to HANA Host."
	default		= "23"
	validation {
		condition     = var.HDB_CONCURRENT_JOBS >= 1 && var.HDB_CONCURRENT_JOBS <=25
		error_message = "The HDB_CONCURRENT_JOBS is not valid."
	}
}

variable "KIT_SAPCAR_FILE" {
	type		= string
	description = "Path to sapcar binary, as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/SAPCAR_1300-70007716.EXE"
}

variable "KIT_SWPM_FILE" {
	type		= string
	description = "Path to SWPM archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/SWPM10SP42_0-20009701.SAR"
}

variable "KIT_SAPEXE_FILE" {
	type		= string
	description = "Path to SAP Kernel OS archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/KERNEL/7.54UC/SAPEXE_400-80007612.SAR"
}

variable "KIT_SAPEXEDB_FILE" {
	type		= string
	description = "Path to SAP Kernel DB archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/KERNEL/7.54UC/SAPEXEDB_400-80007611.SAR"
}

variable "KIT_IGSEXE_FILE" {
	type		= string
	description = "Path to IGS archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/KERNEL/7.54UC/igsexe_4-80007786.sar"
}

variable "KIT_IGSHELPER_FILE" {
	type		= string
	description = "Path to IGS Helper archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/igshelper_17-10010245.sar"
}

variable "KIT_SAPHOSTAGENT_FILE" {
	type		= string
	description = "Path to SAP Host Agent archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/SAPHOSTAGENT65_65-80004822.SAR"
}

variable "KIT_HDBCLIENT_FILE" {
	type		= string
	description = "Path to HANA DB client archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/IMDB_CLIENT20_022_27-80002082.SAR"
}

variable "KIT_NWABAP_EXPORT_FILE" {
	type		= string
	description = "Path to SAP Netweaver Installation Export ZIP file. The archive downloaded from SAP Support Portal should be present in this path."
	default		= "/storage/NW75HDB/ABAPEXP/51050829_3.ZIP"
}
