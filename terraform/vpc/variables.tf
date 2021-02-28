variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
  default     = true
}

variable "name" {
  description = "Define name of VPC used as identifier"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment where swarm will spin up"
  type        = string
  default     = ""
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_tenancy" {
  description = "Define tenancy of instances inside VPC"
  type        = string
  default     = ""
}

variable "assign_generated_ipv6_cidr_block" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block."
  type        = bool
  default     = false

}

variable "tags" {
  description = "Tags to be added to all resources"
  type        = map(string)
  default     = {}
}

variable "azs" {
  description = "Availability zone for subnets"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of AWS private_subnets inside VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets_suffix" {
  description = "Suffix to be added to private subnets"
  type        = string
  default     = "private"
}

variable "private_subnets_tags" {
  description = "Tags for private subnets"
  type        = map(string)
  default     = {}
}

variable "public_subnets" {
  description = "List of AWS public_subnets inside VPC"
  type        = list(string)
  default     = []
}

variable "public_subnets_suffix" {
  description = "Suffix to be added to public subnets"
  type        = string
  default     = "public"
}

variable "public_subnets_tags" {
  description = "Tags for public subnets"
  type        = map(string)
  default     = {}
}

variable "map_public_ip_on_launch" {
  description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address."
  type        = string
  default     = true
}

variable "create_igw" {
  description = "Controls if Internet Gateway should be created"
  type        = bool
  default     = true
}

variable "igw_tags" {
  description = "Specify tags for Internet Gateway"
  type        = map(string)
  default     = {}
}

variable "public_route_table_tags" {
  description = "Tags for public route tables"
  type        = map(string)
  default     = {}
}

variable "private_route_table_tags" {
  description = "Tags for private route tables"
  type        = map(string)
  default     = {}
}

variable "public_network_acl" {
  description = "Flag to state if ACL is needed for public_network_acl"
  type        = bool
  default     = false
}

variable "private_network_acl" {
  description = "Flag to state if ACL is needed for private_network_acl"
  type        = bool
  default     = false
}

variable "public_acl_tags" {
  description = "Tags for public network ACL"
  type        = map(string)
  default     = {}
}

