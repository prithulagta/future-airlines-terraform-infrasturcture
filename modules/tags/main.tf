data "aws_caller_identity" "current" {}

locals {

    acc = "${data.aws_caller_identity.current.account_id}"

     business_tags = "${map (
      "costcenter"         , "${var.cost_centre}",
      "brand"              , "${var.brand}",
      "project"            , "${var.project}",
      "team"               , "${var.team}"
    
    )}"

    technical_tags = "${ 
    map (
      "account"         , "${local.acc}",
      "environment"     , "${var.environment}",
      "application"     , "${var.application}",
      "region"          , "${var.region}",
      "terraform"       , "true"
    )
  }"
  tags = "${ merge(
      local.technical_tags, local.business_tags,)
    }"
 }