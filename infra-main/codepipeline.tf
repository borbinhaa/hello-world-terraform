terraform {
  required_version = "1.9.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.70.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_s3_bucket" "s3-bucket" {
  bucket        = "codepipeline-${var.project_name}"
  force_destroy = true
}

resource "aws_iam_policy" "codebuild-policy" {
  name = "codebuild-${var.project_name}-policy"
  path = "/"
  policy = templatefile("iam/codebuild/codebuild-policy.json", {
    s3_bucket_arn   = aws_s3_bucket.s3-bucket.arn,
    region          = local.region,
    account_id      = local.account_id,
    repository_name = var.project_name
  })
}

resource "aws_iam_role" "codebuild-role" {
  name               = "codebuild-${var.project_name}-role"
  assume_role_policy = file("iam/codebuild/trust-policy.json")
}

resource "aws_iam_role_policy_attachment" "codebuild-policy-attachment" {
  policy_arn = aws_iam_policy.codebuild-policy.arn
  role       = aws_iam_role.codebuild-role.id
}

resource "aws_codebuild_project" "build_stage" {
  name         = var.project_name
  service_role = aws_iam_role.codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = local.region
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = local.account_id
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.project_name
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = var.image_tag
    }

    environment_variable {
      name  = "PROJECT_NAME"
      value = var.project_name
    }
  }

  source {
    type = "CODEPIPELINE"
  }
}

resource "aws_iam_policy" "codepipeline-policy" {
  name = "codepipeline-${var.project_name}-policy"
  path = "/"
  policy = templatefile("iam/codepipeline/codepipeline-policy.json", {
    s3_bucket_arn           = aws_s3_bucket.s3-bucket.arn,
    region                  = local.region,
    account_id              = local.account_id,
    codebuild_project_name  = aws_codebuild_project.build_stage.name,
    codestar_connection_arn = var.github_connection_arn
  })
}

resource "aws_iam_role" "codepipeline-role" {
  name               = "codepipeline-${var.project_name}-role"
  assume_role_policy = file("iam/codepipeline/trust-policy.json")
}

resource "aws_iam_role_policy_attachment" "codepipeline-policy-attachment" {
  policy_arn = aws_iam_policy.codepipeline-policy.arn
  role       = aws_iam_role.codepipeline-role.id
}

resource "aws_codepipeline" "codepipeline" {
  name           = var.project_name
  role_arn       = aws_iam_role.codepipeline-role.arn
  pipeline_type  = "V2"
  execution_mode = "QUEUED"

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.s3-bucket.bucket
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        FullRepositoryId = var.github_repo
        BranchName       = var.github_branch
        ConnectionArn    = var.github_connection_arn
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.build_stage.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ClusterName = aws_ecs_cluster.ecs-cluster.name
        ServiceName = aws_ecs_service.ecs-service.name
        FileName : "imagedefinitions.json"
        DeploymentTimeout = "5"
      }
    }
  }
}