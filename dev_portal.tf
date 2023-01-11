resource "aws_instance" "dev_portal" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.egress.id]
  subnet_id                   = aws_subnet.private.id
  private_ip                  = var.dev_portal_private_ip
  associate_public_ip_address = false
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.nms_profile.name

  user_data = templatefile("${path.module}/dev_portal_userdata.tpl", {
    tailscale_auth_key = var.tailscale_auth_key
    hostname           = "dev_portal"
    region             = var.region
    nginx-repo-crt     = format("%s-nginx-repo-crt-%s", lower(var.owner_name), random_id.id.hex)
    nginx-repo-key     = format("%s-nginx-repo-key-%s", lower(var.owner_name), random_id.id.hex)
  })

  tags = {
    Name    = format("%s-dev_portal", lower(var.owner_name))
    Owner   = var.owner_email
    Project = format("%s-nms", lower(var.owner_name))
  }
}
