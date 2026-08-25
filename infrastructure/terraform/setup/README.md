# Lab 00: Initial Setup

## Description

This setup guides you through the initial configuration needed to work with AWS and Terraform. You will configure the base tools and create the infrastructure needed to manage Terraform state remotely.

## Prerequisites

- AWS account (Free Tier is sufficient to start)
- Terminal (bash/zsh)
- Text editor

---

## Step 1: Install AWS CLI v2

### macOS

```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

### Linux

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Verify installation

```bash
aws --version
```

---

## Step 2: Configure AWS Credentials

### Option A: Basic configuration

```bash
aws configure
# AWS Access Key ID: <your-access-key>
# AWS Secret Access Key: <your-secret-key>
# Default region name: eu-west-1
# Default output format: json
```

### Option B: Use profiles (recommended)

```bash
aws configure --profile aws-lab
# Enter your credentials

# To use the profile:
export AWS_PROFILE=aws-lab

# Verify it works:
aws sts get-caller-identity --profile aws-lab
```

---

## Step 3: Install Terraform

### macOS (with Homebrew)

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

### Linux

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

### Verify installation

```bash
terraform version
```

---

## Step 4: Create Remote Backend for Terraform State

### Deploy the backend

```bash
cd 00-setup

# Initialize Terraform (local backend for this first step)
terraform init

# Review the plan
terraform plan -var="project_name=aws-lab" -var="environment=dev"

# Apply
terraform apply -var="project_name=aws-lab" -var="environment=dev"
```

### Verify

```bash
# Verify the bucket exists
aws s3 ls | grep aws-lab

# Verify the DynamoDB table
aws dynamodb list-tables
```

---

## Cleanup

> **Important:** Do NOT destroy this lab until you have finished all the others, since the remote backend is needed for the rest of the labs.

```bash
terraform destroy -var="project_name=k8s-lab" -var="environment=dev"
```