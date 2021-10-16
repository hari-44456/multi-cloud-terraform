variable public_key_location {
    description = "Specify location for your public key generated via (ssh-keygen)"
}

variable private_key_location {
    description = "Specify location for your private key generated via (ssh-keygen)"
}

variable admin_username {
  default="narahari"
}
s
variable admin_password {
  default="N@rahari12345!"
}

variable prefix {
    description = "The prefix which should be used for all resources"
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
}