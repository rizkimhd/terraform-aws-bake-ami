resource "aws_cloudwatch_log_group" "bake_ami" {
  name              = "/aws/codebuild/${local.bake_project_name}"
  retention_in_days = var.log_retention_in_days
  tags              = local.cwl_log_group_tags
}

resource "aws_codebuild_project" "bake_ami" {
  name         = local.bake_project_name
  description  = "Bake ${var.service_name} AMI"
  service_role = var.codebuild_role_arn

  artifacts {
    type           = "CODEPIPELINE"
    namespace_type = "BUILD_ID"
    packaging      = "ZIP"
  }

  cache {
    type     = var.codebuild_cache_bucket == "" ? "NO_CACHE" : "S3"
    location = "${var.codebuild_cache_bucket}/${local.bake_project_name}"
  }

  environment {
    compute_type                = var.bake_codebuild_compute_type
    image                       = var.bake_codebuild_image
    image_pull_credentials_type = var.bake_codebuild_image_credentials
    type                        = var.bake_codebuild_environment_type
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = local.ami_baking_buildspec
  }

  tags = local.codebuild_tags
}

resource "aws_codepipeline" "bake_ami" {
  count = var.codepipeline_role_arn == null ? 0 : 1

  name     = local.pipeline_name
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.codepipeline_artifact_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Playbook"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["Playbook"]

      configuration = {
        S3Bucket             = var.playbook_bucket
        PollForSourceChanges = var.codepipeline_poll_for_source_changes
        S3ObjectKey          = var.playbook_key
      }

      run_order = "1"
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Bake"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["Playbook"]
      output_artifacts = ["PackerManifest", "BuildManifest"]
      version          = "1"

      configuration = {
        ProjectName = local.bake_project_name
      }

      run_order = "1"
    }

    action {
      name            = "Share"
      category        = "Invoke"
      owner           = "AWS"
      provider        = "Lambda"
      input_artifacts = ["PackerManifest", "Playbook"]
      version         = "1"

      configuration = {
        FunctionName   = var.lambda_function_name
        UserParameters = jsonencode(local.user_parameters)
      }

      run_order = "2"
    }
  }

  tags = local.codepipeline_tags
}

resource "aws_cloudwatch_event_rule" "this" {
  count = var.events_role_arn == null ? 0 : 1

  name        = "${local.pipeline_name}-trigger"
  description = "Capture each s3://${var.playbook_bucket}/${var.playbook_key} upload"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.s3"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "s3.amazonaws.com"
    ],
    "eventName": [
      "PutObject",
      "CompleteMultipartUpload"
    ],
    "resources": {
      "ARN": [
        "arn:aws:s3:::${var.playbook_bucket}/${var.playbook_key}"
      ]
    }
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "this" {
  count = var.events_role_arn == null ? 0 : 1

  rule = aws_cloudwatch_event_rule.this[0].name
  arn  = aws_codepipeline.bake_ami[0].arn

  role_arn = var.events_role_arn
}
