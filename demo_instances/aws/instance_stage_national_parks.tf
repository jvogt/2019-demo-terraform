resource "aws_instance" "stage" {
  connection {
    user        = "${var.aws_centos_image_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }
  count = 3

  ami                    = "${data.aws_ami.centos.id}"
  instance_type          = "${var.demo_instance_type}"
  key_name               = "${var.aws_key_pair_name}"
  subnet_id              = "${aws_subnet.demo_instances-subnet-a.id}"
  vpc_security_group_ids = ["${aws_security_group.demo_instances.id}"]
  ebs_optimized          = true

  tags {
    Name          = "stage_${random_id.instance_id.hex}_${count.index + 1}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  root_block_device {
    delete_on_termination = true
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname stage-app-${count.index + 1}",
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
    #   group = "stage"
    # }
    service {
      name = "jvdemo/national-parks"
      channel = "unstable"
      strategy = "at-once"
      group = "stage"
      binds = ["database:mongodb.stage"]
    }
    # service {
    #   name = "jvdemo/inspec-cis-centos7-demo"
    #   channel = "unstable"
    #   strategy = "at-once"
    # }
  }

  provisioner "chef" {
    server_url = "https://jv-a2.chef-demo.com/organizations/acme"
    user_key = "${file("/Users/jvogt/.chef/chefuser.pem")}"
    user_name = "chefuser"
    recreate_client = true
    client_options  = ["chef_license 'accept'"]
    use_policyfile = true
    policy_group = "stage"
    policy_name = "acme_app"
    node_name = "stage-app-${count.index + 1}"
  }
  
  provisioner "file" {
    destination = "/tmp/enable_eas.sh"
    content     = "${data.template_file.enable_automate_eas_linux_stage.rendered}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/enable_eas.sh",
      "sudo bash /tmp/enable_eas.sh",
    ]
  }
}

data "template_file" "enable_automate_eas_linux_stage" {
  template = "${file("${path.module}/../common/templates/enable_eas.sh")}"

  vars {
    automate_hostname = "${var.automate_hostname}"
    automate_api_token = "${var.automate_api_token}"
    app = "national-parks"
    env = "stage"
  }
}


output "ssh_public_ip_stage" {
  value = "${element(concat(aws_instance.stage.*.public_ip, list("")), 0)}"
}
