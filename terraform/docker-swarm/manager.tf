/*==== Docker Swarm manager configuration ======*/
locals {
  expanded_ec2_list_manager = flatten([
    for cluster in var.cluster-vms : [
      for vm in range(cluster.count) : {
        os            = cluster.os
        instance_type = cluster.instance_type
        ami_username  = cluster.ami_username
        key_name      = cluster.key_name
        role          = cluster.role
        tags          = cluster.tags
      } if cluster.role == "manager"
    ]
  ])
}

########################################
# Docker Swarm manager Network Interface
########################################
resource "aws_network_interface" "swarm_manager" {
  count           = var.create_cluster && length(local.expanded_ec2_list_manager) > 0 ? length(local.expanded_ec2_list_manager) : 0
  subnet_id       = var.private_subnet_ids
  security_groups = [element(aws_security_group.docker_swarm.*.id, count.index)]

  tags = merge(
    {
      "Name" = format("swarm-manager-%s-eni", var.environment)
    },
    lookup(local.expanded_ec2_list_worker[count.index], "tags"),
  )
}

##################
# AWS AMI ID Data
##################
data "aws_ami" "aws_ami_id_manager" {
  count = var.create_cluster && length(local.expanded_ec2_list_manager) > 0 ? 1 : 0

  most_recent = true
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  name_regex = lookup(var.amis_os_map_regex, lookup(local.expanded_ec2_list_manager[count.index], "os"))
  owners     = [length(var.amis_primary_owners) == 0 ? lookup(var.amis_os_map_owners, lookup(local.expanded_ec2_list_manager[count.index], "os")) : var.amis_primary_owners]
}

#########################################
# Docker Swarm manager EC2 Configuration
#########################################
resource "aws_instance" "swarm_manager" {
  count = var.create_cluster && length(local.expanded_ec2_list_manager) > 0 ? length(local.expanded_ec2_list_manager) : 0

  ami           = element(data.aws_ami.aws_ami_id_manager.*.id, count.index)
  instance_type = lookup(local.expanded_ec2_list_manager[count.index], "instance_type")
  key_name      = lookup(local.expanded_ec2_list_manager[count.index], "key_name")

  network_interface {
    device_index         = 0
    network_interface_id = element(aws_network_interface.swarm_manager.*.id, count.index)
  }

  tags = merge(
    {
      "Name" = format("swarm-manager-%s", var.environment)
    },
    lookup(local.expanded_ec2_list_manager[count.index], "tags")
  )
}