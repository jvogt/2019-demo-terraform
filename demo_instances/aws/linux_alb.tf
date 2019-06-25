#### DEV ####
resource "aws_elb" "linux_dev" {
  name               = "demo-elb-linux-dev-${random_id.instance_id.hex}"
  security_groups    = ["${aws_security_group.demo_instances.id}"]
  subnets            = ["${aws_subnet.demo_instances-subnet-a.id}","${aws_subnet.demo_instances-subnet-b.id}"]
  
  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }

  instances                   = ["${aws_instance.dev.*.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags               = {
    Name               = "demo-instances-dev-${random_id.instance_id.hex}"
    X-Dept             = "${var.tag_dept}"
    X-Customer         = "${var.tag_customer}"
    X-Project          = "${var.tag_project}"
    X-Application      = "${var.tag_application}"
    X-Contact          = "${var.tag_contact}"
    X-TTL              = "${var.tag_ttl}"
  }
}


#### PROD ####
# Create a new load balancer
resource "aws_elb" "linux_prod" {
  name               = "demo-elb-linux-prod-${random_id.instance_id.hex}"
  security_groups    = ["${aws_security_group.demo_instances.id}"]
  subnets            = ["${aws_subnet.demo_instances-subnet-a.id}","${aws_subnet.demo_instances-subnet-b.id}"]
  
  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }

  instances                   = ["${aws_instance.prod.*.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags               = {
    Name               = "demo-instances-prod-${random_id.instance_id.hex}"
    X-Dept             = "${var.tag_dept}"
    X-Customer         = "${var.tag_customer}"
    X-Project          = "${var.tag_project}"
    X-Application      = "${var.tag_application}"
    X-Contact          = "${var.tag_contact}"
    X-TTL              = "${var.tag_ttl}"
  }
}

output "linux_dev_elb_dns_name" {
  value = "http://${aws_elb.linux_dev.dns_name}/national-parks"
}

output "linux_prod_elb_dns_name" {
  value = "http://${aws_elb.linux_prod.dns_name}/national-parks"
}
