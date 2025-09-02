# Azure configuration
variable "vm_size"{
  description = "value for VM size"
  type = string
  default = "Standard_B1s"
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "demo"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "centralindia"
}

variable "admin_username" {
  description = "Admin username for VM"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "admin_object_id" {
  description = "Azure AD Object ID for admin"
  type        = string
}

# Cloudflare (optional)
variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  default     = ""
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
  default     = ""
}
