resource "aws_instance" "api" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.egress.id]
  subnet_id                   = aws_subnet.private.id
  private_ip                  = var.api_private_ip
  associate_public_ip_address = false
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.nms_profile.name

  user_data = templatefile("${path.module}/api_userdata.tpl", {
    tailscale_auth_key = var.tailscale_auth_key
    hostname           = "api"
    region             = var.region
  })

  tags = {
    Name    = format("%s-api", lower(var.owner_name))
    Owner   = var.owner_email
    Project = format("%s-nms", lower(var.owner_name))
  }
}
