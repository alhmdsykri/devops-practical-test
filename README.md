# Todo WebAPI - DevOps Practical Test

  ## Architecture Overview

  Internet
     │
     ▼
  [Internet Gateway]
     │
     ▼
  [EC2 t2.micro - Ubuntu] ←──── [S3 Bucket - App Binary]
     │  Public Subnet
     │
     ▼
  [RDS MySQL 8.0]
     Private Subnet

  [CloudWatch] ←── metrics & logs dari EC2 + RDS

  ### Why This Architecture?
  - **EC2 di public subnet** agar bisa diakses langsung dari internet via port 80
  - **RDS di private subnet** agar database tidak terekspos ke internet
  - **S3** untuk menyimpan binary app, diakses EC2 via IAM Role (tanpa credentials)
  - **CloudWatch** untuk monitoring terpusat dan logging aplikasi
  - **nginx** sebagai reverse proxy dari port 80 ke port 5000 (app)

  ---

  ## Prerequisites

  - AWS CLI configured (`aws configure`)
  - Terraform >= 1.0 installed
  - EC2 Key Pair sudah dibuat di AWS Console

  ---

  ## Task 2: Infrastructure as Code

  ### File Structure
  terraform/
  ├── main.tf             # Provider AWS dan Terraform config
  ├── variables.tf        # Variabel (region, db credentials, key pair)
  ├── vpc.tf              # VPC, subnets, internet gateway, route table
  ├── security_groups.tf  # SG untuk EC2 (port 80, 5000, 22) dan RDS (3306)
  ├── s3.tf               # S3 bucket untuk menyimpan binary aplikasi
  ├── iam.tf              # IAM Role agar EC2 bisa akses S3 dan CloudWatch
  ├── ec2.tf              # EC2 t2.micro Ubuntu, auto-run deploy.sh via user_data
  ├── rds.tf              # RDS MySQL 8.0 db.t3.micro di private subnet
  └── cloudwatch.tf       # Log groups dan metric alarms untuk EC2 & RDS

  ### Deploy Infrastructure

  ```bash
  cd terraform

  # 1. Init Terraform
  terraform init

  # 2. Preview perubahan
  terraform plan -var="key_pair_name=YOUR_KEY_PAIR_NAME"

  # 3. Apply
  terraform apply -var="key_pair_name=YOUR_KEY_PAIR_NAME"
