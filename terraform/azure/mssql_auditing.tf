# Extended Auditing Policies pour les MSSQL servers
# Corrige CKV_AZURE_23 (Auditing = On) et CKV_AZURE_24 (retention >= 90 jours)

resource "azurerm_mssql_server_extended_auditing_policy" "audit_mssql1" {
  server_id                  = azurerm_mssql_server.mssql1.id
  storage_endpoint           = azurerm_storage_account.security_storage_account.primary_blob_endpoint
  storage_account_access_key = azurerm_storage_account.security_storage_account.primary_access_key
  retention_in_days          = 90
}

resource "azurerm_mssql_server_extended_auditing_policy" "audit_mssql2" {
  server_id                  = azurerm_mssql_server.mssql2.id
  storage_endpoint           = azurerm_storage_account.security_storage_account.primary_blob_endpoint
  storage_account_access_key = azurerm_storage_account.security_storage_account.primary_access_key
  retention_in_days          = 90
}

resource "azurerm_mssql_server_extended_auditing_policy" "audit_mssql3" {
  server_id                  = azurerm_mssql_server.mssql3.id
  storage_endpoint           = azurerm_storage_account.security_storage_account.primary_blob_endpoint
  storage_account_access_key = azurerm_storage_account.security_storage_account.primary_access_key
  retention_in_days          = 90
}

resource "azurerm_mssql_server_extended_auditing_policy" "audit_mssql4" {
  server_id                  = azurerm_mssql_server.mssql4.id
  storage_endpoint           = azurerm_storage_account.security_storage_account.primary_blob_endpoint
  storage_account_access_key = azurerm_storage_account.security_storage_account.primary_access_key
  retention_in_days          = 90
}

resource "azurerm_mssql_server_extended_auditing_policy" "audit_mssql5" {
  server_id                  = azurerm_mssql_server.mssql5.id
  storage_endpoint           = azurerm_storage_account.security_storage_account.primary_blob_endpoint
  storage_account_access_key = azurerm_storage_account.security_storage_account.primary_access_key
  retention_in_days          = 90
}

resource "azurerm_mssql_server_extended_auditing_policy" "audit_mssql6" {
  server_id                  = azurerm_mssql_server.mssql6.id
  storage_endpoint           = azurerm_storage_account.security_storage_account.primary_blob_endpoint
  storage_account_access_key = azurerm_storage_account.security_storage_account.primary_access_key
  retention_in_days          = 90
}

resource "azurerm_mssql_server_extended_auditing_policy" "audit_mssql7" {
  server_id                  = azurerm_mssql_server.mssql7.id
  storage_endpoint           = azurerm_storage_account.security_storage_account.primary_blob_endpoint
  storage_account_access_key = azurerm_storage_account.security_storage_account.primary_access_key
  retention_in_days          = 90
}
