terraform {
  required_version = "~> 1.1"

  required_providers {
    aws = {
        version = "~> 5.2"
    }
  }
  backend "local" {}
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      AppName = "basic-terraform-demo"
      AssetOwner = "OwnerName"
    }
  }
}