variable "action_groups" {
  description = <<-EOT
    Action groups keyed by name (ag-ldo-uks-prd-001). Every receiver type is a list; receivers
    that support the common alert schema default it to true (the modern payload downstream tools
    expect; opting out is surfaced by a check). Fields:
      short_name   1 to 12 characters, shown in SMS and email notifications (required).
      enabled      Defaults to true; false silences the group without unwiring it.
      *_receivers  email, sms, voice, webhook (with optional AAD auth), event_hub, azure_function,
                   logic_app, automation_runbook, arm_role, azure_app_push, itsm.
  EOT
  type = map(object({
    short_name = string
    enabled    = optional(bool, true)
    tags       = optional(map(string))

    email_receivers = optional(list(object({
      name                    = string
      email_address           = string
      use_common_alert_schema = optional(bool, true)
    })), [])

    sms_receivers = optional(list(object({
      name         = string
      country_code = string
      phone_number = string
    })), [])

    voice_receivers = optional(list(object({
      name         = string
      country_code = string
      phone_number = string
    })), [])

    webhook_receivers = optional(list(object({
      name                    = string
      service_uri             = string
      use_common_alert_schema = optional(bool, true)
      aad_auth = optional(object({
        object_id      = string
        identifier_uri = optional(string)
        tenant_id      = optional(string)
      }))
    })), [])

    event_hub_receivers = optional(list(object({
      name                    = string
      event_hub_namespace     = string
      event_hub_name          = string
      subscription_id         = optional(string)
      tenant_id               = optional(string)
      use_common_alert_schema = optional(bool, true)
    })), [])

    azure_function_receivers = optional(list(object({
      name                     = string
      function_app_resource_id = string
      function_name            = string
      http_trigger_url         = string
      use_common_alert_schema  = optional(bool, true)
    })), [])

    logic_app_receivers = optional(list(object({
      name                    = string
      resource_id             = string
      callback_url            = string
      use_common_alert_schema = optional(bool, true)
    })), [])

    automation_runbook_receivers = optional(list(object({
      name                    = string
      automation_account_id   = string
      runbook_name            = string
      webhook_resource_id     = string
      is_global_runbook       = optional(bool, false)
      service_uri             = string
      use_common_alert_schema = optional(bool, true)
    })), [])

    arm_role_receivers = optional(list(object({
      name                    = string
      role_id                 = string
      use_common_alert_schema = optional(bool, true)
    })), [])

    azure_app_push_receivers = optional(list(object({
      name          = string
      email_address = string
    })), [])

    itsm_receivers = optional(list(object({
      name                 = string
      connection_id        = string
      workspace_id         = string
      ticket_configuration = string
      region               = string
    })), [])
  }))
  default = {}

  validation {
    condition     = alltrue([for g in values(var.action_groups) : length(g.short_name) >= 1 && length(g.short_name) <= 12])
    error_message = "short_name must be 1 to 12 characters (it is what SMS and email notifications display)."
  }

  validation {
    condition = alltrue(flatten([
      for g in values(var.action_groups) : [
        for r in concat(g.sms_receivers, g.voice_receivers) : can(regex("^[0-9]+$", r.country_code))
      ]
    ]))
    error_message = "sms and voice receiver country_code is digits only (44, 1, ...)."
  }

  validation {
    condition = alltrue(flatten([
      for g in values(var.action_groups) : [
        for r in g.arm_role_receivers : can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", r.role_id))
      ]
    ]))
    error_message = "arm_role receiver role_id is the role definition GUID (43d0d8ad-25c7-4714-9337-8ba259a9fe05 for Monitoring Reader), not a full resource id."
  }
}

variable "location" {
  description = "Azure region for the action groups. Action groups are a global service; the default is the literal \"global\", and regional values exist only for the regional-processing preview."
  type        = string
  default     = "global"
}

variable "resource_group_id" {
  description = "Resource id of the resource group the action groups are created in. The resource group name and subscription are parsed from this id."
  type        = string

  validation {
    condition     = try(provider::azurerm::parse_resource_id(var.resource_group_id).resource_type, "") == "resourceGroups"
    error_message = "resource_group_id must be a resource group resource id."
  }
}

variable "tags" {
  description = "Tags applied to the action groups (unless a group sets its own)."
  type        = map(string)
  default     = {}
}
