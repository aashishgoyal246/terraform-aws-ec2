#Module      : EC2
#Description : Terraform module to create an EC2 resource on AWS with Elastic IP Addresses #              and Elastic Block Store.
output "public_instance_id" {
  value       = module.ec2_public.instance_id
  description = "The public instance ID."
}

output "private_instance_id" {
  value       = module.ec2_private.instance_id
  description = "The private instance ID."
}

output "public_tags" {
  value       = module.ec2_public.tags
  description = "Public tags associated to the resources."
}

output "private_tags" {
  value       = module.ec2_private.tags
  description = "Private tags associated to the resources."
}