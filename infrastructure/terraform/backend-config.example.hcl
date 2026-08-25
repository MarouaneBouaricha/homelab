# Copy this file to backend-config.hcl and update the values.
bucket         = "k8s-lab-dev-tf-state-xxxxx"
key            = "homelab/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "k8s-lab-dev-terraform-lock"