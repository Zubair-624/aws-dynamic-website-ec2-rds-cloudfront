# aws-dynamic-website-ec2-rds-cloudfront
End-to-end automated deployment of a dynamic Python Flask web application on AWS — infrastructure provisioned entirely with Terraform, secrets managed via SSM Parameter Store, database hosted on private RDS MySQL, static assets served through CloudFront CDN, and zero-credential CI/CD pipeline powered by GitHub Actions OIDC.

# 🛡️ CostGuard — AWS Cost Optimisation System

> **Automated AWS cost governance platform** with anomaly detection, rightsizing recommendations, and Slack/email alerting — built with Terraform, Python (boto3), and Grafana dashboards.

![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Python](https://img.shields.io/badge/Python_3.11-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Status](https://img.shields.io/badge/Status-In_Progress-orange?style=for-the-badge)

---

## 📌 Table of Contents

- [Problem Statement](#-problem-statement)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Phase Progress](#-phase-progress)
- [Phase 1 — Bootstrap](#-phase-1--project-bootstrap-completed)
- [Prerequisites](#-prerequisites)
- [Getting Started](#-getting-started)
- [Author](#-author)

---

## 💡 Problem Statement

Every AWS team faces the same problem — **cloud bills spiral out of control** without realtime visibility. Engineers only notice cost spikes days later when the invoice arrives.

**CostGuard solves this by:**
- Automatically collecting daily spend data across all AWS services
- Detecting anomalies when any service spikes beyond a threshold
- Recommending EC2 rightsizing based on actual CPU usage
- Sending instant Slack and email alerts when budgets are exceeded

---

## 🏗️ Architecture

> 📸 **[Screenshot placeholder — add `docs/architecture.png` here]**

```
EventBridge Scheduler (daily 06:00 UTC)
        │
        ▼
Lambda: cost-collector
  → Cost Explorer API (last 30 days)
  → Stores per-service spend in DynamoDB
  → Stores raw JSON report in S3
        │
        ▼
Lambda: anomaly-detector          Lambda: rightsizing-advisor
  → 7-day rolling average           → Trusted Advisor + CloudWatch
  → Flags spikes > 20%              → Identifies underused EC2
  → Writes to DynamoDB              → Writes to DynamoDB
        │                                   │
        └──────────────┬────────────────────┘
                       ▼
              Lambda: notifier
                → Reads anomalies + recommendations
                → Publishes to SNS topic
                       │
          ┌────────────┴────────────┐
          ▼                         ▼
    Email (SNS)            Lambda: slack-relay
                             → SSM Parameter Store
                             → Slack Webhook

  AWS Budgets (separate flow)
    → 80% / 100% threshold alerts
    → SNS → Email + Slack

  Grafana Dashboard
    → CloudWatch custom metrics datasource
    → Daily cost, anomalies, budget utilisation
```

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| **IaC** | Terraform >= 1.6 (AWS provider ~> 5.0) |
| **Language** | Python 3.11 + boto3 |
| **Compute** | AWS Lambda |
| **Scheduling** | Amazon EventBridge Scheduler |
| **Database** | Amazon DynamoDB (3 tables) |
| **Storage** | Amazon S3 |
| **Alerting** | Amazon SNS → Email + Slack |
| **Cost APIs** | AWS Cost Explorer, AWS Budgets, Trusted Advisor |
| **Observability** | CloudWatch Metrics + Logs + Alarms |
| **Dashboards** | Grafana (CloudWatch datasource) |
| **CI/CD** | GitHub Actions (OIDC — no static credentials) |
| **Secrets** | AWS SSM Parameter Store |
| **Testing** | pytest + moto (AWS mock library) |

---

## 📁 Project Structure

```
aws-cost-optimisation-system/
│
├── .github/workflows/
│   ├── terraform-plan.yml        # Runs on PR
│   └── terraform-apply.yml       # Runs on merge to main
│
├── terraform/
│   ├── backend.tf                # S3 remote state + DynamoDB lock
│   ├── providers.tf              # AWS provider + default tags
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── modules/
│       ├── dynamodb/             # 3 tables: cost_data, anomalies, recommendations
│       ├── s3/                   # Reports bucket
│       ├── iam/                  # Least-privilege roles + policies
│       ├── lambda/               # All 5 Lambda functions
│       ├── eventbridge/          # Daily cron scheduler
│       ├── sns/                  # Alerts topic + subscriptions
│       ├── budgets/              # Monthly budget alarms
│       └── cloudwatch/           # Alarms + log groups + dashboard
│
├── lambdas/
│   ├── cost_collector/
│   ├── anomaly_detector/
│   ├── rightsizing_advisor/
│   ├── notifier/
│   └── slack_relay/
│
├── scripts/
│   ├── bootstrap_backend.sh      # One-time: creates S3 + DynamoDB for TF state
│   ├── package_lambdas.sh
│   └── run_tests.sh
│
├── grafana/dashboards/
│   └── costguard-overview.json
│
├── docs/
│   └── architecture.png
│
└── README.md
```

---

## ✅ Phase Progress

| Phase | Description | Status |
|-------|-------------|--------|
| **Phase 1** | Project Bootstrap | ✅ Complete |
| **Phase 2** | DynamoDB + S3 Modules | 🔄 In Progress |
| **Phase 3** | IAM Module | ⬜ Pending |
| **Phase 4** | Lambda Functions (Python) | ⬜ Pending |
| **Phase 5** | EventBridge + SNS Modules | ⬜ Pending |
| **Phase 6** | Budgets + CloudWatch + Grafana | ⬜ Pending |
| **Phase 7** | CI/CD + Tests + Documentation | ⬜ Pending |

---

## 🚀 Phase 1 — Project Bootstrap ✅ Completed

### What was built

| Resource | Name | Purpose |
|----------|------|---------|
| **S3 Bucket** | `zubair-tf-state-project002` | Stores Terraform remote state |
| **DynamoDB Table** | `terraform-state-lock-project002` | Prevents concurrent Terraform runs |
| **Terraform Backend** | S3 + DynamoDB | Remote state with locking enabled |
| **AWS Provider** | `hashicorp/aws v5.100.0` | Pinned via `.terraform.lock.hcl` |

### S3 Bucket configuration

| Setting | Value |
|---------|-------|
| Versioning | ✅ Enabled |
| Public Access | ✅ Fully blocked (all 4 flags) |
| Encryption | ✅ SSE-S3 (AES256) |
| Region | `us-east-1` |

### DynamoDB Table configuration

| Setting | Value |
|---------|-------|
| Partition Key | `LockID` (String) |
| Billing Mode | `PAY_PER_REQUEST` |
| Table Status | `ACTIVE` |

### Verification

> 📸 **[Screenshot placeholder — add your terminal output here showing `terraform init` success]**

```bash
# Commands used to verify
aws s3api head-bucket --bucket zubair-tf-state-project002 --profile zubair-devops
aws s3api get-bucket-versioning --bucket zubair-tf-state-project002 --profile zubair-devops
aws s3api get-public-access-block --bucket zubair-tf-state-project002 --profile zubair-devops
aws dynamodb describe-table --table-name terraform-state-lock-project002 --region us-east-1 --profile zubair-devops
```

**Result:** `Successfully configured the backend "s3"` ✅

---

## 🔧 Prerequisites

- AWS Account with programmatic access
- AWS CLI configured (`aws configure --profile zubair-devops`)
- Terraform >= 1.6 installed
- Python 3.11 installed
- `direnv` installed (for automatic env loading via `.envrc`)

---

## ⚡ Getting Started

### 1. Clone the repo

```bash
git clone https://github.com/YOUR_USERNAME/aws-cost-optimisation-system.git
cd aws-cost-optimisation-system
```

### 2. Bootstrap the Terraform backend (run once only)

```bash
bash scripts/bootstrap_backend.sh
```

### 3. Initialise Terraform

```bash
cd terraform
terraform init
```

### 4. Set up Python environment

```bash
python3 -m venv venv
source venv/bin/activate
pip install boto3 pytest black flake8 moto
```

---

## 👤 Author

**Zubair Mazumder**
- GitHub: [@YOUR_USERNAME](https://github.com/YOUR_USERNAME)
- LinkedIn: [your-linkedin](https://linkedin.com/in/your-linkedin)

---

> 🚧 *This project is actively being built. Each phase is committed separately with full documentation.*
