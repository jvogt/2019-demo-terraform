resource "aws_elb" "chef_server" {
  name               = "chef-server-elb-${random_id.instance_id.hex}"
  security_groups    = ["${aws_security_group.chef_server.id}"]
  subnets            = ["${aws_subnet.chef-server-subnet-a.id}","${aws_subnet.chef-server-subnet-b.id}"]
  
  listener {
    instance_port      = 443
    instance_protocol  = "https"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${data.aws_acm_certificate.chef_server.arn}"
  }
  
  listener {
    instance_port     = 4222
    instance_protocol = "tcp"
    lb_port           = 4222
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTPS:443/login"
    interval            = 5
  }

  instances                   = ["${aws_instance.chef_server.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags               = {
    Name               = "chef-server-${random_id.instance_id.hex}"
    X-Dept             = "${var.tag_dept}"
    X-Customer         = "${var.tag_customer}"
    X-Project          = "${var.tag_project}"
    X-Application      = "${var.tag_application}"
    X-Contact          = "${var.tag_contact}"
    X-TTL              = "${var.tag_ttl}"
  }
}


data "aws_acm_certificate" "chef_server" {
  domain   = "${var.chef_server_alb_acm_matcher}"
  statuses = ["ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "selected" {
  name = "${var.chef_server_alb_r53_matcher}"
}

resource "aws_route53_record" "chef_server" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${var.chef_server_hostname}"
  type    = "CNAME"
  ttl     = "30"
  records = ["${aws_elb.chef_server.dns_name}"]
}

output "chef_server_elb_dns_name" {
  value = "${aws_elb.chef_server.dns_name}"
}

output "chef_server_server_public_r53_dns" {
  value = "https://${var.chef_server_hostname}"
}