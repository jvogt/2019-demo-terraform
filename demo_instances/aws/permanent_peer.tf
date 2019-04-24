resource "aws_instance" "permanent_peer" {
  connection {
    user        = "${var.aws_ubuntu_image_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.permanent_peer_instance_type}"
  key_name               = "${var.aws_key_pair_name}"
  subnet_id              = "${aws_subnet.demo_instances-subnet-a.id}"
  vpc_security_group_ids = ["${aws_security_group.demo_instances.id}"]
  ebs_optimized          = true

  root_block_device {
    delete_on_termination = true
    volume_size           = 20
    volume_type           = "gp2"
  }

  tags {
    Name          = "${format("permanent_peer_${random_id.instance_id.hex}")}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname _permanentpeer",
    ]
  }

  provisioner "habitat" {
    permanent_peer = true
    use_sudo     = true
    service_type = "systemd"

    service {
      name = "jvogt/hab-svc-ring-viz"
      channel = "stable"
      strategy = "at-once"
    }
  }
}

output "permanent_peer_public_ip" {
  value = "${aws_instance.permanent_peer.public_ip}"
}

output "Ring Visualization" {
  value = "http://${aws_instance.permanent_peer.public_ip}:3000"
}
