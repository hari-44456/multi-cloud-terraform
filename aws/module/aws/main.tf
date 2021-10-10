module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.cidr_block

  azs             = [var.avail_zone]
  public_subnets  = [var.subnet_cidr_block]



  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_default_security_group" "security" {
    
  
   vpc_id =module.vpc.vpc_id
   ingress{
      from_port =22
      to_port = 22
      protocol = "tcp"
      cidr_blocks=[var.my_ip] 
   }
   ingress{
      from_port =8080
      to_port = 8080
      protocol = "tcp"
      cidr_blocks=["0.0.0.0/0"] 
   }
   egress {
      from_port =0
      to_port = 0
      protocol = "-1"
      cidr_blocks=["0.0.0.0/0"]
      prefix_list_ids = [] 
   }
   tags = {
     "Name" = "Security"
   }

}

data "aws_ami" "latest-amazon-linux-image"{
   

   most_recent = true
   owners=["amazon"]
   filter{
      name="name"
      values=[var.image]
   }
   filter {
     name="virtualization-type"
     values=["hvm"]
   }
}
resource "aws_key_pair" "ssh-key" {
   key_name ="server-key"
   public_key = file(var.public_key_location)
}
resource "aws_instance" "server" {
  count = var.instance
  ami=data.aws_ami.latest-amazon-linux-image.id
  instance_type =var.instance_type
  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_default_security_group.security.id]

  availability_zone = "ap-south-1a"
  associate_public_ip_address =true
  key_name =aws_key_pair.ssh-key.key_name
  /*user_data =file("entry-script.sh")*/

  connection {
     type ="ssh"
     host = self.public_ip
     user="ec2-user"
     private_key = file(var.private_key_location)
    
  }
  provisioner "file" {
     source = "/Users/admin/Desktop/veritas/Project /entry-script.sh"
     destination = "/home/ec2-user/entry-script.sh"
    
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/entry-script.sh",
      "/home/ec2-user/entry-script.sh args",
    ]
  }
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user   -i ${self.public_ip}, --private-key ${var.private_key_location} playbook.yml"
  }
  tags={
     Name="${var.env_prefix}-server"
  }  
}