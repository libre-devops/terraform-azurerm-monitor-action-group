output "ids" {
  description = "Map of action group name to its resource id."
  value       = { for k, v in azurerm_monitor_action_group.this : k => v.id }
}

output "ids_zipmap" {
  description = "Map of action group name to a { name, id } object, for passing where both are needed together."
  value       = { for k, v in azurerm_monitor_action_group.this : k => { name = v.name, id = v.id } }
}

output "names" {
  description = "The action group names."
  value       = keys(azurerm_monitor_action_group.this)
}

output "resource_group_name" {
  description = "Resource group name parsed from resource_group_id."
  value       = local.rg_name
}

output "short_names" {
  description = "Map of action group name to its short name."
  value       = { for k, v in azurerm_monitor_action_group.this : k => v.short_name }
}

output "subscription_id" {
  description = "Subscription id parsed from resource_group_id."
  value       = local.rg.subscription_id
}

output "tags" {
  description = "The tags applied to the action groups."
  value       = var.tags
}
