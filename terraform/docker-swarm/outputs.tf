output "docker_swarm_security_group" {
  description = "Security group id for docker swarm"
  value       = concat(aws_security_group.docker_swarm.*.id, [""])[0]
}

output "elb_dns_name" {
  description = "DNS name for ELB created"
  value = concat(aws_elb.swarm_balancer.*.dns_name, [""])[0]
}