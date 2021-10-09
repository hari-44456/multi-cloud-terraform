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

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}