variable "region" {
  description = "AWS region"
  default     = "us-west-1"
}

variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t3.small"
}

variable "owner_name" {
    description = "Owner name"
}

variable "owner_email" {
    description = "Owner email address"
}

variable "key_name" {
    description = "AWS EC2 SSH key name"
}

variable "tailscale_auth_key" {
    description = "Tailscale Device Auth Key"
}