resource "azurerm_sql_firewall_rule" "example" {
  name                = "terragoat-firewall-rule-${var.environment}"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_sql_server.example.name
  start_ip_address    = "10.0.17.62"
  end_ip_address      = "10.0.17.62"
}

resource "azurerm_sql_server" "example" {
  name                         = "terragoat-sqlserver-${var.environment}${random_integer.rnd_int.result}"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  version                      = "12.0"
  administrator_login          = "ariel"
  administrator_login_password = azurerm_key_vault_secret.sql_password.value
  tags = merge({
    environment = var.environment
    terragoat   = "true"
    }, {
    git_commit           = "81738b80d571fa3034633690d13ffb460e1e7dea"
    git_file             = "terraform/azure/sql.tf"
    git_last_modified_at = "2020-06-19 21:14:50"
    git_last_modified_by = "Adin.Ermie@outlook.com"
    git_modifiers        = "Adin.Ermie/nimrodkor"
    git_org              = "bridgecrewio"
    git_repo             = "terragoat"
    yor_trace            = "e5ec3432-e61f-4244-b59e-9ecc24ddd4cb"
  })
}

resource "azurerm_mssql_server_security_alert_policy" "example" {
  resource_group_name        = azurerm_resource_group.example.name
  server_name                = azurerm_sql_server.example.name
  state                      = "Enabled"
  disabled_alerts = [
    "Sql_Injection",
    "Data_Exfiltration"
  ]
  retention_days       = 90
  email_account_admins = true
  email_addresses      = ["securityengineer@terragoat-tp.local"]
}

resource "azurerm_mysql_flexible_server" "example" {
  name                = "terragoat-mysql-${var.environment}${random_integer.rnd_int.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  administrator_login    = "terragoatadmin"
  administrator_password = random_password.password.result

  sku_name = "B_Standard_B1ms"
  version  = "8.0.21"

  backup_retention_days = 7

  storage {
    size_gb = 20
  }

  tags = {
    git_commit           = "81738b80d571fa3034633690d13ffb460e1e7dea"
    git_file             = "terraform/azure/sql.tf"
    git_last_modified_at = "2020-06-19 21:14:50"
    git_last_modified_by = "Adin.Ermie@outlook.com"
    git_modifiers        = "Adin.Ermie/nimrodkor"
    git_org              = "bridgecrewio"
    git_repo             = "terragoat"
    yor_trace            = "1ac18c16-09a4-41c9-9a66-6f514050178e"
  }
}

resource "azurerm_postgresql_flexible_server" "example" {
  name                = "terragoat-postgresql-${var.environment}${random_integer.rnd_int.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  administrator_login    = "terragoatadmin"
  administrator_password = azurerm_key_vault_secret.sql_password.value

  sku_name   = "B_Standard_B1ms"
  version    = "13"
  storage_mb = 32768

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  tags = {
    git_commit           = "81738b80d571fa3034633690d13ffb460e1e7dea"
    git_file             = "terraform/azure/sql.tf"
    git_last_modified_at = "2020-06-19 21:14:50"
    git_last_modified_by = "Adin.Ermie@outlook.com"
    git_modifiers        = "Adin.Ermie/nimrodkor"
    git_org              = "bridgecrewio"
    git_repo             = "terragoat"
    yor_trace            = "9eae126d-9404-4511-9c32-2243457df459"
  }
}

resource "azurerm_postgresql_flexible_server_configuration" "thrtottling_config" {
  name      = "connection_throttle.enable"
  server_id = azurerm_postgresql_flexible_server.example.id
  value     = "off"
}

resource "azurerm_postgresql_flexible_server_configuration" "example" {
  name      = "log_checkpoints"
  server_id = azurerm_postgresql_flexible_server.example.id
  value     = "off"
}

