resource "aws_security_group" "monitoring" {
  name        = "monitoring-ec2-sg"
  description = "Security group for AWS monitoring EC2 instance"
  vpc_id      = aws_vpc.monitoring.id

  ingress {
    description = "Node Exporter metrics"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound internet access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "monitoring-ec2-sg"
    Project = var.project_name
  }
}
