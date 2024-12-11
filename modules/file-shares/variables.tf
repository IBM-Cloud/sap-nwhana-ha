/**
#################################################################################################################
*                           Variable Section for the Bastion Module.
*                                 Start Here of the Variable Section 
#################################################################################################################
*/
variable "vpc_id" {
  description = "Required parameter vpc_id"
  type        = string
}

variable "vpc" {
  description = "Required parameter vpc"
  type        = string
}

variable "subnet_id" {
    type = string
    description = "Subnet ID"
}

variable "security_group_id" {
    type = string
    description = "Security group ID"
}

variable "region" {
  description = "Please enter a region from the following available region and zones mapping."
  type        = string
  }

variable "zone" {
  description = "Availability Zone where bastion resource will be created"
  type        = string
}

variable "resource_group_id" {
  description = "Resource Group ID is used to separate the resources in a group."
  type        = string
}

locals {
  share_name    = lower ("${var.prefix}-${var.sap_sid}")
}

variable "sap_sid" {
    type = string
    description = "SAP SID"
}

variable "api_key" {
  description = "Please enter the IBM Cloud API key."
  type        = string
}

variable "prefix" {
  description = "Prefix for all the resources."
  type        = string
}

variable "ansible_var_name" {
  description = "ansible_var_name for all the resources."
  type        = string
}

variable "share_size" {
  description = "Specify the file share size. The value should be between 10 GB to 32000 GB's"
  type        = number
}

variable "share_profile" {
  description = "The profile for File Share Storage. Valid value: dp2."
  type        = string
}