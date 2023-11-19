<h1 align="center">
  <img src="./../image/terraform.png" alt="Kubernetes" width=150px height=120px >
  <br>
  Terraform<br>
  Desenvolvendo uma VPN com 2 subnetes  
</h1>

<div align="center">
        <img src="./../image/VPC.png" alt="Kubernetes" width="900px" height="500px">
</div>


<div align="center">

[![Status](https://img.shields.io/badge/version-1.0-blue)]()
[![Status](https://img.shields.io/badge/status-active-success.svg)]()

</div>

<div>

- [Configurando](#configurando)
- [Criando a VPC](#criando-a-vpc)
- [Configurando Subnet](#configurando-subnet)
- [Refatorando](#refatorando)
- [Internet Gateway & Route Table](#internet-gateway--route-table)
- [Associação](#associacao)
- [Grupo de Segurança](#grupo-de-seguranca)
- [Role](#role)
- [Atachando a Policy](#atachando-a-policy)
- [Log](#log)
- [Criando o Cluster](#criando-o-cluster)
- [Node Group](#node-group)
- [Arquivo de Configuração](#arquivo-de-configuracao)
- [Fazendo um Acesso](#fazendo-um-acesso)
- [Destruindo Tudo](#destruindo-tudo)
- [Comandos](#comandos)

</div>

# Configurando 
Arquivo inicial para criar e configurar os provedores e infraestrutura. São as configurações necessárias para executar o código.
* Versão do terraform
* Versão mínima dos provedores
* Configuração do provedor AWS

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
Definindo os recursos da VPC. Definindo o bloco CIDR (Classless Inter-Domain Routing) para a VPC. Este bloco CIDR especifica o intervalo de endereços IP que a VPC utilizará. Está definido como "10.0.0.0/16", o que significa que a VPC terá um intervalo de endereços IP de 10.0.0.0 a 10.0.255.255.<br>
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
terraform apply --auto-approve
```

# Configurando Subnet
Criando 2 subnetes associando a "minha-vpc".<br>
`vpc_id = aws_vpc.minha-vpc.id`: Define o ID da VPC à qual a subnet pertencerá. Aqui, está referenciando a VPC criada anteriormente (com o nome "minha-vpc") e utilizando seu ID.


`vpc.tf`
```
resource "aws_subnet" "subnet-1" {
  aws_availability_zone = "us-east-1a"
  vpc_id = aws_vpc.minha-vpc.id
  cidr_block = "10.0.0.0/24"
  tag = {
    Name = "minha-vpc-subnet-1"
  }
}

resource "aws_subnet" "subnet-2" {
  aws_availability_zone = "us-east-1a"
  vpc_id = aws_vpc.minha-vpc.id
  cidr_block = "10.0.0.0/24"
  tag = {
    Name = "minha-vpc-subnet-2"
  }
}
```

# Refatorando
Deixando o código mais eficiente.<br>
Adicionando variáveis.<br>
`variebles.tf`
```
variable "prefix"{}
```
Informando o valor da variável.<br>
`terraform.tfvars`
```
prefix = "jota"
```
Refatorando a `vpc.tf`
```
resource "aws_vpc" "minha-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

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
```
No comando `data "aws_availability_zones" "available" {}`, pega a zona de disponibilidades e utiliza no `availability_zone` uma espécie de um loop com o `count=2` e coloca o índice aqui `${"count.index"}`. Será criado um total de 2 subnets, se precisar de mais altere o valor. O restante do código pode ser removido.<br>
Esse código cria uma VPC, pegas as zonas de disponibilidade na região AWS e cria duas subnets associadas à VPC, cada uma em uma zona de disponibilidade diferente, com blocos CIDR distintos. As tags são usadas para identificar cada recurso.

# Internet Gateway & Route Table
Criando uma internet gateway para permitir a comunicação com a internet, utilizando uma tag para identificar.<br>
`vpc.tf`
```
resource "aws_internet_gateway" "minha-igw" {
  vpc_id = aws_vpc.minha-vpc
  tags = {
    Name = "${var.prefix}-igw"
  }
}
```
Criando uma route table associada a VPC definindo uma rota padrão que encaminha o tráfego para o Internet Gateway associado à VPC. Tudo que colocar na route table vai ter acesso a internet.
```
resource "aws_route_table" "new-rtb" {
  vpc_id = aws_vpc.minha-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.minha-igw.id
  }
  tags = {
    Name = "${var.prefix}-rtb"
  }
}
```
Aplicando alteração.
```
terraform apply --auto-approve
```

# Associação
Associando as redes que fazem parte da route table, para o direcionar o trágefo para dentro da VPC.<br>
`vpc.tf`
```
resource "aws_route_table_association" "new-rtb-association" {
  count = 2
  route_table_id = aws_route_table.new-rtb.id
  subnet_id = aws_subnet.subnets.*.id[count.index]  
}
```
Aplicando alteração.
```
terraform apply --auto-approve
```

# Grupo de Segurança
Egress (regrad de saída) permitir que o cluster tenha acesso a internet e não que as pessoas acessem o cluster.<br>
* Todas as portas liberadas
* Todos os protocolos liberados
* Todos os IPs liberados

`cluster.tf`
```
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.minha-vpc.id
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name = "${var.prefix}-sg"
  }
}
```

Em AWS Security Groups, tanto ingress quanto egress referem-se ao controle de tráfego, mas em direções opostas:

Ingress:
* Refere-se ao tráfego que entra na instância ou recurso protegido pelo grupo de segurança.
* As regras de ingresso especificam quais tipos de tráfego são permitidos entrar nas instâncias associadas ao grupo de segurança.
* Se você permitir ingresso na porta 80 (HTTP), isso significa que o tráfego vindo de fora da instância para a porta 80 será permitido.

 Egress:
* Refere-se ao tráfego que sai da instância ou recurso protegido pelo grupo de segurança.
* As regras de egresso especificam quais tipos de tráfego são permitidos sair das instâncias associadas ao grupo de segurança.
* Se você permitir egresso na porta 443 (HTTPS), isso significa que o tráfego saindo da instância pela porta 443 será permitido.

Em resumo, o ingress controla o tráfego que entra (incoming), enquanto o egress controla o tráfego que sai (outgoing) de um recurso protegido pelo grupo de segurança. Ambos são importantes para configurar uma política de segurança completa, garantindo que apenas o tráfego desejado, necessário e seguro seja permitido.

# Role
Criando a regra de acesso (IAM). Libera o acesso ao serviço do EKS.<br>
`cluster.tf`
```
resource "aws_iam_role" "cluster" {
  name = "${var.prefix}-${var.cluster_name}-role"
  assume_role_policy = <<POLICY
    {
        "Version": "2012-10-17"
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "eks.amazonws.com"
                },
                "Action": "sts.AssumeRole"
            }
        ]
    }
  POLICY
}
```
`variables.tf`
```
variable "cluster_name" {}
```
`terraform.tfvars`
```
cluster_name = "cluster-jota"
```

# Atachando a Policy
Estes blocos conferem permissões específicas à função IAM denominada "cluster", habilitando-a a assumir as políticas e capacidades vinculadas a "AmazonEKSVPCResourceController" e "AmazonEKSClusterPolicy". Essas políticas concedem as permissões essenciais para interagir com recursos da VPC e administrar os clusters do Amazon EKS. São essenciais para as operações adequadas do Kubernetes, garantindo a correta criação das máquinas necessárias.<br>
`cluster.tf`
```
resource "aws_iam_role_policy_attachment" "cluste-AmazonEKSVPCResourceController" {
  role = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "cluste-AmazonEKSClusterPolicy" {
  role = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
```
Aplicando alteração.
```
terraform apply --auto-approve
```

# Log
Criando arquivo de variáveis.<br>
`terraform.tfvars`
```
variable "retention_days" {}
```
`terraform.tfvars`
```
retention_days = 30
```
Criando um grupo de logs no Amazon CloudWatch Logs.<br>
`cluster.tf`
```
resource "aws_cloudwatch_log_group" "log" {
  name = "/aws/eks/${var.prefix}-${var.cluster_name}/cluster"
  retention_in_days = var.retention_days
}
```

# Criando o Cluster
Criando o cluster EKS.
* Informando a role
* Informando o log
* Informando as subnets
* Informando o security group
* Informando as dependências
```
resource "aws_eks_cluster" "cluster" {
  name = "${var.prefix}-${var.cluster_name}"
  role_arn = aws_iam_role.cluster.arn
  enabled_cluster_log_types = ["api","audit"]
  vpc_config {
    subnet_ids = aws_subnet.subnets[*].id 
    security_group_ids = [aws_security_group.sg.id]
  }
  depends_on = [ 
    aws_cloudwatch_log_group.log,
    aws_iam_role_policy_attachment.cluste-AmazonEKSClusterPolic,
    aws_iam_role_policy_attachment.cluste-AmazonEKSVPCResourceController ]
}
```
Aplicando alteração.<br>
```
terraform apply --auto-approve
```

# Node Group
Definindo as regras de acesso.
* Informando a role
* Informando o log
* Informando as subnets
* Informando o security group
* Informando as dependências
* Informando o tipo de instância
`nodes.tf`
```
resource "aws_iam_role" "node" {
  name = "${var.prefix}-${var.cluster_name}-role-name"
  assume_role_policy = <<POLICY
    {
        "Version": "2012-10-17"
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ec2.amazonws.com"
                },
                "Action": "sts.AssumeRole"
            }
        ]
    }
  POLICY
}
```
Atachando as policys.<br>
Node que tem acesso ao Amazon EKS Worker Node Policy. Um worker que roda no cluster
```
resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}
```
Amazon EKS CNI Policy. Permite a comunicação entre os nodes.
```
resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}
```
Amazon EC2 Container Registry Read Only. Onde rada as imagens Docker, para isso precisa de permissão.
```
resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}
```
Definindo variáveis
`variables.tf`
```
variable "desired_size" {}
variable "max_size" {}
variable "min_size" {}
```
`terraform.tfvars`
```
desired_size = 2
max_size = 4
min_size = 2
```
Criando as instâncias EC2 que são provisionads automaticamente para atuar como nodes no cluster Kubernetes.<br>
`nodes.tf`
```
resource "aws_eks_node_group" "node-1" {
  cluster_name = aws_eks_cluster.cluster.name
  node_group_name = "node-1"
  node_role_arn = aws_iam_role.node.arn
  subnet_ids = aws_subet.subnets[*].id
  instance_types = ["t3.micro"]
  scaling_config {
    desired_size = var.desired_size
    max_size = var.max_size
    min_size = var.min_size
  }
  depends_on = [ 
    aws_cloudwatch_log_group.log,
    aws_iam_role_policy_attachment.cluste-AmazonEKSClusterPolic,
    aws_iam_role_policy_attachment.cluste-AmazonEKSVPCResourceController,
 ]
}
```

# Arquivo de Configuração

Instalar o [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)<br>
1. Configurando o acesso
2. Acessando os nodes

Agora é possível acessar as máquinas na AWS.

```
cp kubeconfig ~/.kube/config
kubectl get nodes
```

# Fazendo um Acesso

```
kubectl create deploy nginx --image=nginx
kubectl get po
```
```
kubectl port-forward pod/< name > 8181:80
```
Acessando: http://localhost:8181

# Destruindo Tudo
**Destroi tudo que foi feito!!!**
```
terraform destroy
```

# Comandos
| **Comandos** | **Descrição** |
|----------|---------------|
| terraform apply | Aplica as alterações |
| terraform apply --auto-approve | Aplica as alterações sem precisar digitar *yes* |
| terraform init | Inicia o terraform |
| terraform plan | Verificar se o çodigo está correto |