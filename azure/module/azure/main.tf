resource "azurerm_resource_group" "myterraformgroup" {
    count = var.instance
    name     = var.groupname
    location = "eastus"

    tags = {
        environment = "Terraform Demo"
    }
    
}

resource "azurerm_virtual_network" "myterraformnetwork" {
    count = var.instance
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.myterraformgroup[0].name

    tags = {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    count = var.instance
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.myterraformgroup[0].name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork[0].name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
   count = var.instance
    name                         = "myPublicIP"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.myterraformgroup[0].name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    count = var.instance
    name                = "myNetworkSecurityGroup"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.myterraformgroup[0].name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    count = var.instance
    name                      = "myNIC"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.myterraformgroup[0].name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet[0].id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip[0].id
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    count = var.instance
    network_interface_id      = azurerm_network_interface.myterraformnic[0].id
    network_security_group_id = azurerm_network_security_group.myterraformnsg[0].id
}


# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    count = var.instance
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.myterraformgroup[0].name
    }

    byte_length = 8
}
resource "azurerm_storage_account" "mystorageaccount" {
    count = var.instance
    name                        = "diag${random_id.randomId[0].hex}"
    resource_group_name         = azurerm_resource_group.myterraformgroup[0].name
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform Demo"
    }
}


resource "tls_private_key" "example_ssh" {
  count = var.instance
  algorithm = "RSA"
  rsa_bits = 4096
}


# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
    count = var.instance
    name                  = "PanVM"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.myterraformgroup[0].name
    network_interface_ids = [azurerm_network_interface.myterraformnic[0].id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "myvm"
    admin_username = var.username
    disable_password_authentication = true

    admin_ssh_key {
        username       = var.username
        public_key     = file("~/.ssh/id_rsa.pub")
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount[0].primary_blob_endpoint
    }
   // custom_data = base64encode(file("/Users/admin/Desktop/veritas/Azure/module/entry-script.sh"))
    
     connection {
      type     ="ssh"    
      host     = self.public_ip_address
      user     = self.admin_username
      private_key = file("~/.ssh/id_rsa")
    }
  provisioner "file" {
     source = "/Users/admin/Desktop/veritas/Project /entry-script.sh"
     destination = "/home/${self.admin_username}/entry-script.sh"

     
    
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.username}/entry-script.sh",
      "/home/${var.username}/entry-script.sh args",
    ]
  }
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u '${self.admin_username}' -i ${self.public_ip_address}, --private-key ${var.private_key_azure} playbook.yml"
  }
    tags = {
        environment = "Terraform Demo"
    }
}