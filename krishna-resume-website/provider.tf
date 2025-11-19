terraform {
  required_providers {
	aws = {
	  source  = "hashicorp/aws"
	  version = "~> 6.19.0"
	}
  }
  required_version = ">= 1.0"

}

provider "aws" {
  profile = "test"
  region = "us-east-2"

}