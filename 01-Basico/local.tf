resource "local_file" "exemplo" {
    filename = "exemplo.txt"
    content = var.conteudo
}

data "local_file" "contudo-exemplo"{
    filename = "exemplo.txt"
}

output "data-source-resul" {
  value = data.local_file.contudo-exemplo.content
}

variable "conteudo" {
  type = string
}

output "id-do-arquivo" {
  value = resource.local_file.exemplo.id
}

output "conteudo" {
  value = var.conteudo
}
# Quem nasceu primeiro ?
output "chiken-egg" {
  value = sort(["🐥","🥚"])
}