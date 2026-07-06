# Plan-time tests for the module. The provider is mocked, so no credentials, no features block,
# and no cloud calls are needed:
#   terraform init -backend=false && terraform test

mock_provider "azurerm" {}

variables {
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ldo-uks-tst-01"

  action_groups = {
    "ag-ldo-uks-tst-01" = {
      short_name = "platform"

      email_receivers = [
        { name = "Notify_platform_team_mailbox", email_address = "platform@example.com" }
      ]

      webhook_receivers = [
        {
          name        = "Post_to_bridge_with_aad"
          service_uri = "https://example.com/hooks/bridge"
          aad_auth    = { object_id = "11111111-1111-1111-1111-111111111111" }
        }
      ]

      logic_app_receivers = [
        {
          name         = "Run_alert_storm_playbook"
          resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ldo-uks-tst-01/providers/Microsoft.Logic/workflows/logic-ldo-uks-tst-01"
          callback_url = "https://prod-00.uksouth.logic.azure.com/workflows/x/triggers/y/paths/invoke"
        }
      ]
    }
  }
}

# Defaults: enabled, global location, common alert schema on for supporting receivers.
run "sensible_defaults" {
  command = plan

  assert {
    condition     = azurerm_monitor_action_group.this["ag-ldo-uks-tst-01"].enabled == true
    error_message = "Action groups should be enabled by default."
  }

  assert {
    condition     = azurerm_monitor_action_group.this["ag-ldo-uks-tst-01"].location == "global"
    error_message = "Action groups should default to the global location."
  }

  assert {
    condition     = tolist(azurerm_monitor_action_group.this["ag-ldo-uks-tst-01"].email_receiver)[0].use_common_alert_schema == true
    error_message = "Receivers should default the common alert schema on."
  }

  assert {
    condition     = tolist(azurerm_monitor_action_group.this["ag-ldo-uks-tst-01"].webhook_receiver)[0].aad_auth[0].object_id == "11111111-1111-1111-1111-111111111111"
    error_message = "Webhook AAD auth should flow through."
  }

  assert {
    condition     = tolist(azurerm_monitor_action_group.this["ag-ldo-uks-tst-01"].logic_app_receiver)[0].use_common_alert_schema == true
    error_message = "Logic app receivers should default the common alert schema on."
  }
}

# The resource group is parsed from the id and exposed as an output.
run "parses_resource_group" {
  command = plan

  assert {
    condition     = output.resource_group_name == "rg-ldo-uks-tst-01"
    error_message = "resource_group_name should be parsed from resource_group_id."
  }
}

# Validation: short_name over 12 characters is rejected.
run "rejects_long_short_name" {
  command = plan

  variables {
    action_groups = {
      "ag-ldo-uks-tst-01" = {
        short_name      = "much-too-long-short-name"
        email_receivers = [{ name = "Notify_team", email_address = "team@example.com" }]
      }
    }
  }

  expect_failures = [var.action_groups]
}

# Validation: a non-numeric country code is rejected.
run "rejects_bad_country_code" {
  command = plan

  variables {
    action_groups = {
      "ag-ldo-uks-tst-01" = {
        short_name    = "platform"
        sms_receivers = [{ name = "Text_oncall", country_code = "+44", phone_number = "7700900123" }]
      }
    }
  }

  expect_failures = [var.action_groups]
}

# Validation: an ARM role receiver wants the role GUID, not a resource id.
run "rejects_role_resource_id" {
  command = plan

  variables {
    action_groups = {
      "ag-ldo-uks-tst-01" = {
        short_name = "platform"
        arm_role_receivers = [{
          name    = "Notify_monitoring_readers"
          role_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/43d0d8ad-25c7-4714-9337-8ba259a9fe05"
        }]
      }
    }
  }

  expect_failures = [var.action_groups]
}

# The empty-group check warns (legal, but visible).
run "warns_on_receiverless_group" {
  command = plan

  variables {
    action_groups = {
      "ag-ldo-uks-tst-01" = { short_name = "quiet" }
    }
  }

  expect_failures = [check.groups_have_receivers]
}
