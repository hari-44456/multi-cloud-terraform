variable "access_key" {
    description = "Specify aws ACCESS_KEY"
}

variable "secret_key" {
    description = "Specify aws SECRET_ACCESS_KEY"
}

variable public_key_location {
    description = "Specify location for your public key generated via (ssh-keygen)"
    default = "~/.ssh/id_rsa.pub"
}

variable private_key_location {
    description = "Specify location for your private key generated via (ssh-keygen)"
    default = "~/.ssh/id_rsa"
}

variable user {
  description = "Specify default user"
  default="narahari"
}

variable password {
  description = "Provide password for user"
  default="N@rahari12345!"
}

variable prefix {
    description = "The prefix which should be used for all resources"
    default = "automation"
}

variable connection_type {
    description = "This describes the connection type"
    default = "winrm"
}

variable vpc_cidr_block {
    description = "Specify vpc cidr block"
    default = "10.0.0.0/16"
}

variable subnet_cidr_block {
    description = "Specify subnet cidr block"
    default = "10.0.10.0/24"
}

variable avail_zone {
    description = "Specify availability zone"
    default = "us-east-2a"
}

variable "region" {
    description = " Specify region"
    default = "us-east-2"
}

variable "ami_id" {
    description = "Provide windows ami id"
    default = "ami-0428fc1ee1bde045a"
}