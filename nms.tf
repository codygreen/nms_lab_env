resource "aws_instance" "nms" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.egress.id]
  subnet_id                   = aws_subnet.private.id
  private_ip                  = var.nms_private_ip
  associate_public_ip_address = false
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.nms_profile.name

  user_data = templatefile("${path.module}/nms_userdata.tpl", {
    tailscale_auth_key = var.tailscale_auth_key
    hostname           = "nms"
    region             = var.region
    nginx-repo-crt     = format("%s-nginx-repo-crt-%s", lower(var.owner_name), random_id.id.hex)
    nginx-repo-key     = format("%s-nginx-repo-key-%s", lower(var.owner_name), random_id.id.hex)
    nms-license        = format("%s-nms-license-%s", lower(var.owner_name), random_id.id.hex)
    nms-license-file   = "/tmp/nms-license-b64.txt"
    nms-host           = var.nms_private_ip
    nms-admin-username = var.nms_admin_username
    nms-admin-password = var.nms_admin_password
  })

  tags = {
    Name    = format("%s-nms", lower(var.owner_name))
    Owner   = var.owner_email
    Project = format("%s-nms", lower(var.owner_name))
  }
}
