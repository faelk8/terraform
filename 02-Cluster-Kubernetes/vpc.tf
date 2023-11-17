resource "aws_vpc" "minha-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "jota-vpc"
  }
}
