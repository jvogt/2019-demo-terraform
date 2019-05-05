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

/////////////////////////////////
// Concourse CI Variables

variable "concourse_db_node_size" {
  default = "t2.medium"
  description = "concourse_db_node_size is the AWS instance type to be used for Concourse's dabatase server"

}
variable "concourse_web_node_size" {
  default = "t2.medium"
  description = "concourse_web_node_size is the AWS instance type to be used for Concourse's web server"
}
variable "concourse_worker_node_size" {
  default = "t2.medium"
  description = "concourse_worker_node_size is the AWS instance type to be used for Concourse's worker server(s)"
}

variable "concourse_worker_count" {
  default = "3"
  description = "concourse_worker_count is the number of concourse worker servers to build. We recommend at least 2."
}

variable "concourse_user_name" {
  default = "admin"
  description = "concourse_user_name is the username which will be used to log in to the concourse web UI"
}
variable "concourse_user_password" {
  default = "O3OKE47ZhPeYUad9kXcRgD!v"
  description = "concourse_password is the password which will be used to log in to the concourse web UI"
}