terraform {
    required_version = ">=0.13.1"
    required_providers {
        aws = ">=5.26.0"
        local = ">=2.4.0"
  }
}

provider "aws" {
#   region = "sa-east-1" # Brasil
    region = "us-east-1" # USA Virginia
}