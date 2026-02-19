#####################################################################
# Block-1: Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0"
    }
  }
  # # Terraform State Storage to Azure Storage Container
  # backend "azurerm" {
  #   resource_group_name  = "terraform-storage-rg"
  #   storage_account_name = "terraformstate201111"
  #   container_name       = "tfstatefiles"
  #   key                  = "terraform.tfstate"
  # }
}
# create a resource group for terraform state storage
resource "azurerm_resource_group" "tfstate_rg" {
  name     = "terraform-storage-rg"
  location = "eastus"
}
# create a storage account for terraform state storage
resource "azurerm_storage_account" "tfstate_sa" {
  name                     = "terraformstate201111"
  resource_group_name      = azurerm_resource_group.tfstate_rg.name
  location                 = azurerm_resource_group.tfstate_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
# create a storage container for terraform state storage
resource "azurerm_storage_container" "tfstate_container" {
  name                  = "tfstatefiles"
  storage_account_name  = azurerm_storage_account.tfstate_sa.name
  container_access_type = "private"
}
#####################################################################
# Block-2: Provider Block
provider "azurerm" {
  features {}
}
#####################################################################
# Block-3: Resource Block
# Create a resource group
resource "azurerm_resource_group" "myrg" {
  name     = "myrg-1"
  location = var.azure_region
}
# Create Virtual Network
resource "azurerm_virtual_network" "myvnet" {
  name                = "myvnet-1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
}
#####################################################################
# Block-4: Input Variables Block
# Define a Input Variable for Azure Region 
variable "azure_region" {
  default     = "eastus"
  description = "Azure Region where resources to be created"
  type        = string
}
# Define a Input Variable for Business Unit
variable "business_unit" {
  description = "Business unit name"
  type        = string
}
# Define a Input Variable for Environment Name
variable "environment_name" {
  description = "Environment name"
  type        = string
}
#####################################################################
# Block-5: Output Values Block
# Output the Azure Resource Group ID 
output "azure_resourcegroup_id" {
  description = "My Azure Resource Group ID"
  value       = azurerm_resource_group.myrg.id
}
#####################################################################
# Block-6: Local Values Block
# Define Local Value with Business Unit and Environment Name combined
locals {
  name = "${var.business_unit}-${var.environment_name}"
}
#####################################################################
# Block-7: Data sources Block
# Use this data source to access information about an existing Resource Group.
data "azurerm_resource_group" "example" {
  name = "existing"
}
output "id" {
  value = data.azurerm_resource_group.example.id
}
#####################################################################
# Block-8: Modules Block
# Azure Virtual Network Block using Terraform Modules (https://registry.terraform.io/modules/Azure/network/azurerm/latest)
module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.example.name
  address_spaces      = ["10.0.0.0/16", "10.2.0.0/16"]
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["subnet1", "subnet2", "subnet3"]

  tags = {
    environment = "dev"
    costcenter  = "it"
  }

  use_for_each = false

  #depends_on = [azurerm_resource_group.example]
}
#####################################################################
