import json
import os

def validateVariables(required_variables,variables_list):
    for key,value in variables_list:
        if(key in required_variables):
            required_variables.remove(key)
    
    if(len(required_variables)):
        return False
    return True

def generateApplyCommand(pairs):
    str = "terraform apply --auto-approve "
    for key,value in pairs:
        str += "-var "+key+"=\""+value+"\" "
    return str;


aws_linux_required_variables = {  "access_key", "secret_key" }
aws_windows_required_variables = {  "access_key", "secret_key" }

azure_linux_required_variables = {"subscription_id","tenant_id","client_id","client_secret" }
azure_windows_required_variables = {"subscription_id","tenant_id","client_id","client_secret"}

gcp_linux_required_variables = {"project","service_account_credentials_file_location"}


data = json.loads(open("input.json").read())

aws_linux_variables = data["aws_linux"].items()
aws_windows_variables = data["aws_windows"].items()

azure_linux_variables = data["azure_linux"].items()
azure_windows_variables = data["azure_windows"].items()

gcp_linux_variables = data["gcp_linux"].items()

if(validateVariables(aws_linux_required_variables,aws_linux_variables)):
    print(generateApplyCommand(aws_linux_variables))
    os.chdir("aws")
    os.system("terraform init")
    os.system(generateApplyCommand(aws_linux_variables))
    os.chdir("..")
else:
    print("skipping \"aws-linux\" vm creation because you have not provided all required variables in input.json")

if(validateVariables(aws_windows_required_variables,aws_windows_variables)):
    print(generateApplyCommand(aws_windows_variables))
    os.chdir("aws-win")
    os.system("terraform init")
    os.system(generateApplyCommand(aws_windows_variables))
    os.chdir("..")
else:
    print("skipping \"aws-windows\" vm creation because you have not provided all required variables in input.json")

if(validateVariables(azure_linux_required_variables,azure_linux_variables)):
    print(generateApplyCommand(azure_linux_variables))
    os.chdir("azure")
    os.system("terraform init")
    os.system(generateApplyCommand(azure_linux_variables))
    os.chdir("..")
else:
    print("skipping \"azure-linux\" vm creation because you have not provided all required variables in input.json")


if(validateVariables(azure_windows_required_variables,azure_windows_variables)):
    print(generateApplyCommand(azure_windows_variables))
    os.chdir("azure-win")
    os.system("terraform init")
    os.system(generateApplyCommand(azure_windows_variables))
    os.chdir("..")
else:
    print("skipping \"azure-windows\" vm creation because you have not provided all required variables in input.json")


if(validateVariables(gcp_linux_required_variables,gcp_linux_variables)):
    print(generateApplyCommand(gcp_linux_variables))
    os.chdir("gcp")
    os.system("terraform init")
    os.system(generateApplyCommand(gcp_linux_variables))
    os.chdir("..")
else:
    print("skipping \"gcp-linux\" vm creation because you have not provided all required variables in input.json")
