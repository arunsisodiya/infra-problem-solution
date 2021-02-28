output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets_id" {
  description = "The ID for private subnets"
  value       = module.vpc.private_subnets_id
}

output "public_subnets_id" {
  description = "The ID for public subnets"
  value       = module.vpc.public_subnets_id
}

//output "bastion_key_name" {
//  description = "The key pair name"
//  value       = module.vpc.bastion_key_pair_key_name
//}
//
//output "bastion_key_id" {
//  description = "The key pair id"
//  value       = module.vpc.bastion_key_pair_key_pair_id
//}
//
//output "bastion_key_pair_fingerprint" {
//  description = "The MD5 public key fingerprint as specified in section 4 of RFC 4716."
//  value       = module.vpc.bastion_key_pair_fingerprint
//}

output "bastion_instance_ip" {
  description = "The public ip for ssh access"
  value       = module.vpc.bastion_instance_ip
}

output "elb_dns_name" {
  description = "DNS name for ELB created"
  value = module.docker-swarm.elb_dns_name
}
//output "private_key_pem" {
//  value = module.vpc.private_key_pem
//}
//
//output "public_key_pem" {
//  value = module.vpc.public_key_pem
//}
