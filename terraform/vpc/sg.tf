/*==== The Security Group configuration ======*/

#####################
# SSH Security Group
#####################
resource "aws_security_group" "allow_ssh" {
  count = var.create_vpc ? 1 : 0

  name        = format("ssh-%s-sg", trimsuffix(var.name, "-vpc"))
  description = "Allow SSH inbound traffic"
  vpc_id      = local.vpc_id

  tags = merge(
    {
      "Name" = format("ssh-%s-sg", trimsuffix(var.name, "-vpc"))
    },
    var.tags
  )
}

##########################
# SSH Security Group Rule
##########################
resource "aws_security_group_rule" "allow_ssh_rule_ingress" {
  count = var.create_vpc ? 1 : 0

  from_port         = 22
  protocol          = "tcp"
  security_group_id = element(aws_security_group.allow_ssh.*.id, count.index)
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ssh_rule_egress" {
  count = var.create_vpc ? 1 : 0

  from_port         = 0
  protocol          = "-1"
  security_group_id = element(aws_security_group.allow_ssh.*.id, count.index)
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}