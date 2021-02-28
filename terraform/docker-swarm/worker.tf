/*==== Docker Swarm worker configuration ======*/
locals {
  expanded_ec2_list_worker = flatten([
    for cluster in var.cluster-vms : [
      for vm in range(cluster.count) : {
        os            = cluster.os
        instance_type = cluster.instance_type
        ami_username  = cluster.ami_username
        key_name      = cluster.key_name
        role          = cluster.role
        tags          = cluster.tags
      } if cluster.role == "worker"
    ]
  ])
}

########################################
# Docker Swarm worker Network Interface
########################################
resource "aws_network_interface" "swarm_worker" {
  count           = var.create_cluster && length(local.expanded_ec2_list_worker) > 0 ? length(local.expanded_ec2_list_worker) : 0
  subnet_id       = var.private_subnet_ids
  security_groups = [element(aws_security_group.docker_swarm.*.id, count.index)]

  tags = merge(
    {
      "Name" = format("swarm-worker-%s-eni", var.environment)
    },
    lookup(local.expanded_ec2_list_worker[count.index], "tags")
  )
}

##################
# AWS AMI ID Data
##################
data "aws_ami" "aws_ami_id_worker" {
  count = var.create_cluster && length(local.expanded_ec2_list_worker) > 0 ? 1 : 0

  most_recent = true
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  name_regex = lookup(var.amis_os_map_regex, lookup(local.expanded_ec2_list_worker[count.index], "os"))
  owners     = [length(var.amis_primary_owners) == 0 ? lookup(var.amis_os_map_owners, lookup(local.expanded_ec2_list_worker[count.index], "os")) : var.amis_primary_owners]
}

#######################################
# Docker Swarm worker EC2 Configuration
#######################################
resource "aws_instance" "swarm_worker" {
  count = var.create_cluster && length(local.expanded_ec2_list_worker) > 0 ? length(local.expanded_ec2_list_worker) : 0

  ami           = element(data.aws_ami.aws_ami_id_worker.*.id, count.index)
  instance_type = lookup(local.expanded_ec2_list_worker[count.index], "instance_type")
  key_name      = lookup(local.expanded_ec2_list_worker[count.index], "key_name")

  network_interface {
    device_index         = 0
    network_interface_id = element(aws_network_interface.swarm_worker.*.id, count.index)
  }

  tags = merge(
    {
      "Name" = format("swarm-worker-%s", var.environment)
    },
    lookup(local.expanded_ec2_list_worker[count.index], "tags")
  )
}