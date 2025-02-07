output "random_availability_zone" {
  value = random_shuffle.az_random.result[0]
}
output "availability_zones" {
  value = data.aws_availability_zones.available.names
}
output "internet_gateway_id" {
  value = aws_internet_gateway.custom_gateWay.id
  description = "The ID of the Internet Gateway"
}
output "public_subnet_id" {
  value = aws_subnet.public.id
  description = "The ID of the Public Subnet"
}

output "private_subnet_id" {
  value = aws_subnet.private.id
  description = "The ID of the Private Subnet"
}

output "public_route_table_id" {
  value = aws_route_table.public.id
  description = "The ID of the Public Route Table"
}
output "public_ip" {
  value = aws_instance.vm.public_ip
  description = "**TASK 2**the public ip:"
}
output "dns_name" {
  value = aws_lb.custom_lb.dns_name
  description = "TASK 3 the DNS is:"
}