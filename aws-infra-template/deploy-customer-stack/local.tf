locals {
  Client_Name        = var.client_name
  Client_Environment = var.client_environment

  Billing_Name = "${local.Client_Name}-${local.Client_Environment}"

  common_tags = {
    Client_Name        = local.Client_Name
    Client_Environment = local.Client_Environment
    Billing_Name       = local.Billing_Name
    Managed_By         = "Terraform"
  }
}
