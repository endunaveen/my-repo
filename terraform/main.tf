provider "aws" {
  region = "ap-south-1"
}

resource "aws_key_pair" "ec2_2_key" {
  key_name   = "ec2-2-key"
  public_key = file("~/.ssh/ec2-2-key.pub")
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Tomcat (8080)"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_2" {
  ami                         = "ami-0c02fb55956c7d316" # Ubuntu 22.04 LTS
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.ec2_2_key.key_name
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true

  tags = {
    Name = "ec2-2-microk8s"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y snapd",
      "sudo snap install microk8s --classic",
      "sudo usermod -a -G microk8s ubuntu",
      "sudo chown -f -R ubuntu ~/.kube",
      "newgrp microk8s",
      "sudo microk8s status --wait-ready",
      "sudo microk8s enable helm3",
      "sudo microk8s helm3 repo add bitnami https://charts.bitnami.com/bitnami",
      "sudo microk8s helm3 install tomcat bitnami/tomcat"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/ec2-2-key")
      host        = self.public_ip
    }
  }
}


output "ec2_2_public_ip" {
  description = "Public IP of EC2-2 instance"
  value       = aws_instance.ec2_2.public_ip
}

