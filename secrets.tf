resource "random_id" "id" {
  byte_length = 2
}

resource "aws_secretsmanager_secret" "nginx-repo-crt" {
  name = format("%s-nginx-repo-crt-%s", lower(var.owner_name), random_id.id.hex)
}

resource "aws_secretsmanager_secret" "nginx-repo-key" {
  name = format("%s-nginx-repo-key-%s", lower(var.owner_name), random_id.id.hex)
}

resource "aws_secretsmanager_secret_version" "nginx-repo-crt" {
  secret_id     = aws_secretsmanager_secret.nginx-repo-crt.id
  secret_string = file("${path.module}/nginx-repo.crt")
}
resource "aws_secretsmanager_secret_version" "nginx-repo-key" {
  secret_id     = aws_secretsmanager_secret.nginx-repo-key.id
  secret_string = file("${path.module}/nginx-repo.key")
}
