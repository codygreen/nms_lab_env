variable "region" {
  description = "AWS region"
  default     = "us-west-1"
}

variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t3.small"
}

variable "nms_private_ip" {
  description = "Private IP Address of NMS Instance"
  default     = "10.0.1.10"
}

variable "gateway_private_ip" {
  description = "Private IP Address of Gateway Instance"
  default     = "10.0.1.11"
}

variable "dev_portal_private_ip" {
  description = "Private IP Address of ACM Dev Portal Instance"
  default     = "10.0.1.12"
}

variable "api_private_ip" {
  description = "Private IP Address of API Server Instance"
  default     = "10.0.1.13"
}

variable "waf_private_ip" {
  description = "Private IP Address of WAF Instance"
  default     = "10.0.1.14"
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

variable "nms_admin_username" {
    description = "NMS Administrator User Name"
    default     = "admin"
}

variable "nms_admin_password" {
    description = "NMS Administrator Password"
}
