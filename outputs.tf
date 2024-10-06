output "action_group_id" {
  description = "The ID of the Azure Monitor Action Group"
  value       = { for name, ag in azurerm_monitor_action_group.this : name => ag.id }
}

output "action_group_location" {
  description = "The location of the Azure Monitor Action Group"
  value       = { for name, ag in azurerm_monitor_action_group.this : name => ag.location }
}

output "action_group_name" {
  description = "The name of the Azure Monitor Action Group"
  value       = { for name, ag in azurerm_monitor_action_group.this : name => ag.name }
}

output "action_group_resource_group_name" {
  description = "The resource group name where the Azure Monitor Action Group is located"
  value       = { for name, ag in azurerm_monitor_action_group.this : name => ag.resource_group_name }
}

output "action_group_tags" {
  description = "The tags of the Azure Monitor Action Group"
  value       = { for name, ag in azurerm_monitor_action_group.this : name => ag.tags }
}
