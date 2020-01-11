### future-airlines-terraform-infrasturcture

### To build mgmt vpc
cd components/vpc
terraform init

terraform workspace list

terraform workspace select new mgmt
  
terraform workspace select mgmt

terraform plan -var-file=../../_TFVARS/mgmt.tfvars

terraform apply -var-file=../../_TFVARS/mgmt.tfvars

### To build jenkins master in mgmt vpc
cd components/jenkins-master

terraform init

terraform workspace list

terraform workspace select new nonprod-jenkins-master
  
terraform workspace select nonprod-jenkins-master

terraform plan -var-file=../../_TFVARS/nonprod-jenkins-master.tfvars

terraform apply -var-file=../../_TFVARS/nonprod-jenkins-master.tfvars

