resource "aws_secretsmanager_secret" "nginx-repo-crt" {
  name = format("%s-nginx-repo-crt", lower(var.owner_name))
}

resource "aws_secretsmanager_secret" "nginx-repo-key" {
  name = format("%s-nginx-repo-key", lower(var.owner_name))
}

resource "aws_secretsmanager_secret_version" "nginx-repo-crt" {
  secret_id     = aws_secretsmanager_secret.nginx-repo-crt.id
  secret_string = file("${path.module}/nginx-repo.crt")
}
resource "aws_secretsmanager_secret_version" "nginx-repo-key" {
  secret_id     = aws_secretsmanager_secret.nginx-repo-key.id
  secret_string = file("${path.module}/nginx-repo.key")
}
