terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 0.14.0"
}

provider "aws" {
  region = "us-east-1"
}


module "stack_deployment" {
  source   = "./module/3tier-components/"
  username = var.username
  password = var.password

}




