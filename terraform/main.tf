terraform {
  required_version = "~> 1.9.0"

  required_providers {
    aws = {
      version = ">= 5.74.0"
      source  = "hashicorp/aws"
    }
  }

  ## For remote state and session locking ##

  #   backend "s3" {
  #     bucket               = "your-terraform-remote-state-storage"
  #     key                  = "bastion.tfstate"
  #     region               = "us-east-1"
  #     dynamodb_table       = "terraform-lock"
  #     workspace_key_prefix = "bastion"
  #   }
}

provider "aws" {
  region = var.aws_region
}