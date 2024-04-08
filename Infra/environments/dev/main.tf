terraform {
  backend "s3" {
    bucket         = "infra35632"
    key            = "sample_terraform_aws/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "infra_state_locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "lambda_integration_one" {
  source               = "../../modules/lambda_net8"
  functionName         = "integration-one"
  environmentShortName = "dev"
  handler              = "IntegrationOne::IntegrationOne.Function::FunctionHandler"
  environmentVariables = {
    variable1 : "variable1"
  }
  logRetention = 30
  assets_dir   = "${path.module}/../../../backend/IntegrationOne/bin/Release/net8.0/linux-x64/publish"
}
