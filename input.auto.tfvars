##########################################################
# General VPC variables:
##########################################################

REGION = ""
# The cloud region where to deploy the solution. Supported regions: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: REGION = "eu-de"

DOMAIN_NAME = "ha.mzexample.com"
# The DOMAIN_NAME variable should contain at least one "." as a separator. It is a private domain and it is not reacheable to and from the outside world.
# The DOMAIN_NAME variable could be like a subdomain name. Ex.: staging.example.com
# Domain names can only use letters, numbers, and hyphens.
# Hyphens cannot be used at the beginning or end of the domain name.
# You can't use a domain name that is already in use.
# Domain names are not case sensitive.

ASCS_VIRT_HOSTNAME = "sapascs"
# ASCS Virtual Hostname
# Default value: sapascs
# When the default value is used, the virtual hostname will automatically be changed based on <SAP_SID> to "sap<sap_sid>ascs"

ERS_VIRT_HOSTNAME = "sapers"
# ERS Virtual Hostname
# Default value: sapers
# When the default value is used, the virtual hostname will automatically be changed based on <SAP_SID> to "sap<sap_sid>ers"

HANA_VIRT_HOSTNAME = "dbhana"
# Hana Virtual Hostname
# Default value: dbhana
# When the default value is used, the virtual hostname will automatically be changed based on <SAP_SID> to "db<hana_sid>hana"

VPC = ""
# The name of an EXISTING VPC. Must be in the same region as the solution to be deployed. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs.
# Example: VPC = "ic4sap"

ZONE_1 = ""
# Availability zone for DB_HOSTNAME_1 and APP_HOSTNAME_1 VSIs, in the same VPC. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: ZONE = "eu-de-1"

SUBNET_1 = ""
# The name of an EXISTING Subnet, in the same VPC, ZONE_1, where DB_HOSTNAME_1 and APP_HOSTNAME_1 VSIs will be created. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets
# Example: SUBNET = "ic4sap-subnet_1"

ZONE_2 = ""
# Availability zone for DB_HOSTNAME_2 and APP_HOSTNAME_2 VSIs, in the same VPC. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. 
# If the same value as for ZONE_1 is used, and the value for SUBNET_1 is the same with the value for SUBNET_2, the deployment will be done in a single zone. If the values for ZONE_1, SUBNET_1 are different than the ones for ZONE_2, SUBNET_2 then an SAP Multizone deployment will be done.
# Example: ZONE = "eu-de-2"

SUBNET_2 = ""
# The name of an EXISTING Subnet, in the same VPC, ZONE_2, where DB_HOSTNAME_2 and APP_HOSTNAME_2 VSIs will be created. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets. 
# If the same value as for SUBNET_1 is used, and the value for ZONE_1 is the same with the value for ZONE_2, the deployment will be done in a single zone. If the values for ZONE_1, SUBNET_1 are different than the ones for ZONE_2, SUBNET_2 then it an SAP Multizone deployment will be done.
# Example: SUBNET = "ic4sap-subnet_2"

SECURITY_GROUP = ""
# The name of an EXISTING Security group for the same VPC. It can be found at the end of the Bastion Server deployment log, in \"Outputs\", before \"Command finished successfully\" message. The list of Security Groups is available here: https://cloud.ibm.com/vpc-ext/network/securityGroups.
# Example: SECURITY_GROUP = "ic4sap-securitygroup"

RESOURCE_GROUP = ""
# EXISTING Resource group, previously created by the user. The list of available Resource Groups: https://cloud.ibm.com/account/resource-groups
# Example: RESOURCE_GROUP = "wes-automation"

SSH_KEYS = [""]
# List of SSH Keys UUIDs that are allowed to connect via SSH, as root, to the VSI. Can contain one or more IDs. The list of SSH Keys is available here: https://cloud.ibm.com/vpc-ext/compute/sshKeys.
# Example: SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680374t3c", "r011-8f72v884-c17f-4500-af8f-d05900374t3c"]

ID_RSA_FILE_PATH = "ansible/id_rsa"
# The path to an existing id_rsa private key file, with 0600 permissions. The private key must be in OpenSSH format.
# This private key is used only during the provisioning and it is recommended to be changed after the SAP deployment.
# It must contain the relative or absoute path from your Bastion.
# Examples: "ansible/id_rsa_ha" , "~/.ssh/id_rsa_ha" , "/root/.ssh/id_rsa".

##########################################################
# File Shares variables:
##########################################################

SHARE_PROFILE = "dp2"
# The Storage Profile for the File Share
# More details on https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#dp2-profile."

USRSAP_AS1      = "20"
USRSAP_AS2      = "20"
USRSAP_SAPASCS  = "20"
USRSAP_SAPERS   = "20"
USRSAP_SAPMNT   = "20"
USRSAP_SAPSYS   = "20"
USRSAP_TRANS    = "80"
# Default File shares sizes:

##########################################################
# DB VSI variables:
##########################################################

DB_HOSTNAME_1 = "hanadb-1"
# HANA DB VSI HOSTNAME 1 in SAP HANA Cluster. The hostname should be up to 13 characters, as required by SAP
# Default value: "hanadb-1"
# When the default value is used, the virtual hostname will automatically be changed based on <HANA_SID> to "hanadb-<hana_sid>-1"

