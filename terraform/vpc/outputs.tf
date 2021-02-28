output "vpc_id" {
  description = "The ID of the VPC"
  value       = concat(aws_vpc.this.*.id, [""])[0]
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = concat(aws_vpc.this.*.cidr_block, [""])[0]
}

output "private_subnets_id" {
  description = "The ID for private subnets"
  value       = concat(aws_subnet.private.*.id, [""])[0]
}

output "public_subnets_id" {
  description = "The ID for public subnets"
  value       = concat(aws_subnet.public.*.id, [""])[0]
}

output "public_subnet_cidr_block" {
  description = "The CIDR block of the public subnets"
  value       = concat(aws_subnet.public.*.cidr_block, [""])[0]
}

output "private_subnet_cidr_block" {
  description = "The CIDR block of the private subnets"
  value       = concat(aws_subnet.private.*.cidr_block, [""])[0]
}

//output "bastion_key_pair_key_name" {
//  description = "The key pair name."
//  value       = concat(aws_key_pair.bastion_key_pair.*.key_name, [""])[0]
//}
//
//output "bastion_key_pair_key_pair_id" {
//  description = "The key pair ID."
//  value       = concat(aws_key_pair.bastion_key_pair.*.key_pair_id, [""])[0]
//}
//
//output "bastion_key_pair_fingerprint" {
//  description = "The MD5 public key fingerprint as specified in section 4 of RFC 4716."
//  value       = concat(aws_key_pair.bastion_key_pair.*.fingerprint, [""])[0]
//}

output "bastion_instance_ip" {
  description = "The public ip for ssh access"
  value       = concat(aws_instance.bastion.*.public_ip, [""])[0]
}

output "bastion_security_groups" {
  description = "The public ip for ssh access"
  value       = concat(aws_network_interface.bastion.*.security_groups, [""])[0]
}

//output "private_key_pem" {
//  value = concat(tls_private_key.private_key.*.private_key_pem, [""])[0]
//}
//
//output "public_key_pem" {
//  value = concat(tls_private_key.private_key.*.public_key_pem, [""])[0]
//}