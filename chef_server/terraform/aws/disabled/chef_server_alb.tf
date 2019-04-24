resource "aws_lb" "chef_server" {
  load_balancer_type = "application"
  name               = "chef-server-${random_id.instance_id.hex}"
  internal           = "false"
  security_groups    = ["${aws_security_group.chef_server.id}"]
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

resource "aws_lb_target_group" "chef_server" {
  name                 = "chef-server-${random_id.instance_id.hex}"
  vpc_id               = "${aws_vpc.habichef-vpc.id}"
  port                 = "443"
  protocol             = "HTTPS"
  
  depends_on = ["aws_lb.chef_server"]

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_acm_certificate" "chef_server" {
  domain   = "${var.chef_server_alb_acm_matcher}"
  statuses = ["ISSUED"]
  most_recent = true
}

resource "aws_lb_listener" "chef_server" {
  load_balancer_arn = "${aws_lb.chef_server.arn}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${data.aws_acm_certificate.chef_server.arn}"
  default_action {
    target_group_arn = "${aws_lb_target_group.chef_server.id}"
    type             = "forward"
  }
}

resource "aws_lb_listener_certificate" "chef_server" {
  listener_arn    = "${aws_lb_listener.chef_server.arn}"
  certificate_arn = "${data.aws_acm_certificate.chef_server.arn}"
}

resource "aws_lb_target_group_attachment" "chef_server" {
  target_group_arn = "${aws_lb_target_group.chef_server.arn}"
  target_id        = "${aws_instance.chef_server.id}"
  port             = 443
}

data "aws_route53_zone" "chef_server_zone" {
  name = "${var.chef_server_alb_r53_matcher}"
}

resource "aws_route53_record" "chef_server" {
  zone_id = "${data.aws_route53_zone.chef_server_zone.zone_id}"
  name    = "${var.chef_server_hostname}"
  type    = "CNAME"
  ttl     = "30"
  records = ["${aws_lb.chef_server.dns_name}"]
}

output "chef_server_public_r53_dns" {
  value = "https://${var.chef_server_hostname}"
}