#!/bin/bash 

terraform_destroy(){
    echo "Do you want to destroy the instances:yes/no"
    read input
    if [ $input=="yes" ]
    then
        terraform destroy -var instance=$1 --auto-approve
    else
       exit 0    
    fi 
     
}
terraform_cmd(){
    terraform init
    terraform apply  -var instance=$1 --auto-approve
    
}
terraform_aws() {
   echo "Enter Number of instance in Aws:"  
   read instance
   cd aws
   terraform_cmd $instance
   terraform_destroy $instance
   cd ..
}
terraform_azure() {
   echo "Enter Number of instance in Azure:"  
   read instance
   cd azure
   terraform_cmd $instance
   terraform_destroy $instance
   cd ..
}
terraform_gcp() {
   echo "Enter Number of instance in GCP:"  
   read instance
   cd GCP
   terraform_cmd $instance
   terraform_destroy $instance
   cd ..
}
echo "Enter option of Cloud: 1.Aws 2.Azure 3.GCP 4.Aws+Azure 5.Aws+GCP 6.Azure+GCP 7.Aws+Azure+GCP "  
read option

if [ $option == 1 ]
then
   terraform_aws

fi

if [ $option == 2 ]
then
    terraform_azure
fi

if [ $option == 3 ]
then
    terraform_gcp
fi

if [ $option == 4 ]
then
    echo "Enter Number of instance in Aws:"  
    read instance1
    echo "Enter Number of instance in Azure:"  
    read instance2
    cd aws
    terraform_cmd $instance1
    terraform_destroy $instance1
    cd ..
    cd azure
    terraform_cmd $instance2
    terraform_destroy $instance2
    cd ..


fi

if [ $option == 5 ]
then
    echo "Enter Number of instance in Aws:"  
    read instance1
    echo "Enter Number of instance in GCP:"  
    read instance2
    cd aws
    terraform_cmd $instance1
    terraform_destroy $instance1
    cd ..
    cd GCP
    terraform_cmd $instance2
    terraform_destroy $instance2
    cd ..
fi

if [ $option == 6 ]
then
    echo "Enter Number of instance in Azure:"  
    read instance1
    echo "Enter Number of instance in GCP:"  
    read instance2
    cd azure
    terraform_cmd $instance1
    terraform_destroy $instance1
    cd ..
    cd GCP
    terraform_cmd $instance2
    terraform_destroy $instance2
    cd ..
fi

if [ $option == 7 ]
then
   echo "Enter Number of instance in Aws:"  
   read instance1
   echo "Enter Number of instance in Azure:"  
   read instance2
   echo "Enter Number of instance in GCP:"  
   read instance3
   cd aws
   terraform_cmd $instance1
   terraform_destroy $instance1
   cd ..
   cd azure
   terraform_cmd $instance2
   terraform_destroy $instance2
   cd ..
   cd GCP
   terraform_cmd $instance3
   terraform_destroy $instance3
   cd ..
   

fi