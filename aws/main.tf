module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr_block

  azs             = [var.avail_zone]
  public_subnets  = [var.subnet_cidr_block]

  public_subnet_tags = {
      Name = "${var.prefix}-subnet-1"
  }

  tags = {
      Name = "${var.prefix}-vpc"
  }
}

resource aws_security_group "myapp-sg" {
    vpc_id =  module.vpc.vpc_id
    name = "${var.prefix}-sg"

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name = "${var.prefix}-default-sg"
    }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners= ["amazon"]
  filter {
      name = "name"
      values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
      name = "virtualization-type"
      values = ["hvm"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.prefix}-key"
  public_key = file(var.public_key_location)
}

variable admin_username {
  default="narahari"
}

variable admin_password {
  default="N@rahari12345!"
}

resource "aws_instance" "web" {

  ami           = "ami-0428fc1ee1bde045a"
  instance_type = "t2.micro"

  key_name = aws_key_pair.deployer.key_name

  subnet_id = module.vpc.public_subnets[0]
  availability_zone = var.avail_zone
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  associate_public_ip_address = true

   user_data     = <<EOF
    <powershell>
    net user ${var.admin_username} '${var.admin_password}' /add /y
    net localgroup administrators ${var.admin_username} /add
    winrm quickconfig -q
    winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="300"}'
    winrm set winrm/config '@{MaxTimeoutms="1800000"}'
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
    winrm set winrm/config/service/auth '@{Basic="true"}'
    netsh advfirewall firewall add rule name="WinRM 5985" protocol=TCP dir=in localport=5985 action=allow
    netsh advfirewall firewall add rule name="WinRM 5986" protocol=TCP dir=in localport=5986 action=allow
    net stop winrm
    sc.exe config winrm start=auto
    net start winrm
    </powershell>
    EOF

  connection {
    host = coalesce(self.public_ip, self.private_ip)
    type = "winrm"
    timeout = "10m"
    user = var.admin_username
    password = var.admin_password
  }

  provisioner "file" {
    source = "abc.txt"
    destination = "C:/test.txt"
  }

  provisioner "remote-exec" {
      inline = [
        "mkdir helloworld",
      ]
    }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.admin_username}   -i ${self.public_ip}, --private-key ${var.private_key_location} playbook.yml"
  }

  tags = {
    Name = "${var.prefix}-Terraform"
  }
}