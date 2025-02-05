output "resource_group_name" {
    value = azurerm_resource_group.rg.name
}

output "vnet_name" {
    value = azurerm_virtual_network.vnet.name
}

output "subnet_name" {
    value = azurerm_subnet.appgw_subnet.name
}

output "app_insights_name" {
    value = azurerm_application_insights.appinsights.name
}

output "app_service_plan_name" {
    value = azurerm_service_plan.asp.name
}

output "app_service_name" {
    value = azurerm_linux_web_app.appservice.name
}

output "appgw_public_pip_id" {
    value = azurerm_public_ip.appgw_public_pip.id
}

output "appgw_public_pip_ip_address" {
    value = azurerm_public_ip.appgw_public_pip.ip_address
}

output "app_gateway_name" {
    value = azurerm_application_gateway.appgw.name
}