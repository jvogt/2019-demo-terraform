
terraform {
  required_version = "~> 0.11.11"
  backend "s3" {
    encrypt = true
    bucket  = "terraform-remote-state-${var.tag_contact}-chef"
    region  = "${var.aws_region}"
    key     = "${random_id.instance_id.hex}/automate"
  }
}

provider "aws" {
  region                  = "${var.aws_region}"
  profile                 = "${var.aws_profile}"
}

resource "random_id" "instance_id" {
  byte_length = 4
}

////////////////////////////////
// Instance Data

data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["chef-highperf-centos7-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["446539779517"]
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "aws_ami" "ubuntu16" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}