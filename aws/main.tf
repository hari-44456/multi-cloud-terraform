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
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
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

resource "aws_instance" "web" {
  ami           = "ami-0c1a7f89451184c8b"
  instance_type = "t2.micro"
  key_name = aws_key_pair.deployer.key_name

  subnet_id = module.vpc.public_subnets[0]
  availability_zone = var.avail_zone
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  associate_public_ip_address = true

  provisioner "remote-exec" {
  
    inline = [
     "mkdir newDir",
     "rmdir newDir"
    ]
    
    connection {
      type = "ssh"
      host = self.public_ip
      user = "ubuntu"
      private_key = file(var.private_key_location)
    }
  }

 /* provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user   -i ${self.public_ip}, --private-key ${var.private_key_location} playbook.yml"
  }*/

  tags = {
    Name = "${var.prefix}-Terraform"
  }
}
/*resource  "aws_ami_from_instance" "ubuntu-ami" {
    name               = "${var.prefix}-ami"
    source_instance_id = "${aws_instance.web.id}"

  depends_on = [
      aws_instance.web,
      ]

  tags = {
      Name = "${var.prefix}-ami"
  }

}*/