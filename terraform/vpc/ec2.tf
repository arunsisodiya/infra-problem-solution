/*==== Bastion host configuration ======*/

#################################
# Bastion Host Network Interface
################################
resource "aws_network_interface" "bastion" {
  count = var.create_vpc && var.bastion_host ? 1 : 0

  subnet_id       = element(aws_subnet.public.*.id, 0)
  security_groups = [element(aws_security_group.allow_ssh.*.id, count.index)]

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
    var.eni_tags
  )
}

##################
# AWS AMI ID Data
##################
data "aws_ami" "aws_ami_id" {
  count = var.create_vpc && var.bastion_host ? 1 : 0

  most_recent = true
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  name_regex = lookup(var.amis_os_map_regex, var.os)
  owners = [length(var.amis_primary_owners) == 0 ? lookup(var.amis_os_map_owners, var.os) : var.amis_primary_owners]
}

#################################
# Bastion Host EC2 Configuration
################################
resource "aws_instance" "bastion" {
  count = var.create_vpc && var.bastion_host ? 1 : 0

  ami           = element(data.aws_ami.aws_ami_id.*.id, count.index)
  instance_type = var.instance_type
  key_name      = var.bastion_key_name
//  user_data     = local.user_data

  network_interface {
    device_index         = 0
    network_interface_id = element(aws_network_interface.bastion.*.id, count.index)
  }

  tags = merge(
    {
      "Name" = format("ec2-%s-bastion", trimsuffix(var.name, "-vpc"))
    },
    var.tags,
    var.ec2_tags
  )
}

#################################
# Bastion Host Key Pair
################################
//resource "tls_private_key" "private_key" {
//  count = var.create_vpc && var.bastion_host ? 1 : 0
//
//  algorithm = "RSA"
//}
//
//resource "aws_key_pair" "bastion_key_pair" {
//  count = var.create_vpc && var.bastion_host ? 1 : 0
//
//  key_name   = var.bastion_key_name
//  public_key = element(tls_private_key.private_key.*.public_key_openssh, count.index)
//}
//
//locals {
//  user_data = <<-EOF
//              #! /bin/bash
//              cat ~/.ssh/id_rsa_pub
//  EOF
//}