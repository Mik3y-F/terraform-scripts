terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}


provider "aws" {
  region = "eu-west-1"
}

resource "aws_budgets_budget" "monthly_cloud_spend" {
  name              = "Monthly Cloud Spend"
  budget_type       = "COST"
  limit_amount      = "20.0"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2021-01-01_00:00"
}
