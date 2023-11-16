resource "local_file" "exemplo" {
    filename = "exemplo.txt"
    content = var.conteudo
}

variable "conteudo" {
  type = string
}