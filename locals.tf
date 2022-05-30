locals {
  bake_project_name = "${var.service_name}-bake-ami"
  pipeline_name     = "${var.service_name}-ami-baking"
  user_parameters = {
    "slack_channel"  = "${var.slack_channel}"
    "targetAccounts" = "${var.target_accounts}"
  }

  ami_baking_buildspec = templatefile("${path.module}/ami_baking_buildspec.tftpl", {
    ami_baking_artifact_bucket = "${var.engineering_manifest_bucket}"
    ami_baking_project_name    = "${local.bake_project_name}"
    template_instance_profile  = "${var.template_instance_profile}"
    template_instance_sg       = "${var.template_instance_sg}"
    base_ami_owners            = "${join(",", var.base_ami_owners)}"
    base_ami_prefix            = "${var.base_ami_prefix}"
    app_ami_prefix             = "${var.app_ami_prefix}"
    subnet_id                  = "${var.subnet_id}"
    vpc_id                     = "${var.vpc_id}"
    region                     = "${data.aws_region.current.name}"
  })
}
