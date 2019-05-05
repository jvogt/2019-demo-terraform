terraform {
  required_version = "~> 0.11.11"
}

provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

resource "aws_s3_bucket" "terraform-state-storage-s3" {
  bucket = "terraform-remote-state-${var.tag_contact}-chef"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name          = "Terraform Remote State for ${var.tag_contact}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "Internal"
    X-Project     = "Terraform"
    X-Application = "Terraform"
    X-Contact     = "${var.tag_contact}"
  }      
}
