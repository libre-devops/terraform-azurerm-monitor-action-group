locals {
  location = lookup(var.regions, var.loc, "uksouth")
  rg_name  = "rg-${var.short}-${var.loc}-${terraform.workspace}-002"
  ag_page  = "ag-${var.short}-${var.loc}-${terraform.workspace}-002"
  ag_quiet = "ag-${var.short}-${var.loc}-${terraform.workspace}-003"
}

module "tags" {
  source  = "libre-devops/tags/azurerm"
  version = "~> 4.0"

  cost_centre     = "1888/67"
  owner           = "platform@example.com"
  deployed_branch = var.deployed_branch
  deployed_repo   = var.deployed_repo
  additional_tags = { Application = "terraform-azurerm-monitor-action-group" }
}

module "rg" {
  source  = "libre-devops/rg/azurerm"
  version = "~> 4.0"

  resource_groups = [{ name = local.rg_name, location = local.location, tags = module.tags.tags }]
}

# Complete call: the appliable receiver surface. The paging group fans out to email, a webhook,
# the Monitoring Reader ARM role, and the Azure mobile app; the second group shows enabled = false, silencing without unwiring (its alerts
# park until re-enabled). Receivers needing live backing resources (event hub, function, logic
# app, runbook, ITSM) are covered by the mocked tests; the logic app receiver gets its live outing
# in the logic-app-workflow module's alert-storm example.
module "action_group" {
  source = "../../"

  resource_group_id = module.rg.ids[local.rg_name]
  tags              = module.tags.tags

  action_groups = {
    (local.ag_page) = {
      short_name = "page-oncall"

      email_receivers = [
        { name = "Notify_oncall_mailbox", email_address = "oncall@example.com" },
        { name = "Notify_platform_lead_legacy_schema", email_address = "lead@example.com", use_common_alert_schema = false },
      ]

      # SMS and voice receivers are mocked-test-only: Azure validates numbers against real
      # numbering plans (PhoneNumberIsNotValid for Ofcom's reserved drama range, proven live), so
      # a runnable example would need a real phone number.
      webhook_receivers = [
        { name = "Post_to_incident_bridge_webhook", service_uri = "https://example.com/hooks/incident-bridge" }
      ]

      arm_role_receivers = [
        # Monitoring Reader, GUID verified with: az role definition list --name "Monitoring Reader"
        { name = "Notify_monitoring_readers", role_id = "43d0d8ad-25c7-4714-9337-8ba259a9fe05" }
      ]

      azure_app_push_receivers = [
        { name = "Push_to_azure_mobile_app", email_address = "oncall@example.com" }
      ]
    }

    (local.ag_quiet) = {
      short_name = "maint-quiet"
      enabled    = false

      email_receivers = [
        { name = "Notify_platform_team_mailbox", email_address = "platform@example.com" }
      ]
    }
  }
}
