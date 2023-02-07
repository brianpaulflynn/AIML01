variable "name" {
  type        = string
  description = "Name of the deployment"
  default     = "bpf7701"
}

variable "environment" {
  type        = string
  description = "Name of the environment"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Location of the resources"
  default     = "East US"
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
