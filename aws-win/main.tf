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

resource "aws_network_acl" "allowall" {
    vpc_id = module.vpc.vpc_id

    #Allow All Out
    egress {
        protocol = "-1"
        rule_no = 100
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0    
    }
    #Allow All In
    ingress {
        protocol = "-1"
        rule_no = 200
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
}
resource aws_security_group "myapp-sg" {
    vpc_id =  module.vpc.vpc_id
    name = "${var.prefix}-sg"

ingress {
        from_port = 3389
        to_port = 3389
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 1880
        to_port = 1880
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 18800
        to_port = 18800
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

        ingress {
        from_port = 5985
        to_port = 5986
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_instance" "web" {

  ami           = "ami-09a62bf22e41143a4"
  instance_type = "t2.micro"
  get_password_data = true
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
   
    winrm set winrm/config/service '@{AllowUnencrypted = "true"}'
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord 
    
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
    Start-Service sshd
    Set-Service -Name sshd -StartupType 'Automatic'

    Write-Host "Config custom"
    $url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
    $file = "$env:temp\ConfigureRemotingForAnsible.ps1"
    (New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
    powershell.exe -ExecutionPolicy ByPass -File $file
    </powershell>
    EOF

   provisioner "remote-exec" {
    connection {
      host     = coalesce(self.public_ip, self.private_ip)
      type     = "winrm"
      port     = 5985
      https    = false
      timeout  = "5m"
      //user     = "Administrator"
      //password = rsadecrypt(self.password_data, file("~/.ssh/id_rsa"))
       user     = "${var.admin_username}"
      password = "${var.admin_password}"
    }
    inline = [
     
      "mkdir helloworld",

  
    ]
  }
  
  provisioner "local-exec" {
    command = "echo ansible_host_1 ansible_host=${self.public_ip} ansible_user=${var.admin_username} ansible_password=${var.admin_password} ansible_connection=${var.connection_type} ansible_winrm_server_cert_validation=ignore ansible_port=5985 > hosts"
  }
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts  ../ansible/windows_playbook.yml"
  }
  provisioner "local-exec" {
    command = "rm -rf hosts"
  }

  tags = {
    Name = "${var.prefix}-Terraform"
  }
}

resource  "aws_ami_from_instance" "window-ami" {
    name               = "${var.prefix}-ami"
    source_instance_id = "${aws_instance.web.id}"

  depends_on = [
      aws_instance.web,
      ]

  tags = {
      Name = "${var.prefix}-ami"
  }

}