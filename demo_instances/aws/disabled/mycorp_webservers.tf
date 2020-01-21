resource "aws_instance" "staging" {
  connection {
    user        = "ec2-user"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                    = "ami-04b762b4289fba92b"
  instance_type          = "${var.demo_instance_type}"
  key_name               = "${var.aws_key_pair_name}"
  subnet_id              = "${aws_subnet.demo_instances-subnet-a.id}"
  vpc_security_group_ids = ["${aws_security_group.demo_instances.id}"]
  ebs_optimized          = true

  tags {
    Name          = "stage_${random_id.instance_id.hex}_${count.index + 1}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  root_block_device {
    delete_on_termination = true
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname mycorp_web_stg",
    ]
  }

  provisioner "chef" {
    server_url = "https://jv-chef.chef-demo.com/organizations/workshop"
    user_key = "${file("/Users/jvogt/.chef/workstation4.pem")}"
    user_name = "workstation4"
    recreate_client = true
    client_options  = ["chef_license 'accept'"]
    use_policyfile = true
    policy_group = "staging"
    policy_name = "mycorp_webserver"
    node_name = "mycorp_web_stg"
  }


}

output "stage_ip" {
  value = "${aws_instance.staging.public_ip}"
}



resource "aws_instance" "production" {
  connection {
    user        = "ec2-user"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                    = "ami-04b762b4289fba92b"
  instance_type          = "${var.demo_instance_type}"
  key_name               = "${var.aws_key_pair_name}"
  subnet_id              = "${aws_subnet.demo_instances-subnet-a.id}"
  vpc_security_group_ids = ["${aws_security_group.demo_instances.id}"]
  ebs_optimized          = true

  tags {
    Name          = "prod_${random_id.instance_id.hex}_${count.index + 1}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  root_block_device {
    delete_on_termination = true
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname mycorp_web_prd",
    ]
  }

  provisioner "chef" {
    server_url = "https://jv-chef.chef-demo.com/organizations/workshop"
    user_key = "${file("/Users/jvogt/.chef/workstation4.pem")}"
    user_name = "workstation4"
    recreate_client = true
    client_options  = ["chef_license 'accept'"]
    use_policyfile = true
    policy_group = "production"
    policy_name = "mycorp_webserver"
    node_name = "mycorp_web_prd"
  }


}

output "prod_ip" {
  value = "${aws_instance.production.public_ip}"
}