### future-airlines-terraform-infrasturcture

cd components/jenkins-master

terraform init

terraform workspace list

terraform workspace select new nonprod-jenkins-master
  
terraform workspace select nonprod-jenkins-master

terraform plan -var-file=../../_TFVARS/nonprod-jenkins-master.tfvars

terraform apply -var-file=../../_TFVARS/nonprod-jenkins-master.tfvars

