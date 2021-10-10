module aws {
   source = "./module/aws"
   image=var.image
   instance_type=var.instance_type
   env_prefix=var.env_prefix
   avail_zone =var.avail_zone
   my_ip =var.my_ip
   cidr_block =var.vpc_cidr_block
   subnet_cidr_block = var.subnet_cidr_block
   instance=var.instance
   private_key_aws=var.private_key_aws
   public_key_location =var.public_key_location
   private_key_location = var.private_key_location
}




