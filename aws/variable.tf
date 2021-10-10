variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone{}
variable env_prefix{}
variable my_ip {}
variable instance_type {}

variable image {}


variable "instance" {
     type=number
     description = "Number of instance of VM"
}
variable private_key_aws{
  
}
variable public_key_location {
  
}
variable private_key_location {
  
}