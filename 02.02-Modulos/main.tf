terraform {
    required_version = ">=0.13.1"
    required_providers {
        aws = ">=5.26.0"
        local = ">=2.4.0"
  }
  # Salvando o terraform.tfstate no S3 - Versiona o bucket
  backend "s3" {
    bubucket = "meu-bucket"    
    key = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
#   region = "sa-east-1" # Brasil
    region = "us-east-1" # USA Virginia
}

module "new-vpc" {
  source = "./modules/vpc"
  prefix = var.prefix
  vpc_cidr_block = var.vpc_cidr_block
}

module "eks" {
  source = "./modules/eks"
  prefix = var.prefix
  vpc_id = new-vpc.vpc_id
  cluster_name = var.cluster_name
  retention_days = var.retention_days
  subnet_ids = module.new-vpc.subnet_ids
  desired_size = var.desired_size
  max_size = var.max_size
  min_size = var.min_size
}