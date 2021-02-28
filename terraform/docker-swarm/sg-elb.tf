/*==== ELB Security Group configuration ======*/

########################
# ELB Security Group
########################
resource "aws_security_group" "load_balancer" {
  count = var.create_cluster ? 1 : 0

  name        = format("elb-sg-%s", var.environment)
  description = "Security group for elastic load balancer"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      "Name"        = format("elb-sg-%s", trimsuffix(var.environment, "-vpc"))
      "environment" = format("%s", var.environment)
    },
  )
  depends_on = [
    aws_instance.swarm_worker,
    aws_instance.swarm_manager
  ]
}
