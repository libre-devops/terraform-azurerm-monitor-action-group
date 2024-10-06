module "rg" {
  source = "libre-devops/rg/azurerm"

  rg_name  = "rg-${var.short}-${var.loc}-${var.env}-01"
  location = local.location
  tags     = local.tags
}

module "azure_monitor_action_groups" {
  source = "../../"

  action_groups = [
    {
      resource_group_name = module.rg.rg_name
      location            = module.rg.rg_location
      tags                = module.rg.rg_tags

      name       = "ag-${var.short}-${var.loc}-${var.env}-01"
      short_name = "${var.short}email"


      email_receiver = [
        {
          name                    = "alert-email-${var.short}-${var.loc}-${var.env}-01"
          email_address           = "example@libredevops.org"
          use_common_alert_schema = true
        }
      ]
    }
  ]
}
