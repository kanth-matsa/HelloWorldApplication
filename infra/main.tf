terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~> 3.0"
        }
    }

    required_version = ">= 1.0.0"
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "rg" {
    name     = var.resource_group_name
    location = var.location
}

resource "azurerm_virtual_network" "vnet" {
    name                = var.vnet_name
    address_space       = var.vnet_address_space
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "appgw_subnet" {
    name                 = var.app_gateway_subnet_name
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = var.app_gateway_subnet_address_prefixes
}

resource "azurerm_public_ip" "appgw_public_pip" {
    name                = var.app_gateway_public_ip_name
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Static"
    sku                 = "Standard
}

resource "azurerm_application_insights" "appinsights" {
    name                = var.appinsights_name
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    application_type    = "web"
}

resource "azurerm_service_plan" "asp" {
    name                = var.app_service_plan_name
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku_name            = var.app_service_plan_sku_name
    os_type             = var.app_service_plan_os_type
}

resource "azurerm_linux_web_app" "appservice" {
    name                = var.app_service_name
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    app_service_plan_id = azurerm_service_plan.asp.id

    app_settings = {
        "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.appinsights.instrumentation_key
    }

    site_config {
        ip_restriction_default_action = "Deny"
        ip_restriction {
            name                 = "allow_app_gateway"
            ip_address           = "${azurerm_public_ip.appgw_public_pip.ip_address}/32"
            action               = "Allow"
            priority             = 100
            headers = []
        }
    }

    connection_string = {
        name = "AppInsights"
        type = "Custom"
        value = azurerm_application_insights.appinsights.instrumentation_key
    }
}

resource "azurerm_application_gateway" "appgw" {
    name                = var.app_gateway_name
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku {
        name     = var.app_gateway_sku_name
        tier     = var.app_gateway_sku_tier
        capacity = var.app_gateway_capacity
    }

    gateway_ip_configuration {
        name      = "appGatewayIpConfig"
        subnet_id = azurerm_subnet.appgw_subnet.id
    }

    frontend_port {
        name = "frontendPort"
        port = 80
    }

    frontend_ip_configuration {
        name                 = "frontendIpConfig"
        public_ip_address_id = azurerm_public_ip.appgw_public_pip.id
    }

    backend_address_pool {
        name = "backendAddressPool"
        fqdns = [${azurerm_linux_web_app.appservice.name}.azurewebsites.net]
    }    
    
    backend_http_settings {
        name                  = "backendHttpSettings"
        cookie_based_affinity = "Disabled"
        port                  = 80
        protocol              = "Http"
        request_timeout       = 20
        pick_host_name_from_backend_address = true
        probe_name = "backendhealthprobe"
    }

    http_listener {
        name                           = "http-listener"
        frontend_ip_configuration_name = "frontendIpConfig"
        frontend_port_name             = "frontendPort"
        protocol                       = "Http"
    }

    request_routing_rule {
        name                       = "routingRule"
        rule_type                  = "Basic"
        http_listener_name         = "httpListener"
        backend_address_pool_name  = "backendAddressPool"
        backend_http_settings_name = "backendHttpSettings"
        priority = 100
    }

    probe {
        name                = "backendhealthprobe"
        protocol            = "Http"
        path                = "/"
        interval            = 30
        timeout             = 120
        unhealthy_threshold = 3
        pick_host_name_from_backend_http_settings = true

        match {
            status_code = ["200-999"]
        }
    }
}