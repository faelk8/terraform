<h1 align="center">
  <img src="image/terraform.png" alt="Kubernetes" width=150px height=120px >
  <br>
  Terraform

Conceitos Básicos
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
Arquivo que contém as variáveis, quando o terraform for iniciado ele vai ler o arquivo.<br>
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
Aplicando a alteração:
```
terraform apply
```

# Output
Pegando o id do arquivo e imprimindo no console.<br>
`local.tf`
```
output "id-do-arquivo" {
  value = resource.local_file.exemplo.id
}
```
Pegando o conteúdo da variável.<br>
```
output "conteudo" {
  value = var.conteudo
}
```
Aplicando a alteração:
```
terraform apply
```
# Lendo Arquivo
Leitura de um arquivo que já existe.<br>
`local.tf`
```
data "local_file" "contudo-exemplo"{
    filename = "exemplo.txt"
}

output "data-source-resul" {
  value = data.local_file.contudo-exemplo.content
}
```