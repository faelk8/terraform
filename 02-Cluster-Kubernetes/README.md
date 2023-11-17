<h1 align="center">
  <img src="image/terraform.png" alt="Kubernetes" width=150px height=120px >
  <br>
  Terraform

  
</h1>


<div align="center">

[![Status](https://img.shields.io/badge/version-1.0-blue)]()
[![Status](https://img.shields.io/badge/status-active-success.svg)]()

</div>

# Configurando 
Arquivo inicial de configuração das versões, seguido da região.

`providers.tf`
```
terraform {
    required_version = ">=0.13.1"
    required_providers {
        aws = ">=5.26.0"
        local = ">=2.4.0"
  }
}

provider "aws" {
    region = "us-east-1" # USA Virginia
}
```
Inciando a aplicação.
```
terraform init
```

# Criando a VPC
`vpc.tc`
```
resource "aws_vpc" "minha-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "jota-vpc"
  }
}
```
Criando a VPC
```
terraform apply
```

# Configurando Subnet

`vpc.tf`
```
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
```

# Comandos
| **Comandos** | **Descrição** |
|----------|---------------|
| terraform apply | Aplica as alterações |
| terraform apply --auto-approve | Para não precisar digital *yes* toda hora |
| terraform init | Inicia o terraform |
