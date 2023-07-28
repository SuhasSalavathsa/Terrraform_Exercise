output "instance_ips" {
  value = aws_instance.web[*].public_ip
}

output "name" {
  value = "test"
}