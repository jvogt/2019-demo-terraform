resource "aws_elb" "habitat_depot" {
  name               = "habitat-depot-elb-${random_id.instance_id.hex}"
  security_groups    = ["${aws_security_group.habitat_depot.id}"]
  subnets            = ["${aws_subnet.habitat_depot-subnet-a.id}","${aws_subnet.habitat_depot-subnet-b.id}"]
  
  listener {
    instance_port      = 443
    instance_protocol  = "https"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${data.aws_acm_certificate.habitat_depot.arn}"
  }
  
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTPS:443/"
    interval            = 5
  }

  instances                   = ["${aws_instance.habitat_depot.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags               = {
    Name               = "habitat-depot-${random_id.instance_id.hex}"
    X-Dept             = "${var.tag_dept}"
    X-Customer         = "${var.tag_customer}"
    X-Project          = "${var.tag_project}"
    X-Application      = "${var.tag_application}"
    X-Contact          = "${var.tag_contact}"
    X-TTL              = "${var.tag_ttl}"
  }
}


data "aws_acm_certificate" "habitat_depot" {
  domain   = "${var.habitat_depot_alb_acm_matcher}"
  statuses = ["ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "selected" {
  name = "${var.habitat_depot_alb_r53_matcher}"
}

resource "aws_route53_record" "habitat_depot" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${var.habitat_depot_hostname}"
  type    = "CNAME"
  ttl     = "30"
  records = ["${aws_elb.habitat_depot.dns_name}"]
}

output "habitat_depot_elb_dns_name" {
  value = "${aws_elb.habitat_depot.dns_name}"
}

output "habitat_depot_server_public_r53_dns" {
  value = "https://${var.habitat_depot_hostname}"
}