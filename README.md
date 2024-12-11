# Automation scripts for the Deployment of SAP Netweaver ABAP HANA High Availability Multi-Zone or Single-Zone using Terraform and Ansible

## Description

This automation solution is designed for **SAP Netweaver ABAP HANA High Availability Deployment** in IBM CLoud Multi-Zone or Single-Zone distribution, using IBM Cloud Schematics or Terraform CLI. The SAP solution will be deployed on top of one of the following Operating Systems: **Red Hat Enterprise Linux 8.6 for SAP**, **Red Hat Enterprise Linux 8.4 for SAP** in an existing IBM Cloud Gen2 VPC, using a deployed [bastion host with secure remote SSH access](https://github.com/IBM-Cloud/sap-bastion-setup).

The solution is based on Terraform and Ansible playbooks executed using IBM Cloud Schematics or Terraform CLI and it is implementing a 'reasonable' set of best practices for SAP VSI host configuration. The automation has support for the following versions: Terraform >= 1.5.7 and IBM Cloud provider for Terraform >= 1.57.0.

It contains:

- Terraform scripts to provision:
  - one Power Placement group for all four VMs created by this solution
  - four VSIs, in an EXISTING VPC, with Subnet and Security Group configs. The VSIs scope: two for the HANA database cluster and two for the SAP application cluster.
- Terraform scripts to provision and configure:
  - three Application Load Balancers for HANA DB, SAP ASCS/ERS
  - one VPC DNS service used to map the ALB FQDN to the SAP ASCS/ERS and Hana Virtual hostnames
  - seven File shares for VPC
- Bash scripts:
  - to check the prerequisites required by SAP VSIs deployment 
  - to integrate into a single step the VPC virtual resources provisioning and the **SAP Netweaver ABAP HANA HA cluster solution** installation.
- Ansible scripts for:
  - OS requirements installation and configuration for SAP applications
  - filesystem setup
  - cluster components installation
  - SAP application cluster configuration and SAP HANA cluster configuration
  - SAP HANA installation
  - SAP HANA system replica configuration
  - ASCS and ERS instances installation
  - DB load
  - primary and additional SAP application servers installation

The following resources are created during the deployment:

- two SAP VMs for ASCS/ERS HA running in a pacemaker cluster; SAP PAS is running on one of the cluster node and SAP AAS on the second node  
- two HANA VMs, with HSR Sync replication, running in a pacemaker cluster; the primary node is active and the secondary node runs in standby mode
- three ALBs used for Virtual IP/hostname for ASCS, ERS and HANA.
- one DNS service to map the virtual names for ASCS/ERS/HANA to ALB hostname
- seven File shares to be used by SAP.

Notes:
- For Network latency between VPC Zones and Regions please check the "VPC Network latency dashboards" using the link bellow and run your own measurement according with SAP note "500235 - Network Diagnosis with NIPING" to perform a latency check using SAP tool niping: https://cloud.ibm.com/docs/vpc?topic=vpc-network-latency-dashboard
   - The results reported are as measured. There are no performance guarantees implied by these measurement. 
   - These statistics provide visibility into latency between all regions and zones to help you plan the optimal selection for your cloud deployment and plan for scenarios, such as data residency and performance

- ZONE_1 is the availability zone for DB_HOSTNAME_1 and APP_HOSTNAME_1 VSIs.
- SUBNET_1  is an EXISTING Subnet, where DB_HOSTNAME_1 and APP_HOSTNAME_1 VSIs will be created. 
- ZONE_2 is the availability zone for DB_HOSTNAME_2 and APP_HOSTNAME_2 VSIs.
- SUBNET_2  is an EXISTING Subnet, where DB_HOSTNAME_2 and APP_HOSTNAME_2 VSIs will be created. 
- If the values of the variables ZONE_1 and ZONE_2 are equal and the values of the variables SUBNET_1 and SUBNET_2 are also equal, an **SAP Single-Zone Deployment** will be done in ZONE_1, SUBNET_1.
- If the variable values from ZONE_1, SUBNET_1 are different than ZONE_2, SUBNET_2, an **SAP Multi-Zone Deployment** will be executed.
- Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc.
- The list of EXISTING Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets.
- Each Subnet must have Internet access throught a Public Gateway.

## Contents:

- [1.1 Installation media](#11-installation-media)
- [1.2 Prerequisites](#12-prerequisites)
- [1.3 VSI Configuration](#13-vsi-configuration)
- [1.4 VPC Configuration](#14-vpc-configuration)
- [1.5 Files description and structure](#15-files-description-and-structure)
- [1.6 General input variabiles](#16-general-input-variables)
- [2.1 Executing the deployment of **HA SAP Netweaver ABAP HANA** in GUI (Schematics)](#21-executing-the-deployment-of-ha-sap-netweaver-abap-hana-in-gui-schematics)
- [2.2 Executing the deployment of **HA SAP Netweaver ABAP HANA** in CLI](#22-executing-the-deployment-of-ha-sap-netweaver-abap-hana-in-cli)
- [3.1 Related links](#31-related-links)

## 1.1 Installation media
SAP HANA installation media used for this deployment is the default one for **SAP HANA, platform edition 2.0 SPS07** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided manually in the input parameter file.

SAP Netweaver installation media used for this deployment is the default one for **SAP Netweaver 7.5** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided manually in the input parameter file.

## 1.2 Prerequisites

- A Deployment Server (BASTION Server) in the same VPC should exist. For more information, see https://github.com/IBM-Cloud/sap-bastion-setup.
- From the SAP Portal, download the SAP kits on the Deployment Server. Make note of the download locations. Ansible decompresses all of the archive kits.
- Create or retrieve an IBM Cloud API key. The API key is used to authenticate with the IBM Cloud platform, determine your permissions for IBM Cloud services and it is required for the functioning of the cluster stonith devices in IBM VPC.
- Create or retrieve your SSH key ID. You need the 40-digit UUID for the SSH key, not the SSH key name.

## 1.3 Server Configuration
The Servers are deployed with one of the following Operating Systems for DB servers and APP servers: **Red Hat Enterprise Linux 8.6 for SAP HANA (amd64)**, **Red Hat Enterprise Linux 8.4 for SAP HANA (amd64)**. The SSH keys are configured to allow root user access. The following storage volumes are creating during the provisioning:

HANA DB VSI Disks:
- the disk sizes depend on the selected profile, according to [Intel Virtual Server certified profiles on VPC infrastructure for SAP HANA](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc) - Last updated 2023-12-28

Note: For SAP HANA on a VSI, according to [Intel Virtual Server certified profiles on VPC infrastructure for SAP HANA](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc#vx2d-16x224) - Last updated 2022-01-28 and to [Storage design considerations](https://cloud.ibm.com/docs/sap?topic=sap-storage-design-considerations) - Last updated 2024-01-25, LVM will be used for **`/hana/data`**, **`hana/log`**, **`/hana/shared`** and **`/usr/sap`**, for all storage profiles, with the following exceptions:
- **`/hana/data`** and **`/hana/shared`** for the following profiles: **`vx2d-44x616`** and **`vx2d-88x1232`**
- **`/hana/shared`** for the following profiles: **`vx2d-144x2016`**, **`vx2d-176x2464`**, **`ux2d-36x1008`**, **`ux2d-48x1344`**, **`ux2d-72x2016`**, **`ux2d-100x2800`**, **`ux2d-200x5600`**.

For example, in case of deploying a SAP HANA on a VSI, using the value `mx2-16x128` for the VSI profile , the automation will execute the following storage setup:  
- 3 volumes x 500 GB each for `<sid>_hana_vg` volume group
  - the volume group will contain the following logical volumes (created with three stripes):
    - `<sid>_hana_data_lv` - size 988 GB
    - `<sid>_hana_log_lv` - size 256 GB
    - `<sid>_hana_shared` - size 256 GB
- 1 volume x 50 GB for `/usr/sap` (volume group: `<sid>_usr_sap_vg`, logical volume: `<sid>_usr_sap_lv`)
- 1 volume x 10 GB for a 2 GB SWAP logical volume (volume group: `<sid>_swap_vg`, logical volume: `<sid>_swap_lv`)

SAP APPs VSI Disks:
- 1 disk with 10 IOPS / GB - SWAP (the size depends on the OS profile used, for `bx2-4x16` the size will be 48 GB)

In order to perform the deployment you can use either the CLI component or the GUI component (Schematics) of the automation solution.

## 1.4 VPC Configuration

The Security Rules inherited from BASTION deployment are the following:
- Allow all traffic in the Security group for private networks.
- Allow outbound traffic  (ALL for port 53, TCP for ports 80, 443, 8443)
- Allow inbound SSH traffic (TCP for port 22) from IBM Schematics Servers.

## 1.5 Files description and structure

The solution is based on Terraform and Ansible playbooks executed throught remote&local-exec tf options by IBM Schematics or Terraform CLI and it has the following structure:

 - `modules` - directory containing the terraform modules.
 - `ansible`  - directory containing the SAP ansible playbooks.
 - `main.tf` - contains the configuration of the VSI for the deployment of the current SAP solution.
 - `output.tf` - contains the code for the information to be displayed after the VSI is created (VPC, Hostname, Private IP).
 - `integration*.tf & generate*.tf` files - contain the integration code that makes the SAP variabiles from Terraform available to Ansible.
 - `provider.tf` - contains the IBM Cloud Provider data in order to run `terraform init` command.
 - `variables.tf` - contains variables for the VPC and VSI.
 - `versions.tf` - contains the minimum required versions for terraform and IBM Cloud provider.
 - `sch.auto.tfvars` - contains programatic variables.

## 1.6 General Input variables

**Server input parameters:**

Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value). The IBM Cloud API Key can be created [here](https://cloud.ibm.com/iam/apikeys)
SSH_KEYS | List of IBM Cloud SSH Keys UUIDs that are allowed to connect via SSH, as root, to the VSI. The SSH Keys should be created for the same region as the Cloud resources for SAP. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input (use your own SSH UUIDs from IBM Cloud):<br /> ["r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a", "r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e"]
RESOURCE_GROUP | The name of an EXISTING Resource Group for VSIs and Volumes resources. <br /> Default value: "Default". The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups).
REGION | The cloud region where to deploy the solution. <br /> The regions and zones for VPC are available [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Supported locations in IBM Cloud Schematics [here](https://cloud.ibm.com/docs/schematics?topic=schematics-locations).<br /> Sample value: eu-de.
VPC | The name of an EXISTING VPC. Must be in the same region as the solution to be deployed. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
ZONE_1| Availability zone for DB_HOSTNAME_1 and APP_HOSTNAME_1 VSIs, in the same VPC. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. 
SUBNET_1 | The name of an EXISTING Subnet, in the same VPC, ZONE_1, where DB_HOSTNAME_1 and APP_HOSTNAME_1 VSIs will be created. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets
ZONE_2| Availability zone for DB_HOSTNAME_2 and APP_HOSTNAME_2 VSIs, in the same VPC. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. OBS.: If the same value as for ZONE_1 is used, and the value for SUBNET_1 is the same with the value for SUBNET_2, the deployment will be done in a single zone. If the values for ZONE_1, SUBNET_1 are different than the ones for ZONE_2, SUBNET_2 then an SAP Multizone deployment will be done.
SUBNET_2 | The name of an EXISTING Subnet, in the same VPC, ZONE_2, where DB_HOSTNAME_2 and APP_HOSTNAME_2 VSIs will be created. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets. OBS.: If the same value as for SUBNET_1 is used, and the value for ZONE_1 is the same with the value for ZONE_2, the deployment will be done in a single zone. If the values for ZONE_1, SUBNET_1 are different than the ones for ZONE_2, SUBNET_2 then it an SAP Multizone deployment will be done.
SECURITY_GROUP | The name of an EXISTING Security group for the same VPC. It can be found at the end of the Bastion Server deployment log, in \"Outputs\", before \"Command finished successfully\" message. The list of Security Groups is available here: https://cloud.ibm.com/vpc-ext/network/securityGroups.
DOMAIN_NAME | The Domain Name used for DNS and ALB. Duplicates are not allowed. The list with DNS resources can be searched [here](https://cloud.ibm.com/resources). <br /> Default value: "ha.mzexample.com" <br />  Sample value:  "example.com". <br /> _(See Obs.*)_
SHARE_PROFILE | The Storage Profile for the File Share. More details [here](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#dp2-profile). <br/> Default value: "dp2".
USRSAP_AS1 | File Share Size (in GB) for /usr/sap/<SAP_SID>/D<SAP_AAS_INSTANCE_NUMBER> mount <br/> Default value: "20"
USRSAP_AS2 | File Share Size (in GB) for /usr/sap/<SAP_SID>/D<SAP_CI_INSTANCE_NUMBER> mount  <br/> Default value: "20"
USRSAP_SAPASCS| File Share Size (in GB) for /usr/sap/<SAP_SID>/ASCS<SAP_ASCS_INSTANCE_NUMBER> mount  <br/> Default value: "20"
USRSAP_SAPERS | File Share Size (in GB) for/usr/sap/<SAP_SID>/ERS<SAP_ERS_INSTANCE_NUMBER> mount  <br/> Default value: "20"
USRSAP_SAPMNT | File Share Size (in GB) for SAP /sapmnt/<SAP_SID> mount  <br/> Default value: "20"
USRSAP_SAPSYS | File Share Size (in GB) for SAP /usr/sap/<SAP_SID>/SYS mount  <br/> Default value: "20"
USRSAP_TRANS | File Share Size (in GB) for SAP /usr/sap/trans mount  <br/> Default value: "80"
[DB/APP]_VIRT_HOSTNAMES | HANA/ASCS/ERS virtual hostnames. <br /> Default values: "dbhana", "sapascs", "sapers" <br /> If the default values are used, they will be automatically converted to: "db<hana_sid>hana", "sap<sap_sid>ascs", "sap<sap_sid>ers".
[DB/APP]_HOSTNAMES | SAP HANA/APP VSI Hostnames, in HANA/SAP cluster. <br /> Default values: "hanadb-1/2", "sapapp-1/2"  <br /> Each hostname should be up to 13 characters as required by SAP.<br> For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361). <br> If the default values are used, they will be automatically converted to: : DB_HOSTNAME_1/2 = "hanadb-<hana_sid>-1/2", APP_HOSTNAME_1/2 = "sapapp-<sap_sid>-1/2".
DB_PROFILE | The instance profile used for the HANA VSI. The list of certified profiles for HANA VSIs is available here. <br> Details about all x86 instance profiles are available here. <br> For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud <br> Default value: DB_PROFILE = "mx2-16x128"
APP_PROFILE | The profile used for the APP VSI. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles).<br> For more information about supported OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211)<br/> Default value: APP_PROFILE = "bx2-4x16".
[DB/APP]_IMAGE | The OS image used for the HANA/APP VSI. You must use the Red Hat Enterprise Linux 8 for SAP HANA (amd64) image for all VMs as this image contains  the required SAP and HA subscriptions.  A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images)  <br/> Default value: "ibm-redhat-8-6-amd64-sap-hana-6"

**SAP input parameters:**

Parameter | Description | Requirements
----------|-------------|-------------
HANA_SID | The SAP system ID identifies the SAP HANA system. <br/> Default value: "HDB" <br /> _(See Obs.*)_ | <ul><li>Consists of exactly three alphanumeric characters</li><li>Has a letter for the first character</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>|
HANA_SYSNO | Specifies the instance number of the SAP HANA system <br /> Default value: "00"| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
HANA_TENANT | SAP HANA tenant name. <br/> Default value: "NWA"
HANA_SYSTEM_USAGE  | System Usage <br /> Default value: "custom"| Valid values: production, test, development, custom
HANA_COMPONENTS | SAP HANA Components <br /> Default value: "server" | Valid values: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp
KIT_SAPHANA_FILE | Path to SAP HANA ZIP file <br /> Default value: "/storage/HANADB/SP07/Rev73/51057281.ZIP" | As downloaded from SAP Support Portal.
SAP_SID | The SAP system ID <SAPSID> identifies the entire SAP system. <br/> Default value: "NWA" <br /> _(See Obs.*)_| <ul><li>Consists of exactly three alphanumeric characters</li><li>Has a letter for the first character</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>
SAP_ASCS_INSTANCE_NUMBER | Technical identifier for internal processes of ASCS <br/> Default value: "00" | <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
SAP_ERS_INSTANCE_NUMBER | Technical identifier for internal processes of ERS <br/> Default value: "01"| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
SAP_CI_INSTANCE_NUMBER | Technical identifier for internal processes of PAS <br/> Default value: "10"| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
SAP_AAS_INSTANCE_NUMBER | Technical identifier for internal processes of AAS <br/> Default value: "20"| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
HDB_CONCURRENT_JOBS | Number of concurrent jobs used to load and/or extract archives to HANA Host <br/> Default value: "23" | 
KIT_SAPCAR_FILE  | Path to sapcar binary <br /> Default value: "/storage/NW75HDB/SAPCAR_1300-70007716.EXE" | As downloaded from SAP Support Portal.
KIT_SWPM_FILE | Path to SWPM archive (SAR) <br /> Default value: "/storage/NW75HDB/SWPM10SP42_0-20009701.SAR | As downloaded from SAP Support Portal. 
KIT_SAPEXE_FILE | Path to SAP Kernel OS archive (SAR) <br /> Default value: "/storage/NW75HDB/KERNEL/7.54UC/SAPEXE_400-80007612.SAR" | As downloaded from SAP Support Portal.
KIT_SAPEXEDB_FILE | Path to SAP Kernel DB archive (SAR) <br /> Default value: "/storage/NW75HDB/KERNEL/7.54UC/SAPEXEDB_400-80007611.SAR"| As downloaded from SAP Support Portal. 
KIT_IGSEXE_FILE | Path to IGS archive (SAR) <br /> Default value: "/storage/NW75HDB/KERNEL/7.54UC/igsexe_4-80007786.sar" | As downloaded from SAP Support Portal. 
KIT_IGSHELPER_FILE | Path to IGS Helper archive (SAR) <br /> Default value: "/storage/NW75HDB/igshelper_17-10010245.sar" | As downloaded from SAP Support Portal.
KIT_SAPHOSTAGENT_FILE | Path to SAP Host Agent archive (SAR) <br /> Default value: "/storage/NW75HDB/SAPHOSTAGENT65_65-80004822.SAR" | As downloaded from SAP Support Portal.
KIT_HDBCLIENT_FILE | Path to HANA DB client archive (SAR) <br /> Default value: "/storage/NW75HDB/IMDB_CLIENT20_022_27-80002082.SAR" | As downloaded from SAP Support Portal. 
KIT_NWABAP_EXPORT_FILE | Path to Netweaver Installation Export ZIP file <br /> Default value: "/storage/NW75HDB/ABAPEXP/51050829_3.ZIP" | The archives downloaded from SAP Support Portal should be present in this path.
 
 **Obs***: <br />

- The configured instance number must be different for each components (ASCS, ERS, CI, AAS).<br />
- **Sensitive** - The variable value is not displayed in your Schematics logs and it is hidden in the input field.<br />
- **SAP Passwords** 
  - The passwords for the SAP system will be asked interactively during terraform plan step and will not be available after the deployment. (Sensitive* values).

Parameter | Description | Requirements
----------|-------------|-------------
SAP_MAIN_PASSWORD | Common password for all users that are created during the installation | <ul><li>It must be 15 to 30 characters long<li>It must contain at least one digit (0-9)</li><li>It must contain at least one lowercase letter (a-z)</li><li>It must contain at least one uppercase letter (A-Z)</li><li>It may contain at one of the following special characters: !, #, $, &, , +, ,, -, ., /, :, =>, @, ^, _, |, ~.</li><li>It must start with a lowercase letter (a-z) or with an uppercase letter (A-Z).</li></ul>
HANA_MAIN_PASSWORD | HANA system master password | <ul><li>It must be 15 to 30 characters long<li>It must contain at least one digit (0-9)</li><li>It must contain at least one lowercase letter (a-z)</li><li>It must contain at least one uppercase letter (A-Z)</li><li>It may contain one of the following special characters: !, #, _, @, $.</li><li>It must start with a lowercase letter (a-z) or with an uppercase letter (A-Z).</li></ul>
HA_PASSWORD | HA cluster password | <ul><li>It must be 15 to 30 characters long<li>It must contain at least one digit (0-9)</li><li>It must contain at least one lowercase letter (a-z)</li><li>It must contain at least one uppercase letter (A-Z)</li><li>It must contain at least one of the following special characters: !, #, $, %, &, (, ), *, +, ,, -, ., /, :, =, >, @, [, ], ^, _, {, |, }, ~.</li><li>It must start with a lowercase letter (a-z) or with an uppercase letter (A-Z).</li></ul>

- The following parameters should have the same values as the ones set for the BASTION server: REGION, ZONES, VPC, SUBNET, SECURITYGROUP.
- **DOMAIN_NAME** variable rules:
  -  it should contain at least one "." as a separator. It is a private domain and it is not reacheable to and from the outside world.
  -  it could be like a subdomain name. Ex.: staging.example.com
  -  it can only use letters, numbers, and hyphens.
  -  hyphens cannot be used at the beginning or end of the domain name.
  -  it can't be used a domain name that is already in use.
  -  domain names are not case sensitive.
- The following SAP **"_SID_"** values are _reserved_ and are _not allowed_ to be used: ADD, ALL, AMD, AND, ANY, ARE, ASC, AUX, AVG, BIT, CDC, COM, CON, DBA, END, EPS, FOR, GET, GID, IBM, INT, KEY, LOG, LPT, MAP, MAX, MIN, MON, NIX, NOT, NUL, OFF, OLD, OMS, OUT, PAD, PRN, RAW, REF, ROW, SAP, SET, SGA, SHG, SID, SQL, SUM, SYS, TMP, TOP, UID, USE, USR, VAR".
 - For any manual change in the terraform code, you have to make sure that you use a certified image based on the SAP NOTE: 2927211.


**Installation media validated for this solution:**

Component | Version | Filename
----------|-------------|-------------
SAPCAR | 7.53 | SAPCAR_1300-70007716.EXE
SOFTWARE PROVISIONING MGR | 1.0 | SWPM10SP42_0-20009701.SAR
SAP KERNEL | 7.54 64-BIT UNICODE | SAPEXE_400-80007612.SAR<br> SAPEXEDB_400-80007611.SAR
SAP IGS | 7.54 | igsexe_4-80007786.sar
SAP IGS HELPER | PL 17 | igshelper_17-10010245.sar
SAP HOST AGENT | 7.22 SP 65 | SAPHOSTAGENT65_65-80004822.SAR
HANA CLIENT | 2.22 | IMDB_CLIENT20_022_27-80002082.SAR
HANA DB | 2.0 SPS07 rev73 | 51057281.ZIP
SAP NW Export | 7.5 | 51050829_3.ZIP

**OS images validated for this solution:**

OS version | Image | Role
-----------|-----------|-----------
Red Hat Enterprise Linux 8.6 for SAP HANA (amd64) | ibm-redhat-8-6-amd64-sap-hana-6 | DB
Red Hat Enterprise Linux 8.6 for SAP HANA (amd64) | ibm-redhat-8-6-amd64-sap-hana-6 | APP
Red Hat Enterprise Linux 8.4 for SAP HANA (amd64) | ibm-redhat-8-4-amd64-sap-hana-10 | DB
Red Hat Enterprise Linux 8.4 for SAP HANA (amd64) | ibm-redhat-8-4-amd64-sap-hana-10 | APP

**Terraform version used to validate this solution:**

The deployment was validated for Terraform 1.9.2

## 2.1 Executing the deployment of **HA SAP Netweaver ABAP HANA** in GUI (Schematics)

### Input parameters

Beside the parameters described in [General input variables Section](#15-general-input-variables), there are specific input variables for Schematics:

Parameter | Description
----------|------------
PRIVATE_SSH_KEY | id_rsa private key content (Sensitive* value) in OpenSSH format. This private key is used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
ID_RSA_FILE_PATH | The file path for the private ssh key. <br> Default value: "ansible/id_rsa" <br> It will be automatically generated. If it is changed, it must contain the relative path from git repo folders. Example: ansible/id_rsa_abap_ase-syb_std
BASTION_FLOATING_IP | The FLOATING IP from the Bastion Server. It can be found at the end of the Bastion Server deployment log, in "Outputs", before "Command finished successfully" message.

### Steps to follow:

1.  Make sure that you have the [required IBM Cloud IAM
    permissions](https://cloud.ibm.com/docs/vpc?topic=vpc-managing-user-permissions-for-vpc-resources) to
    create and work with VPC infrastructure and you are [assigned the
    correct
    permissions](https://cloud.ibm.com/docs/schematics?topic=schematics-access) to
    create the workspace in Schematics and deploy resources.
2.  [Generate an SSH
    key](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys).
    The SSH key is required to access the provisioned VPC virtual server
    instances via the bastion host. After you have created your SSH key,
    make sure to [upload this SSH key to your IBM Cloud
    account](https://cloud.ibm.com/docs/vpc-on-classic-vsi?topic=vpc-on-classic-vsi-managing-ssh-keys#managing-ssh-keys-with-ibm-cloud-console) in
    the VPC region and resource group where you want to deploy the SAP solution
3.  Create the Schematics workspace:
    1.  From the IBM Cloud menu
    select [Schematics](https://cloud.ibm.com/schematics/overview).
        - Push the `Create workspace` button.
        - Provide the URL of the Github repository of this solution
        - Select the latest Terraform version.
        - Click on `Next` button
        - Provide a name, the resources group and location for your workspace
        - Push `Next` button
        - Review the provided information and then push `Create` button to create your workspace
    2.  On the workspace **Settings** page, 
        - In the **Input variables** section, review the default values for the input variables and provide alternatives if desired.
        - Click **Save changes**.
4.  From the workspace **Settings** page, click **Generate plan** 
5.  From the workspace **Jobs** page, the logs of your Terraform
    execution plan can be reviewed.
6.  Apply your Terraform template by clicking **Apply plan**.
7.  Review the logs to ensure that no errors occurred during the
    provisioning, modification, or deletion process.

The output of the Schematics Apply Plan will dispaly the public/private IP addresses of the VSI host, the hostname and the VPC.

 ## 2.2 Executing the deployment of **HA SAP Netweaver ABAP HANA** in CLI

 
### Input parameter file
The `input.auto.tfvars` file must be used to make the desired configuration, as in the example bellow:

**VSI input parameters**

```shell
##########################################################
# General VPC variables:
##########################################################

REGION = "eu-de"
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

VPC = "ic4sap"
# The name of an EXISTING VPC. Must be in the same region as the solution to be deployed. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs.
# Example: VPC = "ic4sap"

ZONE_1 = "eu-de-1"
# Availability zone for DB_HOSTNAME_1 and APP_HOSTNAME_1 VSIs, in the same VPC. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: ZONE = "eu-de-1"

SUBNET_1 = "ic4sap-subnet_1"
# The name of an EXISTING Subnet, in the same VPC, ZONE_1, where DB_HOSTNAME_1 and APP_HOSTNAME_1 VSIs will be created. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets
# Example: SUBNET = "ic4sap-subnet_1"

ZONE_2 = "eu-de-2"
# Availability zone for DB_HOSTNAME_2 and APP_HOSTNAME_2 VSIs, in the same VPC. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. 
# If the same value as for ZONE_1 is used, and the value for SUBNET_1 is the same with the value for SUBNET_2, the deployment will be done in a single zone. If the values for ZONE_1, SUBNET_1 are different than the ones for ZONE_2, SUBNET_2 then an SAP Multizone deployment will be done.
# Example: ZONE = "eu-de-2"

SUBNET_2 = "ic4sap-subnet_2"
# The name of an EXISTING Subnet, in the same VPC, ZONE_2, where DB_HOSTNAME_2 and APP_HOSTNAME_2 VSIs will be created. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets. 
# If the same value as for SUBNET_1 is used, and the value for ZONE_1 is the same with the value for ZONE_2, the deployment will be done in a single zone. If the values for ZONE_1, SUBNET_1 are different than the ones for ZONE_2, SUBNET_2 then it an SAP Multizone deployment will be done.
# Example: SUBNET = "ic4sap-subnet_2"

SECURITY_GROUP = "ic4sap-securitygroup"
# The name of an EXISTING Security group for the same VPC. It can be found at the end of the Bastion Server deployment log, in \"Outputs\", before \"Command finished successfully\" message. The list of Security Groups is available here: https://cloud.ibm.com/vpc-ext/network/securityGroups.
# Example: SECURITY_GROUP = "ic4sap-securitygroup"

RESOURCE_GROUP = "wes-automation"
# EXISTING Resource group, previously created by the user. The list of available Resource Groups: https://cloud.ibm.com/account/resource-groups
# Example: RESOURCE_GROUP = "wes-automation"

SSH_KEYS = ["r010-8f7dsb994-c17f-4500-af8f-d0cddd0374t3c"]
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
```

## Steps to follow:

For initializing Terraform:

```shell
terraform init
```

For planning phase:

```shell
terraform plan --out plan1
# You will be asked for the following sensitive values:
'IBMCLOUD_API_KEY', 'SAP_MAIN_PASSWORD', 'HANA_MAIN_PASSWORD' and 'HA_PASSWORD'.
```

For apply phase:

```shell
terraform apply "plan1"
```

For destroy:

```shell
terraform destroy
# You will be asked for the following sensitive vavalues, as a destroy confirmation phase:
'IBMCLOUD_API_KEY', 'SAP_MAIN_PASSWORD', 'HANA_MAIN_PASSWORD' and 'HA_PASSWORD'.
```

### 3.1 Related links:

- [How to create a BASTION/STORAGE VSI for SAP in IBM Schematics](https://github.com/IBM-Cloud/sap-bastion-setup)
- [Securely Access Remote Instances with a Bastion Host](https://www.ibm.com/cloud/blog/tutorial-securely-access-remote-instances-with-a-bastion-host)
- [VPNs for VPC overview: Site-to-site gateways and Client-to-site servers.](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-overview)
- [IBM Cloud Schematics](https://www.ibm.com/cloud/schematics)
