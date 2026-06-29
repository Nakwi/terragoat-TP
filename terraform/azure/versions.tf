terraform {
  required_version = "= 1.15.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "azurerm" {}
}
# trigger
# retry 1782408522
# retry 1782409256
# relance cicd 1782417283
# trigger cicd 1782734835
