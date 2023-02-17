variable "name" {
  type        = string
  description = "Name of the deployment"
  default     = "bpf7707"
}

variable "environment" {
  type        = string
  description = "Name of the environment"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Location of the resources"
  default     = "West US"
}

variable "admin_username" {
  type        = string
  description = "admin user for vm"
  default     = "dsadmin"
}

variable "admin_password" {
  type        = string
  description = "admin pwd for vm"
  default     = "Password1234!"
}

variable "ARM_SUBSCRIPTION_ID" {
    type = string
}

variable "ARM_TENANT_ID" {
    type = string
}

variable "ARM_CLIENT_ID" {
    type = string
}

variable "ARM_CLIENT_SECRET" {
    type = string
}
