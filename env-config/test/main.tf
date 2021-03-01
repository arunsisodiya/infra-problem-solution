provider "aws" {
  region = var.region
}

locals {
  network_acl_map = {
    private_inbound = [{
      rule_number = 100
      rule_action = "allow"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_block  = module.vpc.public_subnet_cidr_block
      },
      {
        rule_number = 200
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = module.vpc.public_subnet_cidr_block
      },
      {
        rule_number = 300
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
    }]
    private_outbound = [{
      rule_number = 100
      rule_action = "allow"
      protocol    = "-1"
      cidr_block  = module.vpc.public_subnet_cidr_block
      },
      {
        rule_number = 200
        rule_action = "allow"
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
    }]
    public_inbound = [{
      rule_number = 200
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 300
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 400
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 500
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
    }]
    public_outbound = [{
      rule_number = 100
      rule_action = "allow"
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    }]
  }

  swarm_security_group_rules = [{
    type                     = "ingress"
    protocol                 = "tcp"
    description              = "Allow SSH access from bastion host"
    from_port                = 22
    to_port                  = 22
    cidr_blocks              = []
    source_security_group_id = [join(",", module.vpc.bastion_security_groups)]
    },
    {
      type                     = "ingress"
      protocol                 = "tcp"
      description              = "Allow access to application and health endpoints"
      from_port                = 8080
      to_port                  = 8080
      cidr_blocks              = []
      source_security_group_id = [join(",", module.vpc.bastion_security_groups)]
    },
    {
      type                     = "egress"
      protocol                 = "-1"
      description              = "Allow outbound traffic to bastion host"
      from_port                = 0
      to_port                  = 0
      cidr_blocks              = []
      source_security_group_id = [join(",", module.vpc.bastion_security_groups)]
    },
    {
      type                     = "ingress"
      protocol                 = "tcp"
      description              = "Docker swarm TCP port for cluster management communications"
      from_port                = 2377
      to_port                  = 2377
      cidr_blocks              = []
      source_security_group_id = [module.docker-swarm.docker_swarm_security_group]
    },
    {
      type                     = "ingress"
      protocol                 = "tcp"
      description              = "Docker swarm TCP port for communication among nodes"
      from_port                = 7946
      to_port                  = 7946
      cidr_blocks              = []
      source_security_group_id = [module.docker-swarm.docker_swarm_security_group]
    },
    {
      type                     = "ingress"
      protocol                 = "udp"
      description              = "Docker swarm UDP port for communication among nodes"
      from_port                = 7946
      to_port                  = 7946
      cidr_blocks              = []
      source_security_group_id = [module.docker-swarm.docker_swarm_security_group]
    },
    {
      type                     = "ingress"
      protocol                 = "udp"
      description              = "Docker swarm UDP port for overlay network traffic"
      from_port                = 4789
      to_port                  = 4789
      cidr_blocks              = []
      source_security_group_id = [module.docker-swarm.docker_swarm_security_group]
    },
    {
      type                     = "egress"
      protocol                 = "-1"
      description              = "Allow outbound traffic to docker swarm"
      from_port                = 0
      to_port                  = 0
      cidr_blocks              = []
      source_security_group_id = [module.docker-swarm.docker_swarm_security_group]
    },
    {
      type                     = "egress"
      protocol                 = "-1"
      description              = "Allow outbound traffic to internet"
      from_port                = 0
      to_port                  = 0
      cidr_blocks              = ["0.0.0.0/0"]
      source_security_group_id = []
    }
  ]
}

module "vpc" {

  source           = "../../terraform/vpc"
  name             = "infra-test-vpc"
  environment      = var.environment
  cidr             = "10.0.0.0/16"
  instance_tenancy = "default"

  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.0.0/24"]
  azs             = ["eu-central-1a"]

  bastion_host               = true
  bastion_key_name           = var.key_pair
  os                         = "ubuntu-16.04"
  private_nat_gateway        = true
  private_network_acl        = true
  private_inbound_acl_rules  = concat(local.network_acl_map["private_inbound"])
  private_outbound_acl_rules = concat(local.network_acl_map["private_outbound"])

  public_network_acl        = true
  public_inbound_acl_rules  = concat(local.network_acl_map["public_inbound"])
  public_outbound_acl_rules = concat(local.network_acl_map["public_outbound"])

  tags = {
    "environment" = var.environment
  }

  private_subnets_tags = {
    "subnet-type" = "private"
  }

  public_subnets_tags = {
    "subnet-type" = "public"
  }

  ec2_tags = {
    "environment" = var.environment
  }
}

module "docker-swarm" {
  source = "../../terraform/docker-swarm"

  vpc_id                     = module.vpc.vpc_id
  environment                = var.environment
  private_subnet_ids         = module.vpc.private_subnets_id
  public_subnet_ids          = module.vpc.public_subnets_id
  create_cluster             = true
  swarm_security_group_rules = local.swarm_security_group_rules
  bastion_security_groups    = module.vpc.bastion_security_groups
  bastion_instance_ip        = module.vpc.bastion_instance_ip
  cluster-vms = [
    {
      count         = 1
      os            = "ubuntu-16.04"
      instance_type = "t2.micro"
      ami_username  = "ubuntu"
      key_name      = var.key_pair
      role          = "manager"
      tags = {
        "role"        = "manager"
        "environment" = var.environment
      }
    },
    {
      count         = 1
      os            = "ubuntu-16.04"
      instance_type = "t2.micro"
      ami_username  = "ubuntu"
      key_name      = var.key_pair
      role          = "worker"
      tags = {
        "role"        = "worker"
        "environment" = var.environment
      }
    }
  ]

  depends_on = [module.vpc]
}