DB_HOSTNAME_2 = "hanadb-2"
# HANA DB VSI HOSTNAME 2 in SAP HANA Cluster. The hostname should be up to 13 characters, as required by SAP
# Default value: "hanadb-2"
# When the default value is used, the virtual hostname will automatically be changed based on <HANA_SID> to "hanadb-<hana_sid>-2"

DB_PROFILE = "mx2-16x128"
# The instance profile used for the HANA VSI. The list of certified profiles for HANA VSIs: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc
# Details about all x86 instance profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles).
# For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) 
# Default value: "mx2-16x128"

DB_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-6"
# OS image for DB VSI. OS images validated for DB VSIs: ibm-redhat-8-6-amd64-sap-hana-6, ibm-redhat-8-4-amd64-sap-hana-10
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: DB_IMAGE = "ibm-redhat-8-4-amd64-sap-hana-10" 

##########################################################
# SAP APP VSI variables:
##########################################################

APP_HOSTNAME_1 = "sapapp-1"
# APP VSI HOSTNAME 1 in SAP APP Cluster. The hostname should be up to 13 characters. 
# Default value: "sapapp-1"
# When the default value is used, the virtual hostname will automatically be changed based on <SAP_SID> to "sapapp-<sap_sid>-1"

APP_HOSTNAME_2 = "sapapp-2"
# APP VSI HOSTNAME 2 in SAP APP Cluster. The hostname should be up to 13 characters. 
# Default value: "sapapp-2"
# When the default value is used, the virtual hostname will automatically be changed based on <SAP_SID> to "sapapp-<sap_sid>-2"

APP_PROFILE = "bx2-4x16"
# The APP VSI profile. Supported profiles: bx2-4x16. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui

APP_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-6"
# OS image for SAP APP VSI. OS images validated for APP VSIs: ibm-redhat-8-6-amd64-sap-hana-6, ibm-redhat-8-4-amd64-sap-hana-10.
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: APP_IMAGE = "ibm-redhat-8-4-amd64-sap-hana-10" 

##########################################################
# SAP HANA configuration
##########################################################

HANA_SID = "HDB"
# SAP HANA system ID. Should follow the SAP rules for SID naming.
# Obs. This will be used  also as identification number across different HA name resources. Duplicates are not allowed.
# Example: HANA_SID = "HDB"

HANA_SYSNO = "00"
# SAP HANA instance number. Should follow the SAP rules for instance number naming.
# Example: HANA_SYSNO = "00"

HANA_TENANT = "NWA"
# SAP HANA tenant name
# Example: HANA_TENANT = "HDB_TEN1"

HANA_SYSTEM_USAGE = "custom"
# System usage. Default: custom. Suported values: production, test, development, custom
# Example: HANA_SYSTEM_USAGE = "custom"

HANA_COMPONENTS = "server"
# SAP HANA Components. Default: server. Supported values: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp
# Example: HANA_COMPONENTS = "server"

KIT_SAPHANA_FILE = "/storage/HANADB/SP07/Rev73/51057281.ZIP"
# SAP HANA Installation kit path
# Example for Red Hat 8: KIT_SAPHANA_FILE = "/storage/HANADB/SP07/Rev73/51057281.ZIP"

##########################################################
# SAP system configuration
##########################################################

SAP_SID = "NWA"
# SAP System ID
# Obs. This will be used  also as identification number across different HA name resources. Duplicates are not allowed.

SAP_ASCS_INSTANCE_NUMBER = "00"
# The central ABAP service instance number. Should follow the SAP rules for instance number naming.
# Example: SAP_ASCS_INSTANCE_NUMBER = "00"

SAP_ERS_INSTANCE_NUMBER = "01"
# The enqueue replication server instance number. Should follow the SAP rules for instance number naming.
# Example: SAP_ERS_INSTANCE_NUMBER = "01"

SAP_CI_INSTANCE_NUMBER = "10"
# The primary application server instance number. Should follow the SAP rules for instance number naming.
# Example: SAP_CI_INSTANCE_NUMBER = "10"

SAP_AAS_INSTANCE_NUMBER = "20"
# The additional application server instance number. Should follow the SAP rules for instance number naming.
# Example: SAP_AAS_INSTANCE_NUMBER = "20"

HDB_CONCURRENT_JOBS = "23"
# Number of concurrent jobs used to load and/or extract archives to HANA Host

##########################################################
# SAP NW ABAP APP Kit Paths
##########################################################

KIT_SAPCAR_FILE = "/storage/NW75HDB/SAPCAR_1300-70007716.EXE"
KIT_SWPM_FILE = "/storage/NW75HDB/SWPM10SP42_0-20009701.SAR"
KIT_SAPEXE_FILE = "/storage/NW75HDB/KERNEL/7.54UC/SAPEXE_400-80007612.SAR"
KIT_SAPEXEDB_FILE = "/storage/NW75HDB/KERNEL/7.54UC/SAPEXEDB_400-80007611.SAR"
KIT_IGSEXE_FILE = "/storage/NW75HDB/KERNEL/7.54UC/igsexe_4-80007786.sar"
KIT_IGSHELPER_FILE = "/storage/NW75HDB/igshelper_17-10010245.sar"
KIT_SAPHOSTAGENT_FILE = "/storage/NW75HDB/SAPHOSTAGENT65_65-80004822.SAR"
KIT_HDBCLIENT_FILE = "/storage/NW75HDB/IMDB_CLIENT20_022_27-80002082.SAR"
KIT_NWABAP_EXPORT_FILE = "/storage/NW75HDB/ABAPEXP/51050829_3.ZIP"
