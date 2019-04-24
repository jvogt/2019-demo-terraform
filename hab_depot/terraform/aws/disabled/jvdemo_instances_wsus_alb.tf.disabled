variable "wsus_server_hostname" {
  default = "wsus-server.chef.jv.run"
  description = ""
}

variable "wsus_server_alb_acm_matcher" {
  default = "*.chef.jv.run"
  description = ""
}

variable "wsus_server_alb_r53_matcher" {
  default = "chef.jv.run."
  description = ""
}

resource "aws_lb" "wsus_server" {
  load_balancer_type = "application"
  name               = "wsus-server-${random_id.instance_id.hex}"
  internal           = "false"
  security_groups    = ["${aws_security_group.windows_demo_instances.id}"]
  subnets            = ["${aws_subnet.habichef-subnet-a.id}","${aws_subnet.habichef-subnet-b.id}"]
  tags               = {
    Name               = "${var.tag_customer}-${var.tag_project}_${random_id.instance_id.hex}_${var.tag_application}_alb"
    X-Dept             = "${var.tag_dept}"
    X-Customer         = "${var.tag_customer}"
    X-Project          = "${var.tag_project}"
    X-Application      = "${var.tag_application}"
    X-Contact          = "${var.tag_contact}"
    X-TTL              = "${var.tag_ttl}"
  }
}

resource "aws_lb_target_group" "wsus_server" {
  name                 = "wsus-server-${random_id.instance_id.hex}"
  vpc_id               = "${aws_vpc.habichef-vpc.id}"
  port                 = "8530"
  protocol             = "HTTP"
  
  depends_on = ["aws_lb.wsus_server"]

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_acm_certificate" "wsus_server" {
  domain   = "${var.wsus_server_alb_acm_matcher}"
  statuses = ["ISSUED"]
  most_recent = true
}

resource "aws_lb_listener" "wsus_server" {
  load_balancer_arn = "${aws_lb.wsus_server.arn}"
  port              = "8530"
  protocol          = "HTTPS"
  certificate_arn   = "${data.aws_acm_certificate.wsus_server.arn}"
  default_action {
    target_group_arn = "${aws_lb_target_group.wsus_server.id}"
    type             = "forward"
  }
}

resource "aws_lb_listener_certificate" "wsus_server" {
  listener_arn    = "${aws_lb_listener.wsus_server.arn}"
  certificate_arn = "${data.aws_acm_certificate.wsus_server.arn}"
}

resource "aws_lb_target_group_attachment" "wsus_server" {
  target_group_arn = "${aws_lb_target_group.wsus_server.arn}"
  target_id        = "${aws_instance.wsus_server.id}"
  port             = 8530
}

data "aws_route53_zone" "wsus_server_zone" {
  name = "${var.wsus_server_alb_r53_matcher}"
}

resource "aws_route53_record" "wsus_server" {
  zone_id = "${data.aws_route53_zone.wsus_server_zone.zone_id}"
  name    = "${var.wsus_server_hostname}"
  type    = "CNAME"
  ttl     = "30"
  records = ["${aws_lb.wsus_server.dns_name}"]
}

output "wsus_server_public_r53_dns" {
  value = "https://${var.wsus_server_hostname}"
}