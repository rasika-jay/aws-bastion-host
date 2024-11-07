output "dns_endpoint" {
  description = "DNS endpoint for the Network Load Balancer"
  value       = aws_lb.bastion.dns_name
}