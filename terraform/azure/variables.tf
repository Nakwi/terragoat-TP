variable "subscription_id" {
  type        = string
  description = "The subscription ID to be scanned"
  default     = null
}

variable "location" {
  type    = string
  default = "East US"
}

variable "environment" {
  default     = "dev"
  description = "Must be all lowercase letters or numbers"
}

variable "admin_ip" {
  type        = string
  description = "IP publique autorisee pour l'administration SSH/RDP (a remplacer par l'IP reelle de l'admin ou la plage VPN)"
  default     = "86.221.106.162/32"
}
