output "action_group_ids" {
  description = "Map of action group name to resource id."
  value       = module.action_group.ids
}

output "action_group_short_names" {
  description = "Map of action group name to short name."
  value       = module.action_group.short_names
}
