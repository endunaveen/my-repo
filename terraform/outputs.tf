output "ec2_2_public_ip" {
  description = "Public IP of EC2-2 instance"
  value       = aws_instance.ec2_2.public_ip
}

output "ec2_2_private_ip" {
  description = "Private IP of EC2-2 instance"
  value       = aws_instance.ec2_2.private_ip
}
