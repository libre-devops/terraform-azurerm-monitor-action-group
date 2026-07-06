<!--
  Header for the complete example README. Edit this file, then run `just docs`
  (or ./Sort-LdoTerraform.ps1 -IncludeExamples) to regenerate the section between the markers.
  The example's main.tf is embedded into the README automatically (see .terraform-docs.yml).
-->
<div align="center">
  <a href="https://libredevops.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
      <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="200">
    </picture>
  </a>
</div>

# Complete example

The appliable receiver surface: a paging group fanning out to email (including one legacy-schema
opt-out, which the check surfaces), SMS and voice on Ofcom-reserved test numbers, a webhook, the
Monitoring Reader ARM role, and the Azure mobile app, plus a second group showing enabled = false
(silenced without unwiring). Receivers needing live backing resources (event hub, function, logic
app, runbook, ITSM) are covered by the mocked tests. The environment comes from the Terraform
workspace (`terraform.workspace`), not a variable. Run it with `just e2e complete`, which applies
the stack then always destroys it.

[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)
