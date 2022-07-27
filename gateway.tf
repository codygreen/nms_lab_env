resource "aws_instance" "gateway" {
  ami                           = data.aws_ami.ubuntu.id
  instance_type                 = var.instance_type
  vpc_security_group_ids        = [aws_security_group.egress.id]
  subnet_id                     = aws_subnet.private.id
  associate_public_ip_address   = false
  key_name                      = var.key_name

  user_data = templatefile("${path.module}/userdata.tpl", {
    tailscale_auth_key = var.tailscale_auth_key
    hostname = "gateway"
  })

  tags = {
    Name = format("%s-gateway", lower(var.owner_name))
    Owner = var.owner_email
    Project = format("%s-nms", lower(var.owner_name))
  }
}