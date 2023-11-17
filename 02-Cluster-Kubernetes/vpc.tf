resource "aws_vpc" "minha-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "jota-vpc"
  }
}

# Mostra as zonas de disponibilidade
data "aws_availability_zones" "available" {}
    output "az" {
        value = "${data.aws_availability_zones.available.names}"
    }
  
resource "was_subnet" "subnet-1" {
  aws_availability_zone = "us-east-1a"
  vpc_id = aws_vpc.minha-vpc.id
  cidr_block = "10.0.0.0/24"
  tag = {
    Name = "minha-vpc-subnet-1"
  }
}

resource "was_subnet" "subnet-2" {
  aws_availability_zone = "us-east-1a"
  vpc_id = aws_vpc.minha-vpc.id
  cidr_block = "10.0.0.0/24"
  tag = {
    Name = "minha-vpc-subnet-2"
  }
}