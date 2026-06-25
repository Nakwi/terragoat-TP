variable "subscription_id" {
  type        = string
  description = "The subscription ID to be scanned"
  default     = null
}

variable "location" {
  type    = string
  default = "Spain Central"
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

variable "admin_ssh_public_key" {
  type        = string
  description = "Cle SSH publique pour l'acces a la VM Linux"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9QuwG2vXgeM9vEKwFUaZa4UtLw3l6S2KpvIT85OBGV9bFBr0g7NMHzd8nIypGuhkyhNVVyv/te16rpUEyss2lfcj82/US249Ugp7o4uD0uC5/zZdy7cz90ZURu6fgSW2/kQMhPsCiBrH0sVMjzwUqM7a/bdnrNZjHnb3zbuFkr2WctlX2J0yiRnVioZzKLsZNb4sNoXiAmoqnoNKrkGTj0P3p+SkLDpRIo2e93qKHCaCxE2MS1qBAbf0HHqrbETaI88UfYEZiJzS1YeIWwbh7NN8MSzpGMyeVulxJ6TP+1iYnZML7sMO9vq8pE90vS8KvrXYXUPvJKEDcHUTbq+y5l1X8+knbgExobMSknuTSTmiQvcJbUNnlblsvZ4Nmw9PU/gEYj+KF3B1yXbdQ8va4qzl2Lcxk3AGctiN8sjyfE1jTXXCKBmivUPsGol8ocSY8jQGl51qBkKTMM4X6HDmqd51FitiEfH6N30/JA0I4fLguNdfuiydsF89+3t8ieULNNruUanqtiYv0+otODiKc9qrFtZf1xMV4Qzbf90WcK8Ajm6Mk4yrWt4WZ9VzAmXJGj2UlgzdVo4bxSS51Hx3zoHZgI2/sxXpaIJtrHePU3535x3xvgD6pD923Axa80ko2y+ULEZjyDwa2oWhwhwo2atFi+B1xHpz4PcR+Hrlqaw== azureuser@vm-terragoat"
}