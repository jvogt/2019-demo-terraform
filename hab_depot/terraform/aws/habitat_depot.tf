data "template_file" "bldr_env" {
  template = "${file("${path.module}/../common/bldr.env.tpl")}"

  vars {
    habitat_depot_hostname = "${var.habitat_depot_hostname}"
    habitat_oauth_provider = "${var.habitat_oauth_provider}"
    habitat_oauth_userinfo_url = "${var.habitat_oauth_userinfo_url}"
    habitat_oauth_authorize_url = "${var.habitat_oauth_authorize_url}"
    habitat_oauth_token_url = "${var.habitat_oauth_token_url}"
    habitat_oauth_client_id = "${var.habitat_oauth_client_id}"
    habitat_oauth_signup_url = "${var.habitat_oauth_signup_url}"
    habitat_oauth_client_secret = "${var.habitat_oauth_client_secret}"
  }
}

data "template_file" "install_habitat" {
  template = "${file("${path.module}/../common/install_habitat.sh.tpl")}"
  vars {
    habitat_depot_hostname = "${var.habitat_depot_hostname}"
  }
}

resource "aws_instance" "habitat_depot" {
  connection {
    user        = "${var.aws_ubuntu_image_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                    = "${var.aws_ami_id == "" ? data.aws_ami.ubuntu.id : var.aws_ami_id}"
  instance_type          = "t3.large"
  key_name               = "${var.aws_key_pair_name}"
  subnet_id              = "${aws_subnet.habitat_depot-subnet-a.id}"
  vpc_security_group_ids = ["${aws_security_group.habitat_depot.id}"]
  ebs_optimized          = true

  root_block_device {
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }

  tags {
    Name          = "habitat_depot_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "file" {
    destination = "/tmp/bldr.env"
    content     = "${data.template_file.bldr_env.rendered}"
  }

  provisioner "file" {
    destination = "/tmp/install_habitat.sh"
    content     = "${data.template_file.install_habitat.rendered}"
  }

  provisioner "file" {
    destination = "/tmp/origin-setup.sql"
    content     = "${file("${path.module}/../common/origin-setup.sql")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/install_habitat.sh",
      "sudo bash /tmp/install_habitat.sh"
    ]
  }
}

output "habitat_depot_public_ip" {
  value = "${aws_instance.habitat_depot.public_ip}"
}