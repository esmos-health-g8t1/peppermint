terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# One-time import: peppermint-app was created before state was initialised.
# Safe to leave in permanently — Terraform skips it once the resource is in state.
import {
  id = "/subscriptions/d8470534-e61b-4809-8bf5-b9252347a1a8/resourceGroups/esmos-healthcare-rg/providers/Microsoft.App/containerApps/peppermint-app"
  to = azurerm_container_app.peppermint
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_container_app_environment" "env" {
  name                = var.aca_env_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_user_assigned_identity" "aca_identity" {
  name                = "aca-identity"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_container_app" "peppermint" {
  name                         = "peppermint-app"
  container_app_environment_id = data.azurerm_container_app_environment.env.id
  resource_group_name          = data.azurerm_resource_group.rg.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.aca_identity.id]
  }

  registry {
    server   = data.azurerm_container_registry.acr.login_server
    identity = data.azurerm_user_assigned_identity.aca_identity.id
  }

  ingress {
    external_enabled = true
    target_port      = 3000
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = 0
    max_replicas = 30

    container {
      name   = "peppermint"
      image  = "${data.azurerm_container_registry.acr.login_server}/peppermint:${var.image_tag}"
      cpu    = 0.5
      memory = "1.0Gi"

      env {
        name  = "DB_USERNAME"
        value = var.db_user
      }
      env {
        name  = "DB_PASSWORD"
        value = var.db_password
      }
      env {
        name  = "DB_HOST"
        value = var.db_host
      }
      env {
        name  = "DB_PORT"
        value = "6432" # PgBouncer — avoids connection exhaustion under load
      }
      env {
        name  = "DB_DATABASE"
        value = "peppermint"
      }
      env {
        name  = "SECRET"
        value = var.secret_key
      }
    }
  }
}
