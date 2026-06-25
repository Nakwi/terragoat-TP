provider "azurerm" {
  subscription_id            = var.subscription_id
  skip_provider_registration = true
  features {}
}
data "azurerm_client_config" "current" {}
