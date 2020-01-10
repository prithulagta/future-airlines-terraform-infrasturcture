### future-airlines-terraform-infrasturcture

cd components/jenkins-master
terraform init
terraform workspace list
terraform workspace select new <fttest1>
terraform workspace select fttest1
terraform plan -var-file=../_TFVARS/fttest1.tfvars
terraform apply -var-file=../_TFVARS/fttest1.tfvars
