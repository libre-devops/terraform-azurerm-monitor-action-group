# Post-plan sanity checks: informational (warn), they never fail an apply.

check "has_action_groups" {
  assert {
    condition     = length(var.action_groups) > 0
    error_message = "No action groups are defined: the module call creates nothing."
  }
}

# A group with no receivers fires into the void. Legal (sometimes used to deliberately silence a
# rule), but worth seeing.
check "groups_have_receivers" {
  assert {
    condition = alltrue([
      for g in values(var.action_groups) :
      length(concat(
        g.email_receivers, g.sms_receivers, g.voice_receivers, g.webhook_receivers,
        g.event_hub_receivers, g.azure_function_receivers, g.logic_app_receivers,
        g.automation_runbook_receivers, g.arm_role_receivers, g.azure_app_push_receivers,
        g.itsm_receivers,
      )) > 0
    ])
    error_message = "At least one action group has no receivers: alerts sent to it go nowhere."
  }
}

# Opting out of the common alert schema is visible: downstream tooling expects the structured
# payload, and mixed schemas in one group are a debugging trap.
check "common_alert_schema_optouts_are_visible" {
  assert {
    condition = alltrue(flatten([
      for g in values(var.action_groups) : [
        for r in concat(
          g.email_receivers, [for w in g.webhook_receivers : { use_common_alert_schema = w.use_common_alert_schema }],
          g.event_hub_receivers, g.azure_function_receivers, g.logic_app_receivers,
          g.automation_runbook_receivers, g.arm_role_receivers,
        ) : r.use_common_alert_schema
      ]
    ]))
    error_message = "At least one receiver opts out of the common alert schema: expect the legacy payload shape there."
  }
}
