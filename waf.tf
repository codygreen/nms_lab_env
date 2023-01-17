resource "aws_instance" "waf" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.egress.id]
  subnet_id                   = aws_subnet.private.id
  private_ip                  = var.waf_private_ip
  associate_public_ip_address = false
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.nms_profile.name

  user_data = templatefile("${path.module}/waf_userdata.tpl", {
    tailscale_auth_key = var.tailscale_auth_key
    hostname           = "waf"
    region             = var.region
    nms-host           = aws_instance.nms.private_ip
    nginx-repo-crt     = format("%s-nginx-repo-crt-%s", lower(var.owner_name), random_id.id.hex)
    nginx-repo-key     = format("%s-nginx-repo-key-%s", lower(var.owner_name), random_id.id.hex)
  })

  tags = {
    Name    = format("%s-waf", lower(var.owner_name))
    Owner   = var.owner_email
    Project = format("%s-nms", lower(var.owner_name))
  }
}
