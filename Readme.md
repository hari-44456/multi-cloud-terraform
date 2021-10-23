# Multi Cloud Infrastructure Automation Using Terraform and Ansible


## Required Installed Softwares
- [Terraform](https://www.terraform.io/downloads.html)
- [Ansible >= 2.9](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Python 3.x](https://www.python.org/downloads/)


## Configurations
For Windows image creation you should have pywinrm installed
```
pip install pywinrm
```

For Creating Azure service account run following command
```
az ad sp create-for-rbac -n <NameForServiceAccount>  --role="Contributor" --scopes="/subscriptions/<Your Subscription Id>"
```

## Provide all input variables in **input.json** 
### Sample input.json file

```
# input.json
{
	"aws_linux": {
		"access_key": <YOUR ACCESS KEY>,
		"secret_key": <YOUR SECRET KEY>,
        ...
	},
	"aws_windows": {
		"access_key": <YOUR ACCESS KEY>,
        ...
	},
	"azure_linux": {
        "client_id": <YOUR CLIENT ID/ APP ID>,
		"client_secret": <YOUR CLIENT SECRET / PASSWORD>,
        ...
	},
	"azure_windows": {
        "client_id": <YOUR CLIENT ID/ APP ID>,
		"client_secret": <YOUR CLIENT SECRET / PASSWORD>,
        ...
	},
	"gcp_linux": {
		"project": <YOUR PROJECT ID>,
        ...
	}
}
```


##  Run Application
```
python3 start.py
```

>Note:  This application installs mongodb on linux VM images and installs "Notepad++ , Python3, OpenSSH, Google Chrome" on windows VM images.

-----
----


# Variable references

## Variables to be used in aws_linux's image configuration
### Required variables
```
1. access_key {
    description = "Your aws IAM user's ACCESS_KEY"
}

2. secret_key {
    description = "Your aws IAM user's SECRET_ACCESS_KEY"
}
```
### Optional Variables (If you do not provide values for following variables then default values will be used)
```
1. public_key_location {
    description = "Location for your ssh public key"
    default = "~/.ssh/id_rsa.pub"
}

2. private_key_location {
    description = "Location for your ssh private key "
    default = "~/.ssh/id_rsa"
}

3. prefix {
    description = "The prefix which should be used for all resources"
    default = "automation"
}

4. vpc_cidr_block {
    description = "Cidr block for VPC"
    default = "10.0.0.0/16"
}

5. subnet_cidr_block {
    description = "Cidr block for subnet"
    default = "10.0.10.0/24"
}

6. avail_zone {
    description = "Specify Availability zone"
    default = "us-east-2a"
}

7. region {
    description = "Specify region"
    default = "us-east-2"
}

8. ami_id {
    description = "Specify ami_id of base image(Currently only Debian family os are supported)"
    default = "ami-074cce78125f09d61"
}

9. user {
    description = "Specify default user associated with given ami_id"
    default = "ec2-user"
}

10. instance_type {
    description = "Specify instance type"
    default = "t2.micro"
}
```

## Variables to be used in aws_windows's image configuration
### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  Required variables
```
1. access_key {
    description = "Your aws IAM user's ACCESS_KEY"
}

2. secret_key {
    description = "Your aws IAM user's SECRET_ACCESS_KEY"
}
```
### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Optional Variables (If you do not provide values for following variables then default values will be used)
```
1. public_key_location {
    description = "Location for your ssh public key"
    default = "~/.ssh/id_rsa.pub"
}

2. private_key_location {
    description = "Location for your ssh private key "
    default = "~/.ssh/id_rsa"
}

3. prefix {
    description = "The prefix which should be used for all resources"
    default = "automation"
}

4. vpc_cidr_block {
    description = "Cidr block for VPC"
    default = "10.0.0.0/16"
}

5. subnet_cidr_block {
    description = "Cidr block for subnet"
    default = "10.0.10.0/24"
}

6. avail_zone {
    description = "Specify Availability zone"
    default = "us-east-2a"
}

7. region {
    description = "Specify region"
    default = "us-east-2"
}

8. ami_id {
    description = "Specify ami_id of base image"
    default = "ami-0428fc1ee1bde045a"
}

9. user {
    description = "Specify default user associated with given ami_id"
    default = "automation"
}

10. instance_type {
    description = "Specify instance type"
    default = "t2.micro"
}

11. password {
    description = "Provide password for user(Password length should be >=8 and <= 15 , should contain at least one uppercase,one lowercase,one digit and one special character)"
    default="N@rahari12345!"
}
```


## Variables to be used in azure_linux's image configuration
### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Required variables
```
1. subscription_id {
     description = "Your subscription id"
}

2. tenant_id {
    description = "Your Tenant id"
}

3. client_id {
    description = "Yoour client id/appid"
}

4. client_secret {
    description = "Your client secret/password"
}
```
### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Optional Variables (If you do not provide values for following variables then default values will be used)

```
1. public_key_location {
    description = "Location for your ssh public key"
    default = "~/.ssh/id_rsa.pub"
}

2. private_key_location {
    description = "Location for your ssh private key "
    default = "~/.ssh/id_rsa"
}

3. prefix {
    description = "The prefix which should be used for all resources"
    default = "automation"
}

4.  user {
    description = "Specify user's name that will be used for creating VM's"
    default = "automation"
}

5. location {
  description = "The Azure Region in which all resources in this example should be created."
  default = "westeurope"
}

6. vpc_cidr_block {
    description = "specify VPC cidr block"
    default = "10.0.0.0/16"
}

7. subnet_cidr_block {
    description = "specify subnet cidr block"
    default = "10.0.0.0/24"
}

8. size {
    description = "Specify size of vm"
    default = "Standard_F2"
}

9. publisher {
     description = "specify source image reference publisher" 
     default = "Canonical" 
}

10. offer {  
    description = "specify source image reference offer(Currently only Debian family os are supported)"
    default     = "UbuntuServer" 
}

11. sku {  
    description = "specify source image reference sku" 
    default       = "16.04-LTS" 
}

12. image_version { 
    description = "specify source image reference version"
    default   = "latest" 
}
```

## Variables to be used in azure_windows's image configuration
### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Required variables

```
1. subscription_id {
     description = "Your subscription id"
}

2. tenant_id {
    description = "Your Tenant id"
}

3. client_id {
    description = "Yoour client id/appid"
}

4. client_secret {
    description = "Your client secret/password"
}
```
### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Optional Variables (If you do not provide values for following variables then default values will be used)

```
1. public_key_location {
    description = "Location for your ssh public key"
    default = "~/.ssh/id_rsa.pub"
}

2. private_key_location {
    description = "Location for your ssh private key "
    default = "~/.ssh/id_rsa"
}

3. prefix {
    description = "The prefix which should be used for all resources"
    default = "automation"
}

4.  user {
    description = "Specify user's name that will be used for creating VM's"
    default = "narahari"
}

5. password {
    description = " Specify password(Password length should be >=8 and <= 15 .It should contain one uppercase,one lowercase,one digit and one special character)"
    default = "N@rahari12345!"
}

6. prefix {
    description = "The prefix which should be used for all resources"
    default = "automation"
}

7. location {
  description = "The Azure Region in which all resources in this example should be created."
  default = "westeurope"
}

8. vpc_cidr_block {
    description = "specify VPC cidr block"
    default = "10.0.0.0/16"
}

9. subnet_cidr_block {
    description = "specify subnet cidr block"
    default = "10.0.0.0/24"
}

10. publisher {
     description = "specify source image reference publisher" 
     default = "MicrosoftWindowsServer" 
}

11. offer {  
    description = "specify source image reference offer"
    default     = "WindowsServer" 
}

12. sku {  
    description = "specify source image reference sku" 
    default       = "2019-Datacenter" 
}

13. image_version { 
    description = "specify source image reference version"
    default   = "latest" 
}

14. vm_size {
    description = "Specify vm size"
    default = "Standard_DS1_v2"
}
```

## Variables to be used in gcp_linux's image configuration
### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Required variables

```
1. project {
    description = " Specify projectId which has active billing and compute api activated"
}

2. service_account_credentials_file_location  {
    description = "Specify path to service account credentials file"
}

```
### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Optional Variables (If you do not provide values for following variables then default values will be used)

```

1. region {
    description = " Specify region"
    default = "asia-south1"
}

2. zone {
    description = " Specify zone"
    default = "asia-south1-a"
}

3. public_key_location {
    description = "Location for your ssh public key"
    default = "~/.ssh/id_rsa.pub"
}

4. private_key_location {
    description = "Location for your ssh private key "
    default = "~/.ssh/id_rsa"
}

5. user {
    description = "Specify user's name that will be used for creating VM's"
    default = "automation"
}

6. prefix {
    description = "The prefix which should be used for all resources"
    default = "automation"
}

7. machine_type {
    description = "Specify machine type"
    default = "f1-micro"
}

8. boot_image {
    description = "Specify boot image to be used(Currently only Debian family os are supported)"
    default = "ubuntu-os-cloud/ubuntu-1804-lts"
}

```