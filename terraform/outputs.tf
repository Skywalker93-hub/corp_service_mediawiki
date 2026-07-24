output "openvpn_public_ip" {
  description = "The public IP address of the OpenVPN server"
  value       = aws_instance.openvpn.public_ip
}

output "proxy_alb_dns_name" {
  description = "The internal DNS name of the ALB"
  value       = aws_lb.proxy_alb.dns_name
}
