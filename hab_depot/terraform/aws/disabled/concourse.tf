resource "aws_security_group" "concourse_db_sg" {
  name        = "concourse-db-allow-all"
  description = "allow all inbound traffic"
  vpc_id      = "${aws_vpc.habichef-vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9631
    to_port     = 9631
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9638
    to_port     = 9638
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9638
    to_port     = 9638
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name          = "concourse_db_security_group_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

resource "aws_security_group" "concourse_web_worker_sg" {
  name        = "concourse-web-allow-all_${random_id.instance_id.hex}"
  description = "allow all inbound traffic"
  vpc_id      = "${aws_vpc.habichef-vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9631
    to_port     = 9631
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9638
    to_port     = 9638
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9638
    to_port     = 9638
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2222
    to_port     = 2222
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name          = "concourse_web_worker_security_group_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

resource "aws_security_group" "concourse_elb_sg" {
  vpc_id      = "${aws_vpc.habichef-vpc.id}"
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name          = "concourse_elb_security_group"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

resource "aws_elb" "concourse_elb" {
  name               = "concourse-elb-${random_id.instance_id.hex}"
  subnets            = ["${aws_subnet.habichef-subnet-a.id}"]
  instances = ["${aws_instance.concourse_web.*.id}"]
  security_groups     = ["${aws_security_group.concourse_elb_sg.id}"]

  listener {
    instance_port      = 8080
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    target              = "HTTP:8080/"
    interval            = 30
  }

  tags {
    Name          = "concourse-elb-${var.tag_customer}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

resource "aws_instance" "concourse_db" {
  ami           = "${var.aws_ami_id == "" ? data.aws_ami.ubuntu16.id : var.aws_ami_id}"
  instance_type = "${var.concourse_db_node_size}"
  key_name      = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.habichef-subnet-a.id}"
  vpc_security_group_ids      = ["${aws_security_group.concourse_db_sg.id}"]
  associate_public_ip_address = true

  tags {
    Name = "concourse_db_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "habitat" {
    use_sudo = true
    service_type = "systemd"

    service {
      name = "core/postgresql"
      user_toml = "${file("${path.module}/templates/concourse/concourse-postgres.toml")}"
    }

    connection {
      host       = "${self.public_ip}"
      type       = "ssh"
      user       = "ubuntu"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }
}

resource "aws_instance" "concourse_worker" {
  count         = "${var.concourse_worker_count}"
  ami           = "${var.aws_ami_id == "" ? data.aws_ami.ubuntu16.id : var.aws_ami_id}"
  instance_type = "${var.concourse_worker_node_size}"
  key_name      = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.habichef-subnet-a.id}"
  vpc_security_group_ids      = ["${aws_security_group.concourse_web_worker_sg.id}"]
  associate_public_ip_address = true

  tags {
    Name = "concourse_worker_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "habitat" {
    use_sudo = true
    service_type = "systemd"
    peer = "${aws_instance.concourse_web.private_ip}"
    permanent_peer = true

    service {
      name = "habitat/concourse-worker"
      binds = ["web:concourse-web.default"]
    }

    connection {
      host       = "${self.public_ip}"
      type       = "ssh"
      user       = "${var.aws_ubuntu_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }
}

resource "aws_instance" "concourse_web" {
  ami           = "${var.aws_ami_id == "" ? data.aws_ami.ubuntu16.id : var.aws_ami_id}"
  instance_type = "${var.concourse_web_node_size}"
  key_name      = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.habichef-subnet-a.id}"
  vpc_security_group_ids      = ["${aws_security_group.concourse_web_worker_sg.id}"]
  associate_public_ip_address = true

  tags {
    Name = "concourse_web_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "habitat" {
    use_sudo = true
    service_type = "systemd"
    peer = "${aws_instance.concourse_db.public_ip}"
    permanent_peer = true

    service {
      name = "habitat/concourse-web"
      binds = ["database:postgresql.default"]
      user_toml = "${data.template_file.concourse_web_toml.rendered}"
    }

    connection {
      host       = "${self.public_ip}"
      type       = "ssh"
      user       = "${var.aws_ubuntu_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p keys/web keys/worker",
      "ssh-keygen -t rsa -f ./keys/web/tsa_host_key -N ''",
      "ssh-keygen -t rsa -f ./keys/web/session_signing_key -N ''",
      "ssh-keygen -t rsa -f ./keys/worker/worker_key -N ''",
      "cp ./keys/worker/worker_key.pub ./keys/web/authorized_worker_keys",
      "cp ./keys/web/tsa_host_key.pub ./keys/worker",
      "sudo hab file upload concourse-web.default $(date +%s) ~/keys/web/authorized_worker_keys",
      "sudo hab file upload concourse-web.default $(date +%s) ~/keys/web/session_signing_key",
      "sudo hab file upload concourse-web.default $(date +%s) ~/keys/web/session_signing_key.pub",
      "sudo hab file upload concourse-web.default $(date +%s) ~/keys/web/tsa_host_key",
      "sudo hab file upload concourse-web.default $(date +%s) ~/keys/web/tsa_host_key.pub",
      "sudo hab file upload concourse-worker.default $(date +%s) ~/keys/worker/worker_key.pub",
      "sudo hab file upload concourse-worker.default $(date +%s) ~/keys/worker/worker_key",
      "sudo hab file upload concourse-worker.default $(date +%s) ~/keys/worker/tsa_host_key.pub",
      "sudo hab stop habitat/concourse-web",
      "sudo hab start habitat/concourse-web"
    ]

    connection {
      host       = "${self.public_ip}"
      type       = "ssh"
      user       = "${var.aws_ubuntu_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }
}

data "template_file" "concourse_web_toml" {
  template = "${file("${path.module}/templates/concourse/concourse-web.toml")}"
  vars {
    db_ip = "${aws_instance.concourse_db.public_ip}"
    concourse_user_name = "${var.concourse_user_name}"
    concourse_user_password = "${var.concourse_user_password}"
  }
}


output "concourse_web_ip" {
  value = "${aws_instance.concourse_web.public_ip}"
}

output "concourse_db_ip" {
  value = "${aws_instance.concourse_db.public_ip}"
}

output "concourse_worker_ips" {
  value = "${aws_instance.concourse_worker.*.public_ip}"
}

output "concourse_elb_dns" {
  value = "${aws_elb.concourse_elb.dns_name}"
}