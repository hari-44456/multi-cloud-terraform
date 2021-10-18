#!/bin/bash

# chmod +x test.sh

echo -e "Choose \n 1-AWS \n 2-AZURE \n 3-GCP"
read a

if [ $a == 1 ]
then
  cd aws
elif [ $a == 2 ]
then
  cd azure
elif [ $a == 3 ]
then
  pwd
  cd gcp
else  
  exit 0
fi

terraform init
terraform apply --auto-approve
cd ..

echo "Enter \"yes\" (without quotes) to destroy resources"
read var 

if [ $var != "yes" ]
then
  exit 0
fi 

if [ $a == 1 ]
then
  cd aws
elif [ $a == 2 ]
then
  cd azure
elif [ $a == 3 ]
then
  cd gcp 
fi

terraform destroy --auto-approve
