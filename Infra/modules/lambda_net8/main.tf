terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.42.0"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_logGroup" {
  name              = "/aws/lambda/${var.functionName}"
  retention_in_days = var.logRetention
}

data "aws_iam_policy_document" "lambda_log_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_log_policy.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.functionName}-role-${var.environmentShortName}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

data "archive_file" "lambda_assets" {
  type        = "zip"
  source_dir  = var.assets_dir
  output_path = "${path.module}/${var.functionName}.zip"
}

resource "aws_lambda_function" "lambda_function" {
  function_name    = "${var.functionName}_${var.environmentShortName}"
  role             = aws_iam_role.lambda_role.arn
  filename         = data.archive_file.lambda_assets.output_path
  handler          = var.handler
  logging_config {
    log_format = "JSON"
    application_log_level = "INFO"
    system_log_level = "INFO"
  }
  source_code_hash = data.archive_file.lambda_assets.output_base64sha512
  runtime          = "dotnet8"
  environment {
    variables = var.environmentVariables
  }
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_logGroup,
  ]
}