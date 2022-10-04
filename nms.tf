resource "aws_instance" "nms" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.egress.id]
  subnet_id                   = aws_subnet.private.id
  associate_public_ip_address = false
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.nms_profile.name

  user_data = templatefile("${path.module}/nms_userdata.tpl", {
    tailscale_auth_key = var.tailscale_auth_key
    hostname           = "nms"
    region             = var.region
    nginx-repo-crt     = aws_secretsmanager_secret.nginx-repo-crt.arn
    nginx-repo-key     = aws_secretsmanager_secret.nginx-repo-key.arn
  })

  tags = {
    Name    = format("%s-nms", lower(var.owner_name))
    Owner   = var.owner_email
    Project = format("%s-nms", lower(var.owner_name))
  }
}