variable "public_inbound_acl_rules" {
  description = "Public inbound rules for subnets"
  type        = list(map(string))
  default = [{
    rule_number = 100
    rule_action = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "public_outbound_acl_rules" {
  description = "Public outbound rules for subnets"
  type        = list(map(string))
  default = [{
    rule_number = 100
    rule_action = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "private_acl_tags" {
  description = "Tags for private network ACL"
  type        = map(string)
  default     = {}
}

variable "private_inbound_acl_rules" {
  description = "Private inbound rules for subnets"
  type        = list(map(string))
  default = [{
    rule_number = 100
    rule_action = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "private_outbound_acl_rules" {
  description = "Private outbound rules for subnets"
  type        = list(map(string))
  default = [{
    rule_number = 100
    rule_action = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "bastion_host" {
  description = "Boolean flag to define whether the bastion host needed or not"
  type        = bool
  default     = true
}

variable "eni_tags" {
  description = "Tags for Elastic network interface"
  type        = map(string)
  default     = {}
}

variable "os" {
  description = "Operating system for the EC2 instance"
  type        = string
  default     = "ubuntu-16.04"
}

variable "instance_type" {
  description = "EC2 AMI instance type"
  type        = string
  default     = "t2.micro"
}

variable "ec2_tags" {
  description = "Tags for EC2 instance"
  type        = map(string)
  default     = {}
}

variable "bastion_key_name" {
  description = "Define key pair name for bastion host"
  type        = string
  default     = ""
}

variable "private_nat_gateway" {
  description = "Boolean flag to create NAT gateway for private subnets"
  type        = bool
  default     = false
}

variable "amis_primary_owners" {
  description = "Force the ami Owner, could be (self) or specific (id)"
  default     = ""
}

variable "amis_os_map_regex" {
  description = "Map of regex to search amis"
  type        = map(string)

  default = {
    "ubuntu"               = "^ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-.*"
    "ubuntu-14.04"         = "^ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-.*"
    "ubuntu-16.04"         = "^ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-.*"
    "ubuntu-18.04"         = "^ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-.*"
    "ubuntu-18.10"         = "^ubuntu/images/hvm-ssd/ubuntu-cosmic-18.10-amd64-server-.*"
    "ubuntu-19.04"         = "^ubuntu/images/hvm-ssd/ubuntu-disco-19.04-amd64-server-.*"
    "centos"               = "^CentOS.Linux.7.*x86_64.*"
    "centos-6"             = "^CentOS.Linux.6.*x86_64.*"
    "centos-7"             = "^CentOS.Linux.7.*x86_64.*"
    "centos-8"             = "^CentOS.Linux.8.*x86_64.*"
    "rhel"                 = "^RHEL-7.*x86_64.*"
    "rhel-6"               = "^RHEL-6.*x86_64.*"
    "rhel-7"               = "^RHEL-7.*x86_64.*"
    "rhel-8 "              = "^RHEL-8.*x86_64.*"
    "debian"               = "^debian-stretch-.*"
    "debian-8"             = "^debian-jessie-.*"
    "debian-9"             = "^debian-stretch-.*"
    "debian-10"            = "^debian-10-.*"
    "fedora-27"            = "^Fedora-Cloud-Base-27-.*-gp2.*"
    "amazon"               = "^amzn-ami-hvm-.*x86_64-gp2"
    "amazon-2_lts"         = "^amzn2-ami-hvm-.*x86_64-gp2"
    "suse-les"             = "^suse-sles-12-sp\\d-v\\d{8}-hvm-ssd-x86_64"
    "suse-les-12"          = "^suse-sles-12-sp\\d-v\\d{8}-hvm-ssd-x86_64"
    "windows"              = "^Windows_Server-2019-English-Full-Base-.*"
    "windows-2019-base"    = "^Windows_Server-2019-English-Full-Base-.*"
    "windows-2016-base"    = "^Windows_Server-2016-English-Full-Base-.*"
    "windows-2012-r2-base" = "^Windows_Server-2012-R2_RTM-English-64Bit-Base-.*"
    "windows-2012-base"    = "^Windows_Server-2012-RTM-English-64Bit-Base-.*"
    "windows-2008-r2-base" = "^Windows_Server-2008-R2_SP1-English-64Bit-Base-.*"
  }
}

variable "amis_os_map_owners" {
  description = "Map of amis owner to filter only official amis"
  type        = map(string)
  default = {
    ubuntu               = "099720109477" #CANONICAL
    "ubuntu-14.04"       = "099720109477" #CANONICAL
    "ubuntu-16.04"       = "099720109477" #CANONICAL
    "ubuntu-18.04"       = "099720109477" #CANONICAL
    "ubuntu-18.10"       = "099720109477" #CANONICAL
    "ubuntu-19.04"       = "099720109477" #CANONICAL
    rhel                 = "309956199498" #Amazon Web Services
    rhel-6               = "309956199498" #Amazon Web Services
    rhel-7               = "309956199498" #Amazon Web Services
    rhel-8               = "309956199498" #Amazon Web Services
    centos               = "679593333241"
    centos-6             = "679593333241"
    centos-7             = "679593333241"
    centos-8             = "679593333241"
    debian               = "679593333241"
    debian-8             = "679593333241"
    debian-9             = "679593333241"
    "debian-10"          = "136693071363"
    fedora-27            = "125523088429" #Fedora
    amazon               = "137112412989" #amazon
    amazon-2_lts         = "137112412989" #amazon
    suse-les             = "013907871322" #amazon
    suse-les-12          = "013907871322" #amazon
    windows              = "801119661308" #amazon
    windows-2019-base    = "801119661308" #amazon
    windows-2016-base    = "801119661308" #amazon
    windows-2012-r2-base = "801119661308" #amazon
    windows-2012-base    = "801119661308" #amazon
    windows-2008-r2-base = "801119661308" #amazon
  }
}
