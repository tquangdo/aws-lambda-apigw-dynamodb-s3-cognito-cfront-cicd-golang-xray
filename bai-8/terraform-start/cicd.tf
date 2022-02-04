locals {
  click_fe_build = "click-fe-build-${var.var_environment}"
}

resource "aws_codebuild_project" "click_fe_build" {
  name         = local.click_fe_build
  service_role = var.codebuild_role_arn

  artifacts {
    name      = var.codepipeline_bucket
    packaging = "NONE"
    type      = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    image_pull_credentials_type = "CODEBUILD"
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  source {
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_CUSTOM_CACHE"]
  }

  # tags = local.tags
}

resource "aws_codepipeline" "click_fe" {
  name     = "click-fe-${var.var_environment}"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.codepipeline_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name     = "Source"
      category = "Source"
      owner    = "AWS"
      provider = "CodeStarSourceConnection"
      version  = "1"
      output_artifacts = [
        "SourceArtifact"
      ]

      configuration = {
        ConnectionArn    = var.codestar_connection
        FullRepositoryId = "tquangdo/serverless-series-spa"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name      = "Build"
      category  = "Build"
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 1
      version   = "1"
      input_artifacts = [
        "SourceArtifact",
      ]
      output_artifacts = [
        "BuildArtifact",
      ]

      configuration = {
        "EnvironmentVariables" = jsonencode(
          [
            {
              name  = "CLOUDFRONT_DISTRO_ID"
              type  = "PLAINTEXT"
              value = aws_cloudfront_distribution.s3_distribution.id
            },
          ]
        )
        "ProjectName" = local.click_fe_build
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name      = "Deploy"
      category  = "Deploy"
      owner     = "AWS"
      provider  = "S3"
      run_order = 1
      version   = "1"
      input_artifacts = [
        "BuildArtifact",
      ]

      configuration = {
        "BucketName" = var.codepipeline_bucket
        "Extract"    = "true"
      }
    }
  }

  # tags = local.tags
}
