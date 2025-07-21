terraform init
terraform apply --auto-approve -var-file="terraform.tfvars"

#if login in through localhost####  
kubectl port-forward svc/argocd-server -n argocd 8080:443

#argocd password
ausername : admin
#to get password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode && echo