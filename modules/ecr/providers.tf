###############################################################################
# Terraform and Providers
#

## Terraform ==================================================================
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

## Data =======================================================================
data "aws_ecr_authorization_token" "token" {} #                                 ECR token.

## Providers ==================================================================
provider "docker" { #                                                           Docker.
  registry_auth {
    address  = data.aws_ecr_authorization_token.token.proxy_endpoint
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}
