# Deploy script, run from project root
terraform init -backend-config 'config/backend.tfvars' infra
terraform apply -auto-approve -var-file 'config/setup.tfvars' infra
