resource "aws_security_group" "permanent_peer" {
  name        = "permanent_peer_${random_id.instance_id.hex}"
  description = "Permanent Peer for environment"
  vpc_id      = "${aws_vpc.habichef-vpc.id}"

  tags {
    Name          = "${var.tag_customer}-${var.tag_project}_${random_id.instance_id.hex}_${var.tag_application}_security_group"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

//////////////////////////
// Base Linux Rules
resource "aws_security_group_rule" "permanent_peer_allow_22_tcp_all" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.permanent_peer.id}"
}

/////////////////////////
// Habitat Supervisor Rules
# Allow Habitat Supervisor http communication tcp
resource "aws_security_group_rule" "permanent_peer_allow_9631_tcp" {
  type                     = "ingress"
  from_port                = 9631
  to_port                  = 9631
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.permanent_peer.id}"
  source_security_group_id = "${aws_security_group.permanent_peer.id}"
}

# Allow Habitat Supervisor http communication udp
resource "aws_security_group_rule" "permanent_peer_allow_9631_udp" {
  type                     = "ingress"
  from_port                = 9631
  to_port                  = 9631
  protocol                 = "udp"
  security_group_id        = "${aws_security_group.permanent_peer.id}"
  source_security_group_id = "${aws_security_group.permanent_peer.id}"
}

# Allow Habitat Supervisor ZeroMQ communication tcp
resource "aws_security_group_rule" "permanent_peer_9638_tcp" {
  type                     = "ingress"
  from_port                = 9638
  to_port                  = 9638
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.permanent_peer.id}"
  source_security_group_id = "${aws_security_group.permanent_peer.id}"
}

# Allow Habitat Supervisor ZeroMQ communication udp
resource "aws_security_group_rule" "permanent_peer_allow_9638_udp" {
  type                     = "ingress"
  from_port                = 9638
  to_port                  = 9638
  protocol                 = "udp"
  security_group_id        = "${aws_security_group.permanent_peer.id}"
  source_security_group_id = "${aws_security_group.permanent_peer.id}"
}

# Egress: ALL
resource "aws_security_group_rule" "permanent_peer_allow_0-65535_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.permanent_peer.id}"
}

resource "aws_instance" "permanent_peer" {
  connection {
    user        = "${var.aws_ubuntu_image_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                    = "${var.aws_ami_id == "" ? data.aws_ami.ubuntu.id : var.aws_ami_id}"
  instance_type          = "${var.automate_server_instance_type}"
  key_name               = "${var.aws_key_pair_name}"
  subnet_id              = "${aws_subnet.habichef-subnet-a.id}"
  vpc_security_group_ids = ["${aws_security_group.permanent_peer.id}"]
  ebs_optimized          = true

  root_block_device {
    delete_on_termination = true
    volume_size           = 100
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
      "sudo hostnamectl set-hostname permanentpeer",
    ]
  }

  provisioner "habitat" {
    permanent_peer = true
    use_sudo     = true
    service_type = "systemd"

    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.aws_ubuntu_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }
}

output "permanent_peer_public_ip" {
  value = "${aws_instance.permanent_peer.public_ip}"
}
