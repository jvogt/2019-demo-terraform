resource "aws_instance" "chef_server" {
  connection {
    user        = "${var.aws_ubuntu_image_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.chef_server_instance_type}"
  key_name               = "${var.aws_key_pair_name}"
  subnet_id              = "${aws_subnet.chef-server-subnet-a.id}"
  vpc_security_group_ids = ["${aws_security_group.chef_server.id}"]
  ebs_optimized          = true

  root_block_device {
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }

  tags {
    Name          = "chef_server_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "file" {
    destination = "/tmp/install_chef_server_cli.sh"
    content     = "${data.template_file.install_chef_server_cli.rendered}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/install_chef_server_cli.sh",
      "sudo bash /tmp/install_chef_server_cli.sh",
    ]
  }

  provisioner "local-exec" {
    // Clean up local known_hosts in case we get a re-used public IP
    command = "ssh-keygen -R ${aws_instance.chef_server.public_ip}"
  }

}

data "template_file" "install_chef_server_cli" {
  template = "${file("${path.module}/../common/templates/install_chef_server_cli.sh.tpl")}"

  vars {
    chef_server_hostname = "${var.chef_server_hostname}"
    automate_hostname = "${var.automate_hostname}"
    compliance_api_token = "${var.automate_api_token}"
    chef_username = "${var.chef_username}"
    chef_user = "${var.chef_user}"
    chef_password = "${var.chef_password}"
    chef_user_email = "${var.chef_user_email}"
    chef_organization_id = "${var.chef_organization_id}"
    chef_organization_name = "${var.chef_organization_name}"
  }
}

output "chef_server_instance_ssh_ip" {
  value = "${aws_instance.chef_server.public_ip}"
}

output "chef_server_url" {
  value = "https://${var.chef_server_hostname}"
}
