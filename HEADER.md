<!--
  Keep the title and badges OUTSIDE the centered <div>: the Terraform Registry's markdown renderer
  does not parse markdown inside an HTML block, so a # heading or [![badge]] in the div renders as
  literal text on the registry. Only the logo (HTML) goes in the div.
-->
<div align="center">
  <a href="https://libredevops.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
      <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="300">
    </picture>
  </a>
</div>

# Terraform Azure Monitor Action Group

Azure Monitor action groups keyed by name, with every receiver type covered and the common alert
schema on by default.

[![CI](https://github.com/libre-devops/terraform-azurerm-monitor-action-group/actions/workflows/ci.yml/badge.svg)](https://github.com/libre-devops/terraform-azurerm-monitor-action-group/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/libre-devops/terraform-azurerm-monitor-action-group?sort=semver&label=release)](https://github.com/libre-devops/terraform-azurerm-monitor-action-group/releases/latest)
[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)
[![License](https://img.shields.io/github/license/libre-devops/terraform-azurerm-monitor-action-group)](./LICENSE)

---

## Overview

Action groups are the fan-out point of the monitoring estate: alert rules, smart detectors, and
Sentinel automation all end at one. The module keeps them boring and correct:

- **Every receiver type**: email, SMS, voice, webhook (with AAD auth), event hub, function, logic
  app, automation runbook, ARM role, Azure mobile app push, and ITSM, as typed lists.
- **Common alert schema on by default** wherever the receiver supports it, the structured payload
  downstream tooling expects; opting out is allowed and surfaced by a `check`.
- **Plan-time truth**: the 12-character `short_name` limit, digits-only country codes, and
  role-GUID-not-resource-id ARM role receivers are validated before Azure gets a say; receiverless
  groups (legal, occasionally deliberate) warn instead of failing.
- Groups are global (`location = "global"` default); `enabled = false` silences a group without
  unwiring it.

The resource group is passed by id and parsed.

## Usage

```hcl
module "action_group" {
  source  = "libre-devops/monitor-action-group/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids["rg-ldo-uks-prd-001"]
  tags              = module.tags.tags

  action_groups = {
    "ag-ldo-uks-prd-001" = {
      short_name = "page-oncall"

      email_receivers = [
        { name = "Notify_oncall_mailbox", email_address = "oncall@example.com" }
      ]

      logic_app_receivers = [
        {
          name         = "Run_alert_storm_playbook"
          resource_id  = module.logic_app_workflow.ids["logic-ldo-uks-prd-001"]
          callback_url = azurerm_logic_app_trigger_http_request.storm.callback_url
        }
      ]
    }
  }
}
```

## Examples

- [`examples/minimal`](./examples/minimal) - one group, one email receiver.
- [`examples/complete`](./examples/complete) - the appliable receiver surface (email, SMS and
  voice on Ofcom-reserved test numbers, webhook, ARM role, app push) plus a disabled group;
  receivers needing live backing resources are covered by the mocked tests, and the logic app
  receiver gets its live outing in the logic-app-workflow module's alert-storm example.

## Developing

Local work needs **PowerShell 7+** and **[`just`](https://github.com/casey/just)**, because the recipes
wrap the [LibreDevOpsHelpers](https://www.powershellgallery.com/packages/LibreDevOpsHelpers)
PowerShell module (the same engine the `libre-devops/terraform-azure` action runs in CI). Install
just with `brew install just`, or `uv tool add rust-just` then `uv run just <recipe>`.

Run `just` to list recipes: `just update-ldo-pwsh` (install or force-update LibreDevOpsHelpers from
PSGallery), `just validate`, `just scan` (Trivy only), `just pwsh-analyze` (PSScriptAnalyzer only),
`just plan`, `just apply`, `just destroy`, `just e2e`, `just test`, and `just docs` (the
plan/apply/destroy recipes mirror the action, including the storage firewall dance; `just e2e`
applies an example then always destroys it, defaulting to `minimal`, so nothing is left running).
Releasing is also `just`:
`just increment-release [patch|minor|major]` bumps, tags, and publishes a GitHub release, and the
Terraform Registry picks up the tag.

## Security scan exceptions

This module is scanned with [Trivy](https://github.com/aquasecurity/trivy); HIGH and CRITICAL
findings fail the build. Any waiver is a deliberate, reviewed decision, never a way to quiet a
finding that should be fixed. Waivers live in [`.trivyignore.yaml`](./.trivyignore.yaml) (the
machine-applied source of truth, passed to Trivy with `--ignorefile`) and are mirrored in the table
below so the reason is auditable.

| Trivy ID | Resource | Finding | Justification |
|----------|----------|---------|---------------|
| _None_   |          |         |               |

To add an exception: add an entry to `.trivyignore.yaml` (`id`, optional `paths` to scope it, and a
`statement` recording why), then add a matching row here. Where the finding is out of this module's
scope, point the justification at the Libre DevOps module that does address it (for example the
private-endpoint module). Both the file and this table are reviewed in the pull request.

## Reference

The Requirements, Providers, Inputs, Outputs, and Resources below are generated by `terraform-docs`.
