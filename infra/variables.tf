variable "resource_group_name" {
    description = "The name of the resource group"
    type        = string
}

variable "location" {
    description = "The location of the resources"
    type        = string
}

variable "vnet_name" {
    description = "The name of the virtual network"
    type        = string
}

variable "vnet_address_space" {
    description = "The address space of the virtual network"
    type        = list(string)
}

variable "app_gateway_subnet_name" {
    description = "The name of the subnet"
    type        = string
}

variable "app_gateway_subnet_address_prefixes" {
    description = "The address prefixes of the subnet"
    type        = list(string)
}

variable "app_insights_name" {
    description = "The name of the Application Insights"
    type        = string
}

variable "app_service_plan_name" {
    description = "The name of the App Service Plan"
    type        = string
}

variable "app_service_plan_sku_name" {
    description = "The tier of the App Service Plan"
    type        = string
}

variable "app_service_plan_os_type" {
    description = "The size of the App Service Plan"
    type        = string
}

variable "app_service_name" {
    description = "The name of the App Service"
    type        = string
}

variable "app_gateway_public_ip_name" {
    description = "The name of the Public IP"
    type        = string
}

variable "app_gateway_name" {
    description = "The name of the Application Gateway"
    type        = string
}

variable "app_gateway_sku_name" {
    description = "The SKU name of the Application Gateway"
    type        = string
    default     = "Standard_v2"
}

variable "app_gateway_sku_tier" {
    description = "The SKU tier of the Application Gateway"
    type        = string
    default     = "Standard_v2"
}

variable "app_gateway_capacity" {
    description = "The capacity of the Application Gateway"
    type        = number
    default     = 2
}

