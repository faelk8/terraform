<h1 align="center">
  <img src="image/terraform.png" alt="Kubernetes" width=150px height=120px >
  <br>
  Terraform

  Aplicações e Estudo de Caso
</h1>


<div align="center">

[![Status](https://img.shields.io/badge/version-1.0-blue)]()
[![Status](https://img.shields.io/badge/status-active-success.svg)]()

</div>


# Início

Criando o primeiro arquivo.

`local.tf`
```
resource "local_file" "exemplo" {
    filename = "exemplo.txt"
    content = "Rafael Batista"
}
```
Iniciando o terraform.
```
terraform init
```
Analisando o plan.
```
terraform plan
```
Aplicando a alteração.
```
terraform apply
```

# Backup
Arquivo onde armazena as mudanças. ` terraform.tfstate `

# Variáveis
Arquivo que contém as variáveis, quando o terraform for iniciado ele vai ler o arquivo.

`terraform.tfvars`
```
conteudo = "Testando variáveis de ambiente"
```

Alterando o arquivo local.tf
```
resource "local_file" "exemplo" {
    filename = "exemplo.txt"
    content = var.conteudo
}

variable "conteudo" {
  
}
```