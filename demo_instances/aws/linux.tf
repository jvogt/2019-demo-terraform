resource "aws_instance" "dev" {
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
    Name          = "${format("dev_${random_id.instance_id.hex}_${count.index + 1}")}"
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
      "sudo hostnamectl set-hostname dev-app-${count.index + 1}",
    ]
  }

  provisioner "habitat" {
    use_sudo = true
    service_type = "systemd"
    peer = "${aws_instance.permanent_peer.private_ip}"
    
    service {
      name = "jvdemo/chef-linux-hardening-demo"
      channel = "unstable"
      strategy = "at-once"
      group = "dev"
    }
    service {
      name = "jvdemo/national-parks"
      channel = "unstable"
      strategy = "at-once"
      group = "dev"
      binds = ["database:mongodb.dev"]
    }
    # service {
    #   name = "jvdemo/inspec-cis-centos7-demo"
    #   channel = "unstable"
    #   strategy = "at-once"
    # }
  }
}


resource "aws_instance" "devmongo" {
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
    Name          = "${format("devmongo_${random_id.instance_id.hex}")}"
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
      "sudo hostnamectl set-hostname dev-mongo-1",
    ]
  }

  provisioner "habitat" {
    use_sudo = true
    service_type = "systemd"
    peer = "${aws_instance.permanent_peer.private_ip}"
    
    service {
      name = "jvdemo/chef-linux-hardening-demo"
      channel = "unstable"
      strategy = "at-once"
      group = "dev"
    }
    service {
      name = "core/mongodb"
      channel = "stable"
      strategy = "at-once"
      group = "dev"
      user_toml = "${file("${path.module}/../common/templates/mongo.toml")}"
    }
    # service {
    #   name = "jvdemo/inspec-cis-centos7-demo"
    #   channel = "unstable"
    #   strategy = "at-once"
    # }
  }
}

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
      "sudo hostnamectl set-hostname prod-app-${count.index + 1}",
    ]
  }

  provisioner "habitat" {
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
}

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
    Name          = "${format("prodmongo_${random_id.instance_id.hex}")}"
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
      "sudo hostnamectl set-hostname prod-mongo-1",
    ]
  }

  provisioner "habitat" {
    use_sudo = true
    service_type = "systemd"
    peer = "${aws_instance.permanent_peer.private_ip}"
    
    service {
      name = "jvdemo/chef-linux-hardening-demo"
      channel = "unstable"
      strategy = "at-once"
      group = "prod"
    }
    service {
      name = "core/mongodb"
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
}