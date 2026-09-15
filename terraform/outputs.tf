output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.monitoring.id
}

output "instance_public_ip" {
  description = "Public IP address of the monitoring EC2 instance"
  value       = aws_instance.monitoring.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the monitoring EC2 instance"
  value       = aws_instance.monitoring.public_dns
}

output "node_exporter_endpoint" {
  description = "Node Exporter metrics endpoint"
  value       = "http://${aws_instance.monitoring.public_ip}:9100/metrics"
}
