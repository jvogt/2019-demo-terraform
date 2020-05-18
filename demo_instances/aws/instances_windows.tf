data "aws_ami" "win2016" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base-*"]
  }
}

variable "windows_admin_password" {
  default = "Ch3fD3mo^"
  description = ""
}

resource "aws_instance" "windows_node_1" {
  connection  = {
    type     = "winrm"
    user     = "Administrator"
    password = "${var.windows_admin_password}"
    insecure = true
    https    = false
  }
  ami                         = "${data.aws_ami.win2016.id}"
  instance_type               = "m4.xlarge"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.demo_instances-subnet-a.id}"
  vpc_security_group_ids      = ["${aws_security_group.demo_instances.id}"]
  associate_public_ip_address = true
  ebs_optimized               = true
  
  root_block_device {
    volume_size = 80
    delete_on_termination = true
    volume_type           = "gp2"
  }

  tags {
    Name          = "${format("windows_node_1_${random_id.instance_id.hex}")}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "local-exec" {
    command = "sleep 210"
  }

  provisioner "chef" {
    use_policyfile  = "true"
    policy_group    = "stage"
    policy_name     = "acme_app_1"
    node_name       = "acme_app_1_stage"
    server_url      = "https://jv-chef.chef-demo.com/organizations/acme"
    recreate_client = true
    user_name       = "chefuser"
    user_key        = "${file("/Users/jvogt/.chef/chefuser.pem")}"
    client_options  = ["chef_license 'accept'"]
  }

  user_data = <<EOF
<script>
  winrm quickconfig -q & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"}

</script>
<powershell>
  netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
  # Set Administrator password
  $admin = [adsi]("WinNT://./administrator, user")
  $admin.psbase.invoke("SetPassword", "${var.windows_admin_password}")
  $newname = "windows_node_1"
  [Environment]::SetEnvironmentVariable("HAB_UPDATE_STRATEGY_FREQUENCY_MS", "20000", "Machine")
  Rename-Computer -NewName $newname -Force
  Restart-Computer
</powershell>
EOF
}


resource "aws_instance" "windows_node_2" {
  connection  = {
    type     = "winrm"
    user     = "Administrator"
    password = "${var.windows_admin_password}"
    insecure = true
    https    = false
  }

  ami                         = "${data.aws_ami.win2016.id}"
  instance_type               = "m4.xlarge"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.demo_instances-subnet-a.id}"
  vpc_security_group_ids      = ["${aws_security_group.demo_instances.id}"]
  associate_public_ip_address = true
  ebs_optimized               = true
  
  root_block_device {
    volume_size = 80
    delete_on_termination = true
    volume_type           = "gp2"
  }

  tags {
    Name          = "${format("windows_node_2_${random_id.instance_id.hex}")}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "local-exec" {
    command = "sleep 210"
  }

  provisioner "chef" {
    use_policyfile  = "true"
    policy_group    = "prod"
    policy_name     = "acme_app_1"
    node_name       = "acme_app_1_prod"
    server_url      = "https://jv-chef.chef-demo.com/organizations/acme"
    recreate_client = true
    user_name       = "chefuser"
    user_key        = "${file("/Users/jvogt/.chef/chefuser.pem")}"
    client_options  = ["chef_license 'accept'"]
  }

  user_data = <<EOF
<script>
  winrm quickconfig -q & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"}

</script>
<powershell>
  netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
  # Set Administrator password
  $admin = [adsi]("WinNT://./administrator, user")
  $admin.psbase.invoke("SetPassword", "${var.windows_admin_password}")
  $newname = "windows_node_2"
  [Environment]::SetEnvironmentVariable("HAB_UPDATE_STRATEGY_FREQUENCY_MS", "20000", "Machine")
  Rename-Computer -NewName $newname -Force
  Restart-Computer
</powershell>
EOF
}


output "windows_node_1_public_ip" {
  value = "${aws_instance.windows_node_1.public_ip}"
}

output "windows_node_2_public_ip" {
  value = "${aws_instance.windows_node_2.public_ip}"
}
