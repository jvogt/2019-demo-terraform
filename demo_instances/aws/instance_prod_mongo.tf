resource "aws_instance" "prodmongo" {
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
    Name          = "prodmongo_${random_id.instance_id.hex}"
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
      "sudo hostnamectl set-hostname prod-mongo-1",
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
    #   group = "prod"
    # }
    service {
      name = "core/mongodb/3.2.10/20171016003652"
      channel = "stable"
      strategy = "at-once"
      group = "prod"
      user_toml = "${file("${path.module}/../common/templates/mongo.toml")}"
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
    policy_group = "prod"
    policy_name = "acme_mongodb"
    node_name = "prod-mongo-1"
  }

  provisioner "file" {
    destination = "/tmp/enable_eas.sh"
    content     = "${data.template_file.enable_automate_eas_linux_prodmongo.rendered}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/enable_eas.sh",
      "sudo bash /tmp/enable_eas.sh",
    ]
  }
}

data "template_file" "enable_automate_eas_linux_prodmongo" {
  template = "${file("${path.module}/../common/templates/enable_eas.sh")}"

  vars {
    automate_hostname = "${var.automate_hostname}"
    automate_api_token = "${var.automate_api_token}"
    app = "mongodb"
    env = "prod"
  }
}
