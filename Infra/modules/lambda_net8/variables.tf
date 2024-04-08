variable "functionName" {
  description = "AWS lambda function name"
  type        = string
}

variable "environmentShortName" {
  description = "environment short name dev/test/prod"
  default     = "dev"
  type        = string
}

variable "handler" {
  description = "lambda function handler"
  type        = string
}

variable "environmentVariables" {
  description = "environment variables for lambda function"
  type        = map(string)
}

variable "logRetention" {
  description = "lambda function cloudwatch log retention value in days"
  type        = number
  default     = 14
}

variable "assets_dir" {
  description = "lambda function assets directory"
  type        = string
}