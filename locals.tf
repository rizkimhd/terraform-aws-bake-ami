locals {
  bake_project_name = var.architecture == "x86_64" ?  "${var.service_name}-bake-ami" : "${var.service_name}_${var.architecture}-bake-ami"
  pipeline_name     = var.architecture == "x86_64" ?  "${var.service_name}-ami-baking" : "${var.service_name}_${var.architecture}-ami-baking"
  user_parameters = {
    "slack_channel"  = var.slack_channel
    "targetAccounts" = var.target_accounts
  }
  
  aws_instance_type = var.architecture == "x86_64" ? "t3.nano" : "t4g.nano"
  app_ami_suffix    = var.architecture == "x86_64" ? "/hvm/x86_64" : "/hvm/aarch64"

  common_tags = {
    ProductDomain = var.product_domain
    Service       = var.service_name
    Environment   = var.environment
    Architecture  = var.architecture
    ManagedBy     = "terraform"
  }

  cwl_log_group_tags = merge(
    local.common_tags,
    var.cwl_log_group_additional_tags,
    { "Name" = "/aws/codebuild/${local.bake_project_name}" },
    { "Description" = "LogGroup for ${var.service_name} Bake AMI" },
  )

  codebuild_tags = merge(
    local.common_tags,
    var.codebuild_additional_tags,
    { "Name" = local.bake_project_name },
    { "Description" = "Bake ${var.service_name} AMI" },
  )

  codepipeline_tags = merge(
    local.common_tags,
    var.codebuild_additional_tags,
    { "Name" = local.pipeline_name },
    { "Description" = "${var.service_name} AMI Baking Pipeline" },
  )

  ami_baking_buildspec = templatefile("${path.module}/ami_baking_buildspec.tftpl", {
    ami_baking_artifact_bucket = var.engineering_manifest_bucket
    ami_baking_project_name    = local.bake_project_name
    template_instance_profile  = var.template_instance_profile
    template_instance_sg       = var.template_instance_sg
    base_ami_owners            = join(",", var.base_ami_owners)
    base_ami_prefix            = var.base_ami_prefix
    app_ami_prefix             = var.app_ami_prefix
    app_ami_suffix             = coalesce(var.app_ami_suffix, local.app_ami_suffix)
    aws_instance_type          = coalesce(var.aws_instance_type, local.aws_instance_type)
    subnet_id                  = var.subnet_id
    vpc_id                     = var.vpc_id
    region                     = data.aws_region.current.name
  })
}
