variable public_key_location {
    description = "Specify location for your public key generated via (ssh-keygen)"
    default = "~/.ssh/id_rsa.pub"
}

variable private_key_location {
    description = "Specify location for your private key generated via (ssh-keygen)"
    default = "~/.ssh/id_rsa"
}

variable user {
    description = "Specify user's name that will be used for creating VM's"
    default = "ec2-user"
}

variable prefix {
    description = "The prefix which should be used for all resources"
    default = "prathamesh"
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
    default = "ap-south-1a"
}