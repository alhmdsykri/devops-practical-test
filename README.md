# Todo WebAPI - DevOps Practical Test

## Architecture Overview

```
[ User / Internet ]
        │
        ▼
[ Internet Gateway ]
        │
   ┌────┴─────────────────────────┐
   │         AWS VPC              │
   │                              │
   │  ┌────────────────────────┐  │
   │  │    Public Subnet       │  │
   │  │  ┌──────────────────┐  │  │
   │  │  │  EC2 t2.micro    │  │  │
   │  │  │  Ubuntu 22.04    │  │  │
   │  │  │  nginx + .NET 8  │  │  │
   │  │  └──────────────────┘  │  │
   │  └────────────────────────┘  │
   │                              │
   │  ┌────────────────────────┐  │
   │  │    Private Subnet      │  │
   │  │  ┌──────────────────┐  │  │
   │  │  │   RDS MySQL 8.0  │  │  │
   │  │  └──────────────────┘  │  │
   │  └────────────────────────┘  │
   └──────────────────────────────┘
        │                │
        ▼                ▼
  [ S3 Bucket ]   [ CloudWatch ]
  (app binary)    (logs & metrics)
```

### Why This Architecture?
- **EC2 di public subnet** agar bisa diakses langsung dari internet via port 80
- **RDS di private subnet** agar database tidak terekspos ke internet
- **S3** untuk menyimpan binary app, diakses EC2 via IAM Role (tanpa credentials)
- **CloudWatch** untuk monitoring terpusat dan logging aplikasi
- **nginx** sebagai reverse proxy dari port 80 ke port 5000 (app)
- **S3 dan CloudWatch berada di luar VPC** karena merupakan AWS managed services

---

## Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform >= 1.0 installed
- EC2 Key Pair sudah dibuat di AWS Console

---

## Task 2: Infrastructure as Code

### File Structure
```
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
```

### Deploy Infrastructure

```bash
cd terraform

# 1. Init Terraform
terraform init

# 2. Preview perubahan
terraform plan -var="key_pair_name=YOUR_KEY_PAIR_NAME"

# 3. Apply
terraform apply -var="key_pair_name=YOUR_KEY_PAIR_NAME"

# 4. Destroy (setelah selesai testing)
terraform destroy -var="key_pair_name=YOUR_KEY_PAIR_NAME"
```

### Upload Binary ke S3

```bash
# Zip folder binary
cd linux-x64
zip -r ../app.zip .

# Upload ke S3 (gunakan bucket name dari output terraform)
aws s3 cp app.zip s3://BUCKET_NAME/app.zip --region ap-southeast-1
```

---

## Task 3: Deployment Script

File: `scripts/deploy.sh`

Script berjalan otomatis saat EC2 pertama kali launch via `user_data`. Langkah-langkah:

1. Update & upgrade sistem Ubuntu
2. Install dependencies: AWS CLI, .NET 8 runtime, nginx, CloudWatch Agent
3. Buat user `appuser` untuk menjalankan aplikasi
4. Download binary dari S3 dan extract ke `/opt/todowebapi`
5. Setup nginx sebagai reverse proxy port 80 → 5000
6. Buat systemd service agar app otomatis jalan dan restart jika crash

---

## Task 4: Monitoring & Logging

### CloudWatch Setup
- **Log Group** `/todo-webapi/application` → log aplikasi dari `/var/log/todowebapi/app.log`
- **Log Group** `/todo-webapi/system` → syslog dari EC2
- **Alarm** `todo-ec2-high-cpu` → alert jika CPU EC2 > 80% selama 2 periode (4 menit)
- **Alarm** `todo-rds-high-cpu` → alert jika CPU RDS > 80% selama 2 periode (4 menit)
- **Alarm** `todo-rds-low-storage` → alert jika free storage RDS < 2GB

CloudWatch Agent config: `cloudwatch/cloudwatch-agent-config.json`

---

## Task 5: CI/CD Pipeline (Conceptual)

### Tools
- **GitHub Actions** - CI/CD runner (gratis untuk public repo)
- **AWS S3** - artifact storage
- **AWS SSM** - remote command ke EC2 tanpa SSH

### Pipeline Stages

```
1. BUILD
   - Trigger: push ke branch main
   - dotnet restore
   - dotnet build
   - dotnet test

2. PACKAGE
   - dotnet publish -r linux-x64 --self-contained false
   - zip artifact

3. UPLOAD
   - aws s3 cp app.zip s3://BUCKET/app.zip

4. DEPLOY
   - aws ssm send-command ke EC2
   - EC2 download zip dari S3
   - Restart systemd service: systemctl restart todowebapi

5. VERIFY
   - curl http://EC2_IP/api-docs
   - Jika gagal, rollback ke versi sebelumnya
```

---

## Live Demo

- Swagger UI: `http://13.229.200.246/api-docs`

---

## Assumptions

- Test environment, bukan production (single EC2, no load balancer)
- SSH port 22 dibuka ke semua IP untuk kemudahan akses (production harus dibatasi ke IP tertentu)
- `skip_final_snapshot = true` pada RDS karena ini test environment
- Region: `ap-southeast-1` (Singapore) - terdekat dari Indonesia
- App binary di-deploy sebagai self-contained executable Linux x64
