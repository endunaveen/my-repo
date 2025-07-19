provider "aws" {
  region = var.region
}

resource "aws_instance" "ec2_2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name                    # EXISTING key
  vpc_security_group_ids      = [var.security_group_id]         # EXISTING SG

  tags = {
    Name = "ec2-2"
  }
}
