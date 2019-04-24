resource "aws_elb" "concourse_elb" {
  name               = "concourse-${random_id.instance_id.hex}"
  subnets            = ["${aws_subnet.concourse-subnet-a.id}"]
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
    Name          = "concourse_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

resource "aws_instance" "concourse_db" {
  ami           = "${data.aws_ami.ubuntu16.id}"
  instance_type = "${var.concourse_db_node_size}"
  key_name      = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.concourse-subnet-a.id}"
  vpc_security_group_ids      = ["${aws_security_group.concourse_db_sg.id}"]
  associate_public_ip_address = true

  root_block_device {
    delete_on_termination = true
  }

  connection {
    user       = "${var.aws_ubuntu_image_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

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
      user_toml = "${file("${path.module}/../common/templates/concourse-postgres.toml")}"
    }
  }
}

resource "aws_instance" "concourse_worker" {
  count         = "${var.concourse_worker_count}"
  ami           = "${data.aws_ami.ubuntu16.id}"
  instance_type = "${var.concourse_worker_node_size}"
  key_name      = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.concourse-subnet-a.id}"
  vpc_security_group_ids      = ["${aws_security_group.concourse_web_worker_sg.id}"]
  associate_public_ip_address = true

  root_block_device {
    delete_on_termination = true
  }

  connection {
    user       = "${var.aws_ubuntu_image_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  tags {
    Name = "concourse_worker_${count.index + 1}_${random_id.instance_id.hex}"
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

  }
}

resource "aws_instance" "concourse_web" {
  ami           = "${data.aws_ami.ubuntu16.id}"
  instance_type = "${var.concourse_web_node_size}"
  key_name      = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.concourse-subnet-a.id}"
  vpc_security_group_ids      = ["${aws_security_group.concourse_web_worker_sg.id}"]
  associate_public_ip_address = true

  depends_on = ["aws_instance.concourse_worker.0","aws_instance.concourse_worker.1","aws_instance.concourse_worker.2"]

  root_block_device {
    delete_on_termination = true
  }

  connection {
    user       = "${var.aws_ubuntu_image_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

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
    service {
      name = "jvogt/hab-svc-ring-viz"
      channel = "stable"
      strategy = "at-once"
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
  }
}

provisioner "local-exec" {
  inline = [
    "fly --target demo login --concourse-url http://${aws_elb.concourse_elb.dns_name} -u ${var.concourse_user_name} -p ${var.concourse_password}",
    "fly --target demo sync",
    "fly -t demo set-pipeline -p chef-code -c ../chef-pipeline.yml"
    "fly -t demo set-pipeline -p app-code -c ../app-pipeline.yml"
    "fly -t demo set-pipeline -p packer-code -c ../packer-pipeline.yml"
  ]
}

data "template_file" "concourse_web_toml" {
  template = "${file("${path.module}/../common/templates/concourse-web.toml")}"
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