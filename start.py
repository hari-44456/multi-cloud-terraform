import json
import os

def validateVariables(required_variables,variables_list):
    if variables_list is not None:
        for key,value in variables_list:
            if(key in required_variables):
                required_variables.remove(key)
        
        if(len(required_variables)):
            return False
        return True
    return False

def generateApplyCommand(pairs,st="apply"):
    str = "terraform " + st +" --auto-approve "
    for key,value in pairs:
        str += "-var "+key+"=\""+value+"\" "
    return str;

def destroyResources(dir,variables):
    os.chdir(dir)
    os.system(generateApplyCommand(variables,"destroy"))
    os.chdir("..")


aws_linux_required_variables = {  "access_key", "secret_key" }
aws_windows_required_variables = {  "access_key", "secret_key" }

azure_linux_required_variables = {"subscription_id","tenant_id","client_id","client_secret" }
azure_windows_required_variables = {"subscription_id","tenant_id","client_id","client_secret"}

gcp_linux_required_variables = {"project","service_account_credentials_file_location"}


aws_linux_variables = None
aws_windows_variables = None
azure_linux_variables = None
azure_windows_variables = None
gcp_linux_variables = None
data = None

try:
    data = json.loads(open("input.json").read())
except:
    print("Please provide input.json")
    exit(0)
    
try:
    aws_linux_variables = data["aws_linux"].items()
except:
    print("skipping \"aws-linux\" vm creation because you have not provided all required variables in input.json")

try:
    aws_windows_variables = data["aws_windows"].items()
except:
    print("skipping \"aws-windows\" vm creation because you have not provided all required variables in input.json")

try:
    azure_linux_variables = data["azure_linux"].items()
except:
    print("skipping \"azure-linux\" vm creation because you have not provided all required variables in input.json")

try:
    azure_windows_variables = data["azure_windows"].items()
except:
    print("skipping \"azure-windows\" vm creation because you have not provided all required variables in input.json")

try:
    gcp_linux_variables = data["gcp_linux"].items()
except:
    print("skipping \"gcp-linux\" vm creation because you have not provided all required variables in input.json")


# if(validateVariables(aws_linux_required_variables,aws_linux_variables)):
#     print(generateApplyCommand(aws_linux_variables))
#     os.chdir("aws")
#     os.system("terraform init -upgrade")
#     os.system(generateApplyCommand(aws_linux_variables))
#     os.chdir("..")

if(validateVariables(aws_windows_required_variables,aws_windows_variables)):
    print(generateApplyCommand(aws_windows_variables))
    os.chdir("aws-win")
    os.system("terraform init -upgrade")
    os.system(generateApplyCommand(aws_windows_variables))
    os.chdir("..")

# if(validateVariables(azure_linux_required_variables,azure_linux_variables)):
#     print(generateApplyCommand(azure_linux_variables))
#     os.chdir("azure")
#     os.system("terraform init -upgrade")
#     os.system(generateApplyCommand(azure_linux_variables))
#     os.chdir("..")


# if(validateVariables(azure_windows_required_variables,azure_windows_variables)):
#     print(generateApplyCommand(azure_windows_variables))
#     os.chdir("azure-win")
#     os.system("terraform init -upgrade")
#     os.system(generateApplyCommand(azure_windows_variables))
#     os.chdir("..")


# if(validateVariables(gcp_linux_required_variables,gcp_linux_variables)):
#     print(generateApplyCommand(gcp_linux_variables))
#     os.chdir("gcp")
#     os.system("terraform init -upgrade")
#     os.system(generateApplyCommand(gcp_linux_variables))
#     os.chdir("..")


# s = input("Enter \"yes\" without quotes to destroy all resources:  \n")

# if(s != "yes"):
#     exit(0)

# destroyResources("aws",aws_linux_variables)
# destroyResources("aws-win",aws_windows_variables)

# destroyResources("azure",azure_linux_variables)
# destroyResources("azure-win",azure_windows_variables)

# destroyResources("gcp",gcp_linux_variables)
    