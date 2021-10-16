variable project {
    description = " Specify projectId which has active billing and compute api activated"
}

variable region {
    description = " Specify region"
}

variable public_key_location {
    description = "Specify location for your public key generated via (ssh-keygen)" 
}

variable private_key_location {
    description = "Specify location for your private key generated via (ssh-keygen)"
}

variable user {
    description = "Specify user's name that will be used for creating VM's"
}

variable prefix {
    description = "The prefix which should be used for all resources"
}
variable admin_username {
  default="rahul"
}
variable admin_password {
  default="Rahul@2410"
}
variable "connection_type" {
  default="winrm"
}