#Module      : LABELS
#Description : This terraform module is designed to generate consistent label names and tags
#              for resources. You can use terraform-labels to implement a strict naming
#              convention.
module "labels" {
  source = "git::https://github.com/aashishgoyal246/terraform-labels.git?ref=tags/0.12.0"

  name        = var.name
  application = var.application
  environment = var.environment
  enabled     = var.enabled
  label_order = var.label_order
  tags        = var.tags
}

#Module      : EC2
#Description : Terraform module to create an EC2 resource on AWS with Elastic IP Addresses
#              and Elastic Block Store.
resource "aws_instance" "default" {
  count = var.enabled ? var.instance_count : 0

  ami                                  = var.ami
  placement_group                      = var.placement_group
  tenancy                              = var.tenancy
  host_id                              = var.host_id
  cpu_core_count                       = var.cpu_core_count
  ebs_optimized                        = var.ebs_optimized
  disable_api_termination              = var.disable_api_termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type                        = var.instance_type
  key_name                             = var.key_name
  monitoring                           = var.monitoring
  vpc_security_group_ids               = var.vpc_security_group_ids
  subnet_id                            = element(distinct(compact(concat(var.subnet_ids))), count.index)
  associate_public_ip_address          = var.associate_public_ip_address
  source_dest_check                    = var.source_dest_check
  user_data                            = var.user_data != "" ? base64encode(file(var.user_data)) : ""
  iam_instance_profile                 = var.instance_profile_enabled ? join("", aws_iam_instance_profile.default.*.name) : ""
  ipv6_address_count                   = var.ipv6_enabled ? var.ipv6_address_count : 0
  ipv6_addresses                       = var.ipv6_enabled ? var.ipv6_addresses : []
  
  root_block_device {
    volume_type           = var.volume_type
    volume_size           = var.volume_size
    iops                  = var.volume_type == "io1" ? var.iops : 0
    delete_on_termination = true
    encrypted             = var.encrypted
    kms_key_id            = var.encrypted ? var.kms_key_id : ""
  }

  credit_specification {
    cpu_credits = var.cpu_credits
  }

  tags = merge(
    module.labels.tags,
    {

      "Name" = format("%s%s%s", module.labels.id, var.delimiter, (count.index))
    },
    var.instance_tags
  )

  volume_tags = merge(
    module.labels.tags,
    {
      "Name" = format("%s%s%s", module.labels.id, var.delimiter, (count.index))
    }
  )

  lifecycle {
    ignore_changes = [
      tags,
      ipv6_addresses,
      volume_tags,
    ]
  }
}

#Module      : EIP
#Description : Provides an Elastic IP resource.
resource "aws_eip" "default" {
  count = var.enabled && var.assign_eip_address ? var.instance_count : 0

  network_interface = element(aws_instance.default.*.primary_network_interface_id, count.index)
  vpc               = true

  tags = merge(
    module.labels.tags,
    {
      "Name" = format("%s%s%s-eip", module.labels.id, var.delimiter, count.index + 1)
    }
  )
}

#Module      : EBS VOLUME
#Description : Manages a single EBS volume.
resource "aws_ebs_volume" "default" {
  count = var.enabled && var.ebs_volume_enabled ? var.instance_count : 0

  availability_zone = element(aws_instance.default.*.availability_zone, count.index)
  size              = var.ebs_volume_size
  iops              = var.ebs_volume_type == "io1" ? var.ebs_iops : 0
  type              = var.ebs_volume_type
  encrypted         = var.encrypted
  kms_key_id        = var.kms_key_id
  
  tags = merge(
    module.labels.tags,
    {
      "Name" = format("%s%s%s", module.labels.id, var.delimiter, count.index + 1)
    }
  )
}

#Module      : VOLUME ATTACHMENT
#Description : Provides an AWS EBS Volume Attachment as a top level resource, to attach and detach volumes from AWS Instances.
resource "aws_volume_attachment" "default" {
  count = var.enabled && var.ebs_volume_enabled ? var.instance_count : 0

  device_name = element(var.ebs_device_name, count.index)
  volume_id   = element(aws_ebs_volume.default.*.id, count.index)
  instance_id = element(aws_instance.default.*.id, count.index)
}

#Module      : IAM INSTANCE PROFILE
#Description : Provides an IAM instance profile.
resource "aws_iam_instance_profile" "default" {
  count = var.enabled && var.instance_profile_enabled ? 1 : 0
  name  = format("%s%sinstance-profile", module.labels.id, var.delimiter)
  role  = var.iam_instance_profile
}