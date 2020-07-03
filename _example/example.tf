provider "aws" {
  region = "ap-south-1"
}

module "keypair" {
  source = "git::https://github.com/aashishgoyal246/terraform-aws-keypair.git?ref=tags/0.12.0"

  enabled  = true
  key_name = "ssh-key"
  key_path = "~/.ssh/id_rsa.pub"
}

module "vpc" {
  source = "git::https://github.com/aashishgoyal246/terraform-aws-vpc.git?ref=tags/0.12.0"

  name        = "vpc"
  application = "aashish"
  environment = "test"
  label_order = ["environment", "application", "name"]

  enabled                          = true
  cidr_block                       = "10.10.0.0/16"
  assign_generated_ipv6_cidr_block = true
}

module "public_private_subnet" {
  source = "git::https://github.com/aashishgoyal246/terraform-aws-subnet.git?ref=tags/0.12.0"

  name        = "public-private-subnet"
  application = "aashish"
  environment = "test"
  label_order = ["environment", "application", "name"]

  enabled             = true
  availability_zones  = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  vpc_id              = module.vpc.vpc_id
  type                = "public-private"
  igw_id              = module.vpc.ig_id
  nat_gateway_enabled = true
  cidr_block          = module.vpc.vpc_cidr_block
  ipv6_enabled        = true
  ipv6_cidr_block     = module.vpc.vpc_ipv6_cidr_block
}

module "http_https" {
  source = "git::https://github.com/aashishgoyal246/terraform-aws-security-group.git?ref=tags/0.12.0"

  name        = "http-https"
  application = "aashish"
  environment = "test"
  label_order = ["environment", "application", "name"]

  enabled       = true
  vpc_id        = module.vpc.vpc_id
  description   = "Security Group for WebServer."
  protocol      = "tcp"
  allowed_ip    = ["0.0.0.0/0"]
  allowed_ports = [80, 443]

  ipv6_enabled = true
  allowed_ipv6 = ["::/0"]
}

module "ssh" {
  source = "git::https://github.com/aashishgoyal246/terraform-aws-security-group.git?ref=tags/0.12.0"

  name        = "ssh"
  application = "aashish"
  environment = "test"
  label_order = ["environment", "application", "name"]

  enabled       = true
  vpc_id        = module.vpc.vpc_id
  description   = "Security Group for SSH."
  protocol      = "tcp"
  allowed_ip    = ["49.36.131.84/32", module.vpc.vpc_cidr_block]
  allowed_ports = [22]

  ipv6_enabled = true
  allowed_ipv6 = ["2405:201:5e00:36ff:e1ba:13a0:2de:89af/128", module.vpc.vpc_ipv6_cidr_block]
}

module "iam_role" {
  source = "git::https://github.com/aashishgoyal246/terraform-aws-iam-role.git?ref=tags/0.12.1"

  name               = "iam-role"
  application        = "aashish"
  environment        = "test"
  label_order        = ["environment", "application", "name"]
  
  enabled            = true
  assume_role_policy = data.aws_iam_policy_document.default.json
  policy_enabled     = true
  policy             = data.aws_iam_policy_document.iam_policy.json
}

data "aws_iam_policy_document" "default" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "iam_policy" {
  statement {
    actions = [
      "s3:*"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

module "ec2_public" {
  source = "../"

  name        = "ec2-public-instance"
  application = "aashish"
  environment = "test"
  label_order = ["environment", "application", "name"]

  enabled                = true
  instance_count         = 1
  ami                    = "ami-02d55cb47e83a99a0"
  instance_type          = "t2.micro"
  monitoring             = false
  tenancy                = "default"
  vpc_security_group_ids = [module.ssh.security_group_id, module.http_https.security_group_id]
  subnet_ids             = module.public_private_subnet.public_subnet_id

  assign_eip_address          = true
  associate_public_ip_address = true

  instance_profile_enabled = true
  iam_instance_profile     = module.iam_role.name
  key_name                 = module.keypair.key_name

  volume_type        = "standard"
  volume_size        = 8
  ebs_optimized      = false
  ebs_volume_enabled = false
  ebs_volume_type    = "gp2"
  ebs_volume_size    = 30

  ipv6_enabled       = true
  ipv6_address_count = 1
}

module "ec2_private" {
  source = "../"

  name        = "ec2-private-instance"
  application = "aashish"
  environment = "test"
  label_order = ["environment", "application", "name"]

  enabled                = true
  instance_count         = 1
  ami                    = "ami-02d55cb47e83a99a0"
  instance_type          = "t2.micro"
  monitoring             = false
  tenancy                = "default"
  vpc_security_group_ids = [module.ssh.security_group_id, module.http_https.security_group_id]
  subnet_ids             = module.public_private_subnet.private_subnet_id

  instance_profile_enabled = true
  iam_instance_profile     = module.iam_role.name
  key_name                 = module.keypair.key_name

  volume_type        = "standard"
  volume_size        = 8
  ebs_optimized      = false
  ebs_volume_enabled = false
  ebs_volume_type    = "gp2"
  ebs_volume_size    = 30

  ipv6_enabled       = true
  ipv6_address_count = 1
}