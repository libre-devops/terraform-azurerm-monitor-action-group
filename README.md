```hcl
resource "azurerm_monitor_action_group" "this" {
  for_each = { for group in var.action_groups : group.name => group }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  short_name          = each.value.short_name != null ? each.value.short_name : "agazuremonitor"
  tags                = each.value.tags

  dynamic "arm_role_receiver" {
    for_each = each.value.arm_role_receiver != null ? each.value.arm_role_receiver : []
    content {
      name                    = arm_role_receiver.value.name
      role_id                 = arm_role_receiver.value.role_id
      use_common_alert_schema = arm_role_receiver.value.use_common_alert_schema
    }
  }

  dynamic "automation_runbook_receiver" {
    for_each = each.value.automation_runbook_receiver != null ? each.value.automation_runbook_receiver : []
    content {
      name                    = automation_runbook_receiver.value.name
      automation_account_id   = automation_runbook_receiver.value.automation_account_id
      runbook_name            = automation_runbook_receiver.value.runbook_name
      webhook_resource_id     = automation_runbook_receiver.value.webhook_resource_id
      is_global_runbook       = automation_runbook_receiver.value.is_global_runbook
      service_uri             = automation_runbook_receiver.value.service_uri
      use_common_alert_schema = automation_runbook_receiver.value.use_common_alert_schema
    }
  }

  dynamic "azure_app_push_receiver" {
    for_each = each.value.azure_app_push_receiver != null ? each.value.azure_app_push_receiver : []
    content {
      name          = azure_app_push_receiver.value.name
      email_address = azure_app_push_receiver.value.email_address
    }
  }

  dynamic "azure_function_receiver" {
    for_each = each.value.azure_function_receiver != null ? each.value.azure_function_receiver : []
    content {
      name                     = azure_function_receiver.value.name
      function_app_resource_id = azure_function_receiver.value.function_app_resource_id
      function_name            = azure_function_receiver.value.function_name
      http_trigger_url         = azure_function_receiver.value.http_trigger_url
      use_common_alert_schema  = azure_function_receiver.value.use_common_alert_schema
    }
  }

  dynamic "email_receiver" {
    for_each = each.value.email_receiver != null ? each.value.email_receiver : []
    content {
      name                    = email_receiver.value.name
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = email_receiver.value.use_common_alert_schema
    }
  }

  dynamic "event_hub_receiver" {
    for_each = each.value.event_hub_receiver != null ? each.value.event_hub_receiver : []
    content {
      name                    = event_hub_receiver.value.name
      event_hub_name          = event_hub_receiver.value.event_hub_name
      event_hub_namespace     = event_hub_receiver.value.event_hub_namespace
      subscription_id         = event_hub_receiver.value.subscription_id
      tenant_id               = event_hub_receiver.value.tenant_id
      use_common_alert_schema = event_hub_receiver.value.use_common_alert_schema
    }
  }

  dynamic "itsm_receiver" {
    for_each = each.value.itsm_receiver != null ? each.value.itsm_receiver : []
    content {
      name                 = itsm_receiver.value.name
      workspace_id         = itsm_receiver.value.workspace_id
      connection_id        = itsm_receiver.value.connection_id
      ticket_configuration = itsm_receiver.value.ticket_configuration
      region               = itsm_receiver.value.region
    }
  }

  dynamic "logic_app_receiver" {
    for_each = each.value.logic_app_receiver != null ? each.value.logic_app_receiver : []
    content {
      name                    = logic_app_receiver.value.name
      resource_id             = logic_app_receiver.value.resource_id
      callback_url            = logic_app_receiver.value.callback_url
      use_common_alert_schema = logic_app_receiver.value.use_common_alert_schema
    }
  }

  dynamic "sms_receiver" {
    for_each = each.value.sms_receiver != null ? each.value.sms_receiver : []
    content {
      name         = sms_receiver.value.name
      country_code = sms_receiver.value.country_code
      phone_number = sms_receiver.value.phone_number
    }
  }

  dynamic "voice_receiver" {
    for_each = each.value.voice_receiver != null ? each.value.voice_receiver : []
    content {
      name         = voice_receiver.value.name
      country_code = voice_receiver.value.country_code
      phone_number = voice_receiver.value.phone_number
    }
  }

  dynamic "webhook_receiver" {
    for_each = each.value.webhook_receiver != null ? each.value.webhook_receiver : []
    content {
      name                    = webhook_receiver.value.name
      service_uri             = webhook_receiver.value.service_uri
      use_common_alert_schema = webhook_receiver.value.use_common_alert_schema

      dynamic "aad_auth" {
        for_each = webhook_receiver.value.aad_auth != null ? [webhook_receiver.value.aad_auth] : []
        content {
          object_id      = aad_auth.value.object_id
          identifier_uri = aad_auth.value.identifier_uri
          tenant_id      = aad_auth.value.tenant_id
        }
      }
    }
  }
}
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_action_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action_groups"></a> [action\_groups](#input\_action\_groups) | List of Azure Monitor Action Groups configurations | <pre>list(object({<br>    name                = string<br>    resource_group_name = string<br>    location            = string<br>    tags                = map(string)<br>    short_name          = optional(string)<br>    enabled             = optional(bool, true)<br><br>    arm_role_receiver = optional(list(object({<br>      name                    = string<br>      role_id                 = string<br>      use_common_alert_schema = optional(bool)<br>    })))<br><br>    automation_runbook_receiver = optional(list(object({<br>      name                    = string<br>      automation_account_id   = string<br>      runbook_name            = string<br>      webhook_resource_id     = string<br>      is_global_runbook       = bool<br>      service_uri             = string<br>      use_common_alert_schema = optional(bool)<br>    })))<br><br>    azure_app_push_receiver = optional(list(object({<br>      name          = string<br>      email_address = string<br>    })))<br><br>    azure_function_receiver = optional(list(object({<br>      name                     = string<br>      function_app_resource_id = string<br>      function_name            = string<br>      http_trigger_url         = string<br>      use_common_alert_schema  = optional(bool)<br>    })))<br><br>    email_receiver = optional(list(object({<br>      name                    = string<br>      email_address           = string<br>      use_common_alert_schema = optional(bool)<br>    })))<br><br>    event_hub_receiver = optional(list(object({<br>      name                    = string<br>      event_hub_name          = optional(string)<br>      event_hub_namespace     = optional(string)<br>      subscription_id         = optional(string)<br>      tenant_id               = optional(string)<br>      use_common_alert_schema = optional(bool)<br>    })))<br><br>    itsm_receiver = optional(list(object({<br>      name                 = string<br>      workspace_id         = string<br>      connection_id        = string<br>      ticket_configuration = string<br>      region               = string<br>    })))<br><br>    logic_app_receiver = optional(list(object({<br>      name                    = string<br>      resource_id             = string<br>      callback_url            = string<br>      use_common_alert_schema = optional(bool)<br>    })))<br><br>    sms_receiver = optional(list(object({<br>      name         = string<br>      country_code = string<br>      phone_number = string<br>    })))<br><br>    voice_receiver = optional(list(object({<br>      name         = string<br>      country_code = string<br>      phone_number = string<br>    })))<br><br>    webhook_receiver = optional(list(object({<br>      name                    = string<br>      service_uri             = string<br>      use_common_alert_schema = optional(bool)<br>      aad_auth = optional(object({<br>        object_id      = string<br>        identifier_uri = optional(string)<br>        tenant_id      = optional(string)<br>      }))<br>    })))<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_action_group_id"></a> [action\_group\_id](#output\_action\_group\_id) | The ID of the Azure Monitor Action Group |
| <a name="output_action_group_location"></a> [action\_group\_location](#output\_action\_group\_location) | The location of the Azure Monitor Action Group |
| <a name="output_action_group_name"></a> [action\_group\_name](#output\_action\_group\_name) | The name of the Azure Monitor Action Group |
| <a name="output_action_group_resource_group_name"></a> [action\_group\_resource\_group\_name](#output\_action\_group\_resource\_group\_name) | The resource group name where the Azure Monitor Action Group is located |
| <a name="output_action_group_tags"></a> [action\_group\_tags](#output\_action\_group\_tags) | The tags of the Azure Monitor Action Group |
