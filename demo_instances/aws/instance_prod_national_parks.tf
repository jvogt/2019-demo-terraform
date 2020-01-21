resource "aws_instance" "prod" {
  connection {
    user        = "${var.aws_centos_image_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }
  count = 15

  ami                    = "${data.aws_ami.centos.id}"
  instance_type          = "${var.demo_instance_type}"
  key_name               = "${var.aws_key_pair_name}"
  subnet_id              = "${aws_subnet.demo_instances-subnet-a.id}"
  vpc_security_group_ids = ["${aws_security_group.demo_instances.id}"]
  ebs_optimized          = true

  root_block_device {
    delete_on_termination = true
  }

  tags {
    Name          = "prod_${random_id.instance_id.hex}_${count.index + 1}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname prod-app-${count.index + 1}",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /hab/accepted-licenses",
      "mkdir -p ~/.hab/accepted-licenses",
      "sudo touch ~/.hab/accepted-licenses/habitat",
      "sudo touch /hab/accepted-licenses/habitat"
    ]
  }

  provisioner "habitat" {
    channel = "unstable"
    use_sudo = true
    service_type = "systemd"
    peer = "${aws_instance.permanent_peer.private_ip}"

    service {
      name = "jvdemo/chef-linux-hardening-demo"
      channel = "stable"
      strategy = "at-once"
      group = "prod"
    }
    service {
      name = "jvdemo/national-parks"
      channel = "stable"
      strategy = "at-once"
      group = "prod"
      binds = ["database:mongodb.prod"]
    }
    # service {
    #   name = "jvdemo/inspec-cis-centos7-demo"
    #   channel = "stable"
    #   strategy = "at-once"
    # }
  }
  provisioner "file" {
    destination = "/tmp/enable_eas.sh"
    content     = "${data.template_file.enable_automate_eas_linux_prod.rendered}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/enable_eas.sh",
      "sudo bash /tmp/enable_eas.sh",
    ]
  }
}


data "template_file" "enable_automate_eas_linux_prod" {
  template = "${file("${path.module}/../common/templates/enable_eas.sh")}"

  vars {
    automate_hostname = "${var.automate_hostname}"
    automate_api_token = "${var.automate_api_token}"
    app = "national-parks"
    env = "prod"
  }
}

output "ssh_public_ip_prod" {
  value = "${element(concat(aws_instance.prod.*.public_ip, list("")), 0)}"
}