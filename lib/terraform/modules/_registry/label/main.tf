module "subcomponents" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  enabled = local.input.enabled

  attributes = local.input.subcomponents

  label_order = ["attributes"]
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  enabled = local.input.enabled

  namespace   = local.input.stack
  name        = local.input.component
  environment = local.input.environment
  attributes  = local.input.subcomponents

  label_order    = ["namespace", "name", "environment", "attributes"]
  labels_as_tags = ["name"]

  tags = {
    Provisioner  = "terraform"
    Repository   = local.input.repository
    Stack        = local.input.stack
    Component    = local.input.component
    Environment  = local.input.environment
    Subcomponent = module.subcomponents.id == "" ? null : module.subcomponents.id
  }
}
