data "aws_caller_identity" "current" {}

locals {
  account_id          = data.aws_caller_identity.current.account_id
  ecr_repository_name = "${var.app_name}-${var.environment}"
}

resource "aws_s3_bucket" "s3-bucket" {
  bucket        = "codepipeline-${var.app_name}-${var.environment}"
  force_destroy = true
}

resource "aws_iam_policy" "codebuild-policy" {
  name = "codebuild-${var.app_name}-${var.environment}-policy"
  path = "/"
  policy = templatefile("${path.module}/iam/codebuild/codebuild-policy.json", {
    s3_bucket_arn   = aws_s3_bucket.s3-bucket.arn,
    region          = var.region,
    account_id      = local.account_id,
    repository_name = local.ecr_repository_name
  })
}

resource "aws_iam_role" "codebuild-role" {
  name               = "codebuild-${var.app_name}-${var.environment}-role"
  assume_role_policy = file("${path.module}/iam/codebuild/trust-policy.json")
}

resource "aws_iam_role_policy_attachment" "codebuild-policy-attachment" {
  policy_arn = aws_iam_policy.codebuild-policy.arn
  role       = aws_iam_role.codebuild-role.id
}

resource "aws_codebuild_project" "build_stage" {
  name         = "${var.app_name}-${var.environment}"
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
      value = var.region
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = local.account_id
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = local.ecr_repository_name
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = var.image_tag
    }

    environment_variable {
      name  = "CONTAINER_NAME"
      value = var.container_name
    }
  }

  source {
    type = "CODEPIPELINE"
  }
}

resource "aws_iam_policy" "codepipeline-policy" {
  name = "codepipeline-${var.app_name}-${var.environment}-policy"
  path = "/"
  policy = templatefile("${path.module}/iam/codepipeline/codepipeline-policy.json", {
    s3_bucket_arn           = aws_s3_bucket.s3-bucket.arn,
    region                  = var.region,
    account_id              = local.account_id,
    codebuild_project_name  = aws_codebuild_project.build_stage.name,
    codestar_connection_arn = var.codestar_connection
  })
}

resource "aws_iam_role" "codepipeline-role" {
  name               = "codepipeline-${var.app_name}-${var.environment}-role"
  assume_role_policy = file("${path.module}/iam/codepipeline/trust-policy.json")
}

resource "aws_iam_role_policy_attachment" "codepipeline-policy-attachment" {
  policy_arn = aws_iam_policy.codepipeline-policy.arn
  role       = aws_iam_role.codepipeline-role.id
}

resource "aws_codepipeline" "codepipeline" {
  name           = "${var.app_name}-${var.environment}"
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
        ConnectionArn    = var.codestar_connection
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
        ClusterName = var.cluster_name
        ServiceName = var.service_name
        FileName : "imagedefinitions.json"
        DeploymentTimeout = "5"
      }
    }
  }
}