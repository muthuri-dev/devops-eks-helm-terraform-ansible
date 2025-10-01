# DevOps EKS Infrastructure with Terraform, Helm & Ansible

A complete DevOps infrastructure solution featuring Amazon EKS cluster deployment using Infrastructure as Code (IaC) principles with Terraform, application deployment using Helm charts, and configuration management with Ansible.

## 🏗️ Architecture Overview

This project implements a production-ready EKS infrastructure with the following components:

```
┌─────────────────────────────────────────────────────────────┐
│                        AWS VPC                             │
│  ┌─────────────────┐              ┌─────────────────┐      │
│  │   Public Subnet │              │   Public Subnet │      │
│  │      AZ-1       │              │      AZ-2       │      │
│  │                 │              │                 │      │
│  │  ┌─────────────┐│              │┌─────────────┐  │      │
│  │  │     NAT     ││              ││    Load     │  │      │
│  │  │   Gateway   ││              ││  Balancer   │  │      │
│  │  └─────────────┘│              │└─────────────┘  │      │
│  └─────────────────┘              └─────────────────┘      │
│           │                               │                │
│  ┌─────────────────┐              ┌─────────────────┐      │
│  │  Private Subnet │              │  Private Subnet │      │
│  │      AZ-1       │              │      AZ-2       │      │
│  │                 │              │                 │      │
│  │  ┌─────────────┐│              │┌─────────────┐  │      │
│  │  │ EKS Worker  ││              ││ EKS Worker  │  │      │
│  │  │    Nodes    ││              ││    Nodes    │  │      │
│  │  └─────────────┘│              │└─────────────┘  │      │
│  └─────────────────┘              └─────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
devops-eks-helm-terraform-ansible/
├── infrastructure/           # Terraform IaC configurations
│   ├── 01-provider.tf       # AWS provider configuration
│   ├── 02-backend.tf        # S3 backend configuration
│   ├── 03-variables.tf      # Variable definitions
│   └── 04-vpc-networking.tf # VPC and networking resources
├── helm/                    # Helm charts for applications
├── ansible/                 # Ansible playbooks and roles
├── application/             # Application source code
├── .gitignore              # Git ignore rules
└── README.md               # This file
```

## 🚀 Prerequisites

Before you begin, ensure you have the following tools installed:

### Required Tools

- **Terraform** >= 1.12.0
- **AWS CLI** >= 2.0
- **kubectl** >= 1.28
- **Helm** >= 3.0
- **Ansible** >= 2.9

### AWS Configuration

```bash
# Configure AWS credentials
aws configure

# Verify access
aws sts get-caller-identity
```

## 🔧 Infrastructure Setup

### 1. Initialize Terraform Backend

First, create the S3 bucket for Terraform state:

```bash
# Create S3 bucket for state (if not exists)
aws s3 mb s3://devops-cluster-state-bucket --region us-east-1
```

### 2. Deploy Infrastructure

```bash
cd infrastructure/

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### 3. Verify Deployment

```bash
# List created resources
terraform state list

# Show VPC details
terraform show aws_vpc.production_vpc
```

## 📊 Infrastructure Components

### VPC Configuration

- **CIDR Block**: `10.0.0.0/16`
- **Availability Zones**: 2 AZs for high availability
- **Public Subnets**: 2 subnets for load balancers and NAT gateways
- **Private Subnets**: 2 subnets for EKS worker nodes

### Network Resources

- **Internet Gateway**: For public subnet internet access
- **NAT Gateway**: For private subnet outbound connectivity
- **Route Tables**: Separate routing for public and private subnets
- **Security Groups**: Network-level security controls

## 🎯 Variables Configuration

Key variables in `03-variables.tf`:

| Variable           | Default       | Description           |
| ------------------ | ------------- | --------------------- |
| `region`           | `us-east-1`   | AWS deployment region |
| `vpc_cidr_block`   | `10.0.0.0/16` | VPC CIDR block        |
| `eks_cluster_name` | `production`  | EKS cluster name      |

## 🔐 Security Best Practices

### State Management

- Terraform state stored in encrypted S3 bucket
- State locking with DynamoDB (recommended to add)
- Remote state prevents local state corruption

### Network Security

- Private subnets for workloads
- Public subnets only for load balancers
- Security groups with least privilege access
- NAT Gateway for secure outbound connectivity

## 🚢 Application Deployment

### Helm Charts

```bash
cd helm/

# Add application chart
helm create my-application

# Deploy application
helm install my-app ./my-application
```

### Ansible Configuration

```bash
cd ansible/

# Run playbook
ansible-playbook -i inventory site.yml
```

## 📈 Monitoring and Observability

### AWS CloudWatch Integration

- Container Insights for EKS
- VPC Flow Logs
- Application-level metrics

### Recommended Additions

- Prometheus & Grafana
- AWS Load Balancer Controller
- ExternalDNS for automatic DNS management
- Cert-Manager for TLS certificate automation

## 🔄 CI/CD Pipeline

### Terraform Workflow

```yaml
# .github/workflows/terraform.yml
name: Terraform
on: [push, pull_request]
jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Terraform Plan
        run: terraform plan
```

## 🧹 Cleanup

To destroy the infrastructure:

```bash
cd infrastructure/
terraform destroy
```

⚠️ **Warning**: This will permanently delete all resources. Ensure you have backups of any important data.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For questions and support:

- Create an issue in this repository
- Contact: [muthuri.dev](mailto:contact@muthuri.dev)

## 🔗 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Amazon EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [Helm Documentation](https://helm.sh/docs/)
- [Ansible Documentation](https://docs.ansible.com/)

---

**Built with ❤️ for modern DevOps practices**
