
resource "aws_instance" "devhaproxy" {
  connection {
    user        = "${var.aws_centos_image_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                    = "${data.aws_ami.centos.id}"
  instance_type          = "${var.demo_instance_type}"
  key_name               = "${var.aws_key_pair_name}"
  subnet_id              = "${aws_subnet.demo_instances-subnet-a.id}"
  vpc_security_group_ids = ["${aws_security_group.demo_instances.id}"]
  ebs_optimized          = true

  tags {
    Name          = "devhaproxy_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = 20
    volume_type           = "gp2"
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname dev-haproxy-1",
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
    
    # service {
    #   name = "jvdemo/chef-linux-hardening-demo"
    #   channel = "unstable"
    #   strategy = "at-once"
    #   group = "dev"
    # }
    service {
      name = "core/haproxy"
      channel = "stable"
      strategy = "at-once"
      group = "dev"
      binds = ["backend:national-parks.dev"]
      user_toml = "${file("${path.module}/../common/templates/haproxy.toml")}"
    }
    # service {
    #   name = "jvdemo/inspec-cis-centos7-demo"
    #   channel = "unstable"
    #   strategy = "at-once"
    # }
  }

  provisioner "file" {
    destination = "/tmp/enable_eas.sh"
    content     = "${data.template_file.enable_automate_eas_linux_devhaproxy.rendered}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/enable_eas.sh",
      "sudo bash /tmp/enable_eas.sh",
    ]
  }
}

data "template_file" "enable_automate_eas_linux_devhaproxy" {
  template = "${file("${path.module}/../common/templates/enable_eas.sh")}"

  vars {
    automate_hostname = "${var.automate_hostname}"
    automate_api_token = "${var.automate_api_token}"
    app = "haproxy"
    env = "dev"
  }
}

output "haproxy_dev" {
  value = "http://${element(concat(aws_instance.devhaproxy.*.public_ip, list("")), 0)}"
}
