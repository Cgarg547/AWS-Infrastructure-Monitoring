data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "monitoring" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.monitoring.id
  vpc_security_group_ids      = [aws_security_group.monitoring.id]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.monitoring_ec2.name

  user_data = <<-USERDATA
              #!/bin/bash

              dnf update -y

              useradd --no-create-home --shell /bin/false node_exporter || true

              cd /tmp
              curl -LO https://github.com/prometheus/node_exporter/releases/latest/download/node_exporter-1.9.1.linux-amd64.tar.gz

              tar -xzf node_exporter-1.9.1.linux-amd64.tar.gz

              cp node_exporter-1.9.1.linux-amd64/node_exporter /usr/local/bin/node_exporter

              chown node_exporter:node_exporter /usr/local/bin/node_exporter

              cat > /etc/systemd/system/node_exporter.service <<'SERVICE'
              [Unit]
              Description=Prometheus Node Exporter
              Wants=network-online.target
              After=network-online.target

              [Service]
              User=node_exporter
              Group=node_exporter
              Type=simple
              ExecStart=/usr/local/bin/node_exporter

              [Install]
              WantedBy=multi-user.target
              SERVICE

              systemctl daemon-reload
              systemctl enable node_exporter
              systemctl start node_exporter
              USERDATA

  tags = {
    Name        = "monitoring-ec2"
    Project     = var.project_name
    Environment = var.environment
    Monitoring  = "prometheus"
  }
}
