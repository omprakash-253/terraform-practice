terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "6.50.0"
        }
    }
    backend "s3" {
        bucket = "omansh-remote-state"
        key    = "prod/ec2/terraform.tfstate"
        region = "us-east-1"
        encrypt = true
        dynamodb_table = "remote-state-lock"
    }
}

provider "aws" {
    region = "us-east-1"
}

