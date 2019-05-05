resource "aws_instance" "chef_automate" {
  connection {
    user        = "${var.aws_ubuntu_image_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.automate_server_instance_type}"
  key_name               = "${var.aws_key_pair_name}"
  subnet_id              = "${aws_subnet.automate-subnet-a.id}"
  vpc_security_group_ids = ["${aws_security_group.chef_automate.id}"]
  ebs_optimized          = true

  root_block_device {
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }

  tags {
    Name          = "chef_automate_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "file" {
    destination = "/tmp/install_chef_automate_cli.sh"
    content     = "${data.template_file.install_chef_automate_cli.rendered}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/install_chef_automate_cli.sh",
      "sudo bash /tmp/install_chef_automate_cli.sh",
    ]
  }

  provisioner "local-exec" {
    // Clean up local known_hosts in case we get a re-used public IP
    command = "ssh-keygen -R ${aws_instance.chef_automate.public_ip}"
  }

  provisioner "local-exec" {
    // Write ssh key for Automate server to local known_hosts so we can scp automate-credentials.toml in data.external.a2_secrets
    command = "ssh-keyscan -t ecdsa ${aws_instance.chef_automate.public_ip} >> ~/.ssh/known_hosts"
  }
}

data "template_file" "install_chef_automate_cli" {
  template = "${file("${path.module}/../common/templates/install_chef_automate_cli.sh.tpl")}"

  vars {
    automate_hostname = "${var.automate_hostname}"
    channel = "${var.automate_channel}"
    automate_license = "${var.automate_license}"
    compliance_api_token = "${var.automate_api_token}"
    a2_admin_password = "${var.automate_admin_password}"
    preload_profiles = "${var.automate_preload_profiles}"
  }
}

output "a2_instance_ssh_ip" {
  value = "${aws_instance.chef_automate.public_ip}"
}

output "a2_url" {
  value = "${var.automate_hostname}"
}

output "a2_admin_password" {
  value = "${var.automate_admin_password}"
}

output "a2_token" {
  value = "${var.automate_api_token}"
}

