terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

#to select env
#terraform workspace select dev

#to initialize and deploy per env
# terraform init -reconfigure
# terraform init
# terraform workspace select dev
# terraform plan -var-file="env/dev.tfvars"
# terraform apply -var-file="env/dev.tfvars"
# terraform destroy -var-file="env/dev.tfvars"

# terraform plan -var-file="env/dev.tfvars" -out=dev-plan.tfplan
# terraform apply dev-plan.tfplan

#aws eks update-kubeconfig --region ca-central-1 --name tsp-cluster-dev
#kubectl get all

#kubectl get nodes

# terraform fmt          # auto-format your .tf files
# terraform validate  