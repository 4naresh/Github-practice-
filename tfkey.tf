provider "azurerm" {
  features {}
}

# Data block to reference an existing Key Vault
data "azurerm_key_vault" "existing_vault" {
  name                = "<existing-keyvault-name>"
  resource_group_name = "<resource-group-name>"
}

# Retrieve the list of keys in the existing Key Vault
data "azurerm_key_vault_key" "existing_keys" {
  for_each = toset(data.azurerm_key_vault.existing_vault.keys)

  name                = each.key
  key_vault_id        = data.azurerm_key_vault.existing_vault.id
}

# Apply the key rotation policy for existing keys
resource "azurerm_key_vault_key" "key_rotation" {
  for_each            = data.azurerm_key_vault.existing_vault.keys
  name                = each.value
  key_vault_id        = data.azurerm_key_vault.existing_vault.id
  key_type            = "RSA"  # Or use the appropriate key type, e.g., RSA, EC

  rotation_policy {
    enabled = true
    lifetime_actions {
      action {
        action_type = "Rotate"
        time_limit  = "30d"  # Set the rotation time to 30 days
      }
    }
  }
}
###########################################################################################

provider "azurerm" {
  features {}
}

# Retrieve the existing Key Vault
data "azurerm_key_vault" "example" {
  name                = "<existing-keyvault-name>"
  resource_group_name = "<resource-group-name>"
}

# Define the Key Vault Key Rotation Policy for the keys in the existing Key Vault
resource "azurerm_key_vault_key" "key_rotation" {
  for_each            = { for key in data.azurerm_key_vault.example.keys : key.id => key }
  name                = each.key.name
  key_vault_id        = data.azurerm_key_vault.example.id
  key_type            = each.key.key_type
  rotation_policy {
    enabled = true
    lifetime_actions {
      action {
        action_type = "Rotate"
        time_limit  = "30d"  # Set the rotation time to 30 days
      }
    }
  }
}
