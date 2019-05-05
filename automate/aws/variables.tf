////////////////////////////////
// AWS Connection

variable "aws_region" {
  default="us-east-1"
  description = "aws_region is the AWS region in which we will build instances"
}

variable "aws_profile" {
  default="default"
  description = "aws_profile is the profile from your credentials file which we will use to authenticate to the AWS API."
}

variable "aws_key_pair_name" {
  default="habichef_demo"
  description = "aws_key_pair_naem is the AWS keypair we will configure on all newly built instances."
}

variable "aws_key_pair_file" {
  description = "aws_key_pair_file is the local SSH private key we will use to log in to AWS instances"
}

////////////////////////////////
// Object Tags

variable "tag_customer" {
  description = "tag_customer is the customer tag which will be added to AWS"
}

variable "tag_project" {
  description = "tag_project is the project tag which will be added to AWS"
}

variable "tag_name" {
  description = "tag_name is the name tag which will be added to AWS"
}

variable "tag_dept" {
  description = "tag_dept is the department tag which will be added to AWS"
}

variable "tag_contact" {
  description = "tag_contact is the contact tag which will be added to AWS"
}

variable "tag_application" {
  description = "tag_application is the application tag which will be added to AWS"
}

variable "tag_ttl" {
  default = 8
}

////////////////////////////////
// OS Variables

variable "aws_centos_image_user" {
  default = "centos"
  description = "aws_centos_image_user is the username which will be used to log in to centos instances on AWS"
}

variable "aws_ubuntu_image_user" {
  default = "ubuntu"
  description = "aws_ubuntu_image_user is the username which will be used to log in to ubuntu instances on AWS"
}

variable "platform" {
  default = "ubuntu"
  description = "platform will be used to specify the correctl home directory to be used during A2 setup"
}


////////////////////////////////
// Chef Automate

variable "channel" {
  default="current"
  description = "channel is the habitat channel which will be used for installing A2"
}

variable "automate_hostname" {
  description = "automate_hostname is the hostname which will be given to your A2 instance"
}

variable "automate_license" {
  default = "Contact Chef Sales at sales@chef.io to request a license."
  description = "automate_license is the license key for your A2 installation"
}

variable "automate_alb_acm_matcher" {
  default = "*.chef-demo.com"
  description = "Matcher to look up the ACM cert for the ALB (when using chef_automate_alb.tf"
}

variable "automate_alb_r53_matcher" {
  default = "chef-demo.com."
  description = "Matcher to find the r53 zone"
}

variable "automate_server_instance_type" {
  default = "m4.xlarge"
  description = "automate_server_instance_type is the AWS instance type to be used for A2"
}

variable "automate_api_token" {
  default = "api-token-for-compliance-demo"
  description = "Hardcoded API token for compliance"
}

variable "automate_channel" {
  default = "current"
  description = ""
}

variable "automate_admin_password" {
  default = "automatedemo"
  description = "Resets admin password"
}