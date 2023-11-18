resource "aws_vpc" "minha-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

# Mostra as zonas de disponibilidade
data "aws_availability_zones" "available" {}

resource "aws_subnet" "subnets" {
  count = 2
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id =  aws_vpc.minha-vpc.id
  cidr_block = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.prefix}-subnet-${count.index}"
  }  
}

  
# resource "was_subnet" "subnet-1" {
#   aws_availability_zone = "us-east-1a"
#   vpc_id = aws_vpc.minha-vpc.id
#   cidr_block = "10.0.0.0/24"
#   tag = {
#     Name = "${var.prefix}-subnet-1"
#   }
# }

# resource "was_subnet" "subnet-2" {
#   aws_availability_zone = "us-east-1a"
#   vpc_id = aws_vpc.minha-vpc.id
#   cidr_block = "10.0.0.0/24"
#   tag = {
#     Name = "${var.prefix}-subnet-2"
#   }
# }