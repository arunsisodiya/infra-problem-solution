/*==== Elastic load balancer configuration ======*/

data "aws_subnet_ids" "public_subnets" {
  vpc_id = var.vpc_id
  filter {
    name = "tag:subnet-type"
    values = ["public"]
  }
}
##############################################
# Classic Elastic Load Balancer configuration
#############################################
resource "aws_elb" "swarm_balancer" {
  count = var.create_cluster ? 1 : 0

  name = format("infra-elb-%s", var.environment)
  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold = 2
    interval = 30
    target = "HTTP:8080/ping"
    timeout = 3
    unhealthy_threshold = 2
  }
  subnets = [join(",", data.aws_subnet_ids.public_subnets.ids)]
  security_groups = [element(aws_security_group.load_balancer.*.id, count.index)]
  instances = concat(aws_instance.swarm_manager.*.id, aws_instance.swarm_worker.*.id)
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 300

  depends_on = [
    aws_instance.swarm_worker,
    aws_instance.swarm_manager
  ]
}