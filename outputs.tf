
output "instance_public_dns" {
  value = aws_instance.server.public_dns
}

output "instance_public_IP" {
  value = aws_instance.server.public_ip
}

output "instance_public_tls_dns2" {
  value = aws_instance.server_tls.public_dns
}

output "instance_public_tls_IP2" {
  value = aws_instance.server_tls.public_ip
}
