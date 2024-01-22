output "vpc_id" {
  value = aws_vpc.app_vpc.id
}

output "public_subnets" {
  value = aws_subnet.public_subnets.*.id
}

output "security_group_ec2" {
  value = aws_security_group.sg.*.id
}
