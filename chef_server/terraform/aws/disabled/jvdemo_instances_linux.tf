resource "aws_instance" "dev" {
  connection {
    user        = "${var.aws_centos_image_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }
  count = 3

  ami                    = "${var.aws_ami_id == "" ? data.aws_ami.centos.id : var.aws_ami_id}"
  instance_type          = "t3.medium"
  key_name               = "${var.aws_key_pair_name}"
  subnet_id              = "${aws_subnet.habichef-subnet-a.id}"
  vpc_security_group_ids = ["${aws_security_group.chef_automate.id}"]
  ebs_optimized          = true

  tags {
    Name          = "${format("dev_${random_id.instance_id.hex}_${count.index + 1}")}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname dev-${count.index + 1}",
    ]
  }

  provisioner "habitat" {
    use_sudo = true
    service_type = "systemd"

    service {
      name = "jvogt/jv-hardening-example"
      topology = "standalone"
      channel = "unstable"
      strategy = "at-once"
    }
  }
}

resource "aws_instance" "prod" {
  connection {
    user        = "${var.aws_centos_image_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }
  count = 15

  ami                    = "${var.aws_ami_id == "" ? data.aws_ami.centos.id : var.aws_ami_id}"
  instance_type          = "t3.small"
  key_name               = "${var.aws_key_pair_name}"
  subnet_id              = "${aws_subnet.habichef-subnet-a.id}"
  vpc_security_group_ids = ["${aws_security_group.chef_automate.id}"]
  ebs_optimized          = true

  tags {
    Name          = "${format("prod_${random_id.instance_id.hex}_${count.index + 1}")}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname prod-${count.index + 1}",
    ]
  }

  provisioner "habitat" {
    use_sudo = true
    service_type = "systemd"

    service {
      name = "jvogt/jv-hardening-example"
      topology = "standalone"
      channel = "stable"
      strategy = "at-once"
    }
  }
}
