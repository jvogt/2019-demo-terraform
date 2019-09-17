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

variable "aws_ami_id" {
  description = "aws_ami_id is the (optional) AWS AMI to use when building new instances if you would prefer to specify a specific AMI instead of using the latest for your platform."
  default = ""
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
// Habitat Depot

variable "habitat_depot_hostname" {
  default = "demo-hab-depot.chef-demo.com"
  description = "Hostname of the hab depot"
}
variable "habitat_oauth_provider" {
  default = "github"
  description = ""
}
variable "habitat_oauth_userinfo_url" {
  default = "https://api.github.com/user"
  description = ""
}
variable "habitat_oauth_authorize_url" {
  default = "https://github.com/login/oauth/authorize"
  description = ""
}
variable "habitat_oauth_token_url" {
  default = "https://github.com/login/oauth/access_token"
  description = ""
}
variable "habitat_oauth_client_id" {
  default = "abcd1234"
  description = ""
}
variable "habitat_oauth_client_secret" {
  default = "abcd1234zyxw0987"
  description = ""
}
variable "habitat_oauth_signup_url" {
  default = "https://github.com/join"
  description = ""
}
variable "habitat_depot_alb_acm_matcher" {
  default = ""
  description = "Matcher to look up the ACM cert for the ALB (when using habitat_depot_alb.tf"
}
variable "habitat_depot_alb_r53_matcher" {
  default = ""
  description = "Matcher to find the r53 zone"
}
