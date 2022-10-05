variable "service_name" {
  type        = string
  description = "the name of the service"
}

variable "product_domain" {
  type        = string
  description = "the owner of this pipeline (e.g. team). This is used mostly for adding tags to resources"
}

variable "environment" {
  type        = string
  default     = "special"
  description = "The environment where this ami baking pipeline is provisioned"
}

variable "architecture" {
  type        = string
  default     = "x86_64"
  description = "The architecture used by the codebuild and the generated image. Valid options are x86_64/aarch64"
}

variable "base_ami_owners" {
  type        = list(string)
  description = "the owners (AWS account IDs) of the base AMIs that instances will be run from"
}

variable "base_ami_prefix" {
  type        = string
  description = "The latest AMI which name follows this prefix will be used as the base AMI of your app AMI"
}

variable "app_ami_prefix" {
  type        = string
  description = "The created app AMI will be named with this prefix"
}

variable "app_ami_suffix" {
  type        = string
  description = "The latest AMI which name follows this suffix will be used as the base AMI of your app AMI"
  default     = ""
}

variable "aws_instance_type" {
  type        = string
  description = "AWS instance type that will be used for AMI baking"
  default     = ""
}

variable "playbook_bucket" {
  type        = string
  description = "the S3 bucket that contains the AMI baking playbook"
}

variable "playbook_key" {
  type        = string
  description = "the S3 key of the AMI baking playbook that will be used as the pipeline input. CodeBuild doesn't seem to support tar files"
}

variable "vpc_id" {
  type        = string
  description = "the id of the VPC where AMI baking instances will reside on"
}

variable "subnet_id" {
  type        = string
  description = "the id of the subnet where AMI baking instances will reside on"
}

variable "bake_codebuild_compute_type" {
  type        = string
  description = "https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "engineering_manifest_bucket" {
  type        = string
  description = "the bucket where ami build manifests will be uploaded to"
}

variable "bake_codebuild_image" {
  type        = string
  description = "https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html"
  default     = "015110552125.dkr.ecr.ap-southeast-1.amazonaws.com/bei-codebuild-ami-baking-app:1.3.0"
}

variable "bake_codebuild_image_credentials" {
  type        = string
  default     = "SERVICE_ROLE"
  description = "Credentials to be used to pull codebuild environment image"
}

variable "bake_codebuild_environment_type" {
  type        = string
  description = "https://docs.aws.amazon.com/codebuild/latest/userguide/create-project.html#create-project-cli"
  default     = "LINUX_CONTAINER"
}

variable "codepipeline_artifact_bucket" {
  type        = string
  description = "An S3 bucket to be used as CodePipeline's artifact bucket"
}

variable "codebuild_cache_bucket" {
  type        = string
  description = "An S3 bucket to be used as CodeBuild's cache bucket"

  # default to no cache
  default = ""
}

variable "template_instance_profile" {
  type        = string
  description = "The name of the instance profile with which AMI baking instances will run"
}

variable "template_instance_sg" {
  type        = string
  description = "The id of the security group with which AMI baking instances will run"
}

variable "codebuild_role_arn" {
  type        = string
  description = "The role arn to be assumed by the codebuild project"
}

variable "codepipeline_role_arn" {
  type        = string
  description = "The role arn to be assumed by the codepipeline"
  default     = null
}

variable "lambda_function_name" {
  type        = string
  description = "The name of the AMI sharing lambda function"
}

variable "events_role_arn" {
  type        = string
  description = "The role arn to be assumed by the cloudwatch events rule"
  default     = null
}

variable "slack_channel" {
  type        = string
  description = "The name of the slack channel to which baked AMI IDs will be sent"
}

variable "codepipeline_poll_for_source_changes" {
  type        = string
  description = "Whether or not the pipeline should poll for source changes"
  default     = "false"
}

variable "target_accounts" {
  type        = list(string)
  description = "The list of AWS accounts to which AMIs will be shared"
  default     = []
}

variable "log_retention_in_days" {
  type        = number
  description = "Cloudwatch log retention for ami-baking"
  default     = 30
}

variable "cwl_log_group_additional_tags" {
  type        = map(string)
  description = "The list of tags to be attached to the cloudwatch log groups"
  default     = {}
}

variable "codebuild_additional_tags" {
  type        = map(string)
  description = "The list of tags to be attached to the codebuild project"
  default     = {}
}

variable "codepipeline_additional_tags" {
  type        = map(string)
  description = "The list of tags to be attached to the codepipeline"
  default     = {}
}
