#Module      : LABELS
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "application" {
  type        = string
  default     = ""
  description = "Application (e.g. `cd` or `clouddrove`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "enabled" {
  type        = bool
  default     = false
  description = "Flag to control the vpc creation."
}

variable "label_order" {
  type        = list
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `organization`, `name`, `environment` and `attributes`."
}

variable "tags" {
  type        = map
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

# Module      : EC2 Module
# Description : Terraform EC2 module variables.
variable "instance_count" {
  type        = number
  default     = 0
  description = "Number of instances to launch."
}

variable "ami" {
  type        = string
  default     = ""
  description = "The AMI to use for the instance."
}

variable "placement_group" {
  type        = string
  default     = ""
  description = "The Placement Group to start the instance in."
}

variable "tenancy" {
  type        = string
  default     = ""
  description = "The tenancy of the instance (if the instance is running in a VPC). An instance with a tenancy of dedicated runs on single-tenant hardware. The host tenancy is not supported for the import-instance command."
}

variable "host_id" {
  type        = string
  default     = null
  description = "The Id of a dedicated host that the instance will be assigned to. Use when an instance is to be launched on a specific dedicated host."
}

variable "cpu_core_count" {
  type        = string
  default     = null
  description = "Sets the number of CPU cores for an instance."
}

variable "ebs_optimized" {
  type        = bool
  default     = false
  description = "If true, the launched EC2 instance will be EBS-optimized."
}

variable "disable_api_termination" {
  type        = bool
  default     = false
  description = "If true, enables EC2 Instance Termination Protection."
}

variable "instance_initiated_shutdown_behavior" {
  type        = string
  default     = ""
  description = "Shutdown behavior for the instance." # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior
}

variable "instance_type" {
  type        = string
  default     = ""
  description = "The type of instance to start. Updates to this field will trigger a stop/start of the EC2 instance."
}

variable "key_name" {
  type        = string
  default     = ""
  description = "The key name to use for the instance."
}

variable "monitoring" {
  type        = bool
  default     = false
  description = "If true, the launched EC2 instance will have detailed monitoring enabled. (Available since v0.6.0)."
}

variable "vpc_security_group_ids" {
  type        = list(string)
  default     = []
  description = "A list of security group IDs to associate with."
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "A list of VPC Subnet IDs to launch in."
}

variable "associate_public_ip_address" {
  type        = bool
  default     = false
  description = "Associate a public IP address with the instance."
}

variable "source_dest_check" {
  type        = bool
  default     = true
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs."
}

variable "user_data" {
  type        = string
  default     = ""
  description = "The Base64-encoded user data to provide when launching the instances."
}

variable "ipv6_enabled" {
  type        = bool
  default     = false
  description = "Flag to control the IPV6 address creation."
}

variable "ipv6_address_count" {
  type        = number
  default     = 0
  description = "Number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet."
}

variable "ipv6_addresses" {
  type        = list
  default     = []
  description = "List of IPv6 addresses from the range of the subnet to associate with the primary network interface."
}

variable "volume_type" {
  type        = string
  default     = "standard"
  description = "The type of volume. Can be 'standard', 'gp2', 'io1', 'sc1', or 'st1'. (Default: 'standard')."
}

variable "volume_size" {
  type        = number
  default     = 8
  description = "Size of the root volume in gigabytes."
}

variable "iops" {
  type        = number
  default     = 0
  description = "Amount of provisioned IOPS. This must be set with a volume_type of io1."
}

variable "encrypted" {
  type        = bool
  default     = false
  description = "If true, the disk will be encrypted."
}

variable "kms_key_id" {
  type        = string
  default     = ""
  description = "The ARN for the KMS encryption key. When specifying kms_key_id, encrypted needs to be set to true."
}

variable "cpu_credits" {
  type        = string
  default     = "standard"
  description = "The credit option for CPU usage. Can be `standard` or `unlimited`. T3 instances are launched as unlimited by default. T2 instances are launched as standard by default."
}

variable "assign_eip_address" {
  type        = bool
  default     = false
  description = "Assign an Elastic IP address to the instance."
}

variable "instance_tags" {
  type        = map
  default     = {}
  description = "Instance tags."
}

variable "ebs_volume_enabled" {
  type        = bool
  default     = false
  description = "Flag to control the ebs creation."
}

variable "ebs_volume_size" {
  type        = number
  default     = 30
  description = "Size of the EBS volume in gigabytes."
}

variable "ebs_volume_type" {
  type        = string
  default     = "gp2"
  description = "The type of EBS volume. Can be standard, gp2 or io1."
}

variable "ebs_iops" {
  type        = number
  default     = 0
  description = "Amount of provisioned IOPS. This must be set with a volume_type of io1."
}

variable "ebs_device_name" {
  type        = list(string)
  default     = ["/dev/xvdb", "/dev/xvdc", "/dev/xvdd", "/dev/xvde", "/dev/xvdf", "/dev/xvdg", "/dev/xvdh", "/dev/xvdi", "/dev/xvdj", "/dev/xvdk", "/dev/xvdl", "/dev/xvdm", "/dev/xvdn", "/dev/xvdo", "/dev/xvdp", "/dev/xvdq", "/dev/xvdr", "/dev/xvds", "/dev/xvdt", "/dev/xvdu", "/dev/xvdv", "/dev/xvdw", "/dev/xvdx", "/dev/xvdy", "/dev/xvdz"]
  description = "Name of the EBS device to mount."
}

variable "instance_profile_enabled" {
  type        = bool
  default     = false
  description = "Flag to control the instance profile creation."
}

variable "iam_instance_profile" {
  type        = string
  default     = ""
  description = "The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
}