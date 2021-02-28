/*==== Docker Swarm Security Group configuration ======*/

########################
# Swarm Security Group
########################
resource "aws_security_group" "docker_swarm" {
  count = var.create_cluster ? 1 : 0

  depends_on  = [var.vpc_id]
  name        = format("docker-swarm-sg-%s", var.environment)
  description = "Security group for ec2 instances in docker swarm"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      "Name"        = format("docker-swarm-sg-%s", trimsuffix(var.environment, "-vpc"))
      "environment" = format("%s", var.environment)
    },
  )
}

#############################
# Swarm Security Group Rules
#############################
resource "aws_security_group_rule" "swarm_security_group_rules_cidr" {
  count = var.create_cluster && length(var.swarm_security_group_rules) > 0 && length(local.swarm_security_group_rules_cidr) > 0 ? length(local.swarm_security_group_rules_cidr) : 0

  depends_on = [
    var.vpc_id,
    aws_security_group.docker_swarm,
    var.bastion_security_groups
  ]
  description       = lookup(local.swarm_security_group_rules_cidr[count.index], "description", null)
  from_port         = lookup(local.swarm_security_group_rules_cidr[count.index], "from_port")
  protocol          = lookup(local.swarm_security_group_rules_cidr[count.index], "protocol")
  security_group_id = element(aws_security_group.docker_swarm.*.id, count.index)
  to_port           = lookup(local.swarm_security_group_rules_cidr[count.index], "to_port")
  type              = lookup(local.swarm_security_group_rules_cidr[count.index], "type")
  cidr_blocks       = lookup(local.swarm_security_group_rules_cidr[count.index], "cidr_blocks")

}

resource "aws_security_group_rule" "swarm_security_group_rules_sg" {
  count = var.create_cluster && length(var.swarm_security_group_rules) > 0 && length(local.swarm_security_group_rules_sg) > 0 ? length(local.swarm_security_group_rules_sg) : 0

  depends_on = [
    var.vpc_id,
    aws_security_group.docker_swarm,
    var.swarm_security_group_rules,
    var.bastion_security_groups
  ]
  description              = lookup(local.swarm_security_group_rules_sg[count.index], "description", null)
  from_port                = lookup(local.swarm_security_group_rules_sg[count.index], "from_port")
  protocol                 = lookup(local.swarm_security_group_rules_sg[count.index], "protocol")
  security_group_id        = element(aws_security_group.docker_swarm.*.id, count.index)
  to_port                  = lookup(local.swarm_security_group_rules_sg[count.index], "to_port")
  type                     = lookup(local.swarm_security_group_rules_sg[count.index], "type")
  source_security_group_id = lookup(local.swarm_security_group_rules_sg[count.index], "source_security_group_id")

}

locals {
  swarm_security_group_rules_cidr = flatten([
    for rule in var.swarm_security_group_rules :
    {
      description = rule.description
      from_port   = rule.from_port
      protocol    = rule.protocol
      to_port     = rule.to_port
      type        = rule.type
      cidr_blocks = rule.cidr_blocks
    } if length(rule.cidr_blocks) > 0
  ])
  swarm_security_group_rules_sg = flatten([
    for rule in var.swarm_security_group_rules :
    {
      description              = rule.description
      from_port                = rule.from_port
      protocol                 = rule.protocol
      to_port                  = rule.to_port
      type                     = rule.type
      source_security_group_id = join(",", rule.source_security_group_id)
    } if length(rule.source_security_group_id) > 0
  ])
}