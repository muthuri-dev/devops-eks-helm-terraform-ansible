# DevOps EKS Infrastructure with Terraform, Helm & Ansible

A production-ready DevOps infrastructure solution featuring Amazon EKS cluster with comprehensive observability stack including ELK (Elasticsearch, Logstash, Kibana), Prometheus/Grafana monitoring, and ArgoCD GitOps deployment using Infrastructure as Code (IaC) principles.

## 🏗️ Architecture Overview

This project implements a complete production-grade EKS infrastructure with observability and GitOps:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                  AWS Cloud                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                              VPC (10.0.0.0/16)                             │ │
│  │                                                                             │ │
│  │  ┌─────────────────┐                           ┌─────────────────┐         │ │
│  │  │   Public Subnet │                           │   Public Subnet │         │ │
│  │  │   (us-east-1a)  │                           │   (us-east-1b)  │         │ │
│  │  │                 │                           │                 │         │ │
│  │  │  ┌─────────────┐│                           │┌─────────────────┐       │ │
│  │  │  │ NAT Gateway ││                           ││  Load Balancers │       │ │
│  │  │  │             ││                           ││ (Kibana/Grafana)│       │ │
│  │  │  └─────────────┘│                           │└─────────────────┘       │ │
│  │  └─────────────────┘                           └─────────────────┘         │ │
│  │           │                                              │                 │ │
│  │  ┌─────────────────┐                           ┌─────────────────┐         │ │
│  │  │  Private Subnet │                           │  Private Subnet │         │ │
│  │  │   (us-east-1a)  │                           │   (us-east-1b)  │         │ │
│  │  │                 │                           │                 │         │ │
│  │  │ ┌─────────────┐ │                           │ ┌─────────────┐ │         │ │
│  │  │ │ EKS Workers │ │                           │ │ EKS Workers │ │         │ │
│  │  │ │             │ │                           │ │             │ │         │ │
│  │  │ │┌───────────┐│ │                           │ │┌───────────┐│ │         │ │
│  │  │ ││ELK Stack  ││ │                           │ ││Monitoring ││ │         │ │
│  │  │ ││Prometheus ││ │                           │ ││ArgoCD     ││ │         │ │
│  │  │ ││Fluent Bit ││ │                           │ ││Apps       ││ │         │ │
│  │  │ │└───────────┘│ │                           │ │└───────────┘│ │         │ │
│  │  │ └─────────────┘ │                           │ └─────────────┘ │         │ │
│  │  └─────────────────┘                           └─────────────────┘         │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## 🎯 Features

### ✅ **Infrastructure Components**

- **Amazon EKS**: Managed Kubernetes cluster with multi-AZ worker nodes
- **VPC Networking**: Production-grade networking with public/private subnets
- **EBS CSI Driver**: Persistent storage support with automatic provisioning
- **Load Balancers**: AWS ALB for external access to services

### ✅ **Observability Stack**

- **ELK Stack**: Elasticsearch + Kibana with ECK operator for log aggregation
- **Fluent Bit**: Lightweight log collection from all containers
- **Prometheus**: Metrics collection and monitoring
- **Grafana**: Metrics visualization and dashboards

### ✅ **GitOps & DevOps**

- **ArgoCD**: GitOps continuous deployment
- **Terraform**: Infrastructure as Code with remote state
- **Helm**: Package management for Kubernetes applications

## 📁 Project Structure

```
devops-eks-helm-terraform-ansible/
├── infrastructure/              # Terraform IaC configurations
│   ├── 01-provider.tf          # Multi-provider configuration (AWS, Helm, Kubernetes, kubectl, TLS)
│   ├── 02-backend.tf           # S3 backend with state locking
│   ├── 03-variables.tf         # Variable definitions
│   ├── 04-vpc-networking.tf    # VPC, subnets, NAT gateway, security groups
│   ├── 05-eks-networking.tf    # EKS cluster and node groups
│   ├── 06-ebs-csi.tf          # EBS CSI driver with OIDC provider
│   ├── 07-monitoring.tf        # Prometheus and Grafana deployment
│   ├── 08-argocd.tf           # ArgoCD GitOps platform
│   ├── 09-logging.tf          # ECK-based ELK stack
│   └── 11-outputs.tf          # Infrastructure outputs
├── helm/                       # Helm charts for applications
├── ansible/                    # Ansible playbooks and roles
├── application/                # Application source code
├── .gitignore                 # Comprehensive ignore rules
└── README.md                  # This documentation
```

## 🚀 Prerequisites

Before you begin, ensure you have the following tools installed:

### Required Tools

- **Terraform** >= 1.12.0
- **AWS CLI** >= 2.0
- **kubectl** >= 1.28
- **Helm** >= 3.0
- **curl** (for testing endpoints)

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

### 3. Configure kubectl

```bash
# Update kubeconfig for EKS cluster
aws eks update-kubeconfig --region us-east-1 --name production_eks

# Verify cluster access
kubectl get nodes
```

## 🌐 Service Access

### **Kibana Dashboard (Log Visualization)**

```bash
# Get Kibana LoadBalancer URL
kubectl get service kibana-kb-http -n elastic-stack

# Access URL (example):
# http://af2aafebe7cfd43aaa966173c9609a36-664672556.us-east-1.elb.amazonaws.com:5601
```

**Setting up Log Visualization:**

1. Open Kibana in your browser
2. Go to **Stack Management** → **Index Patterns**
3. Create new index pattern: `fluent-bit*`
4. Choose `@timestamp` as time field
5. Go to **Discover** to view logs

### **Grafana Dashboard (Metrics)**

```bash
# Get Grafana LoadBalancer URL
kubectl get service prometheus-grafana -n monitoring
```

### **ArgoCD Dashboard (GitOps)**

```bash
# Get ArgoCD LoadBalancer URL
kubectl get service argocd-server -n argocd

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### **Elasticsearch (Direct Access)**

```bash
# Port-forward to access Elasticsearch
kubectl port-forward service/elasticsearch-es-http 9200:9200 -n elastic-stack

# Test cluster health
curl -X GET "localhost:9200/_cluster/health?pretty"

# Check indices
curl -X GET "localhost:9200/_cat/indices?v"
```

## 📊 Infrastructure Components Details

### **EKS Cluster Configuration**

- **Cluster Name**: `production_eks`
- **Version**: Latest supported version
- **Node Groups**: Auto-scaling across multiple AZs
- **Instance Types**: Optimized for cost and performance

### **VPC Configuration**

- **CIDR Block**: `10.0.0.0/16`
- **Availability Zones**: 2 AZs for high availability
- **Public Subnets**: 2 subnets for load balancers and NAT gateways
- **Private Subnets**: 2 subnets for EKS worker nodes

### **Storage Configuration**

- **EBS CSI Driver**: v1.48.0 with OIDC authentication
- **Storage Class**: `gp2` (default)
- **Persistent Volumes**: Automatic provisioning for stateful apps

### **Observability Stack Details**

#### ELK Stack (Logging)

- **Elasticsearch**: 8.5.1 with 5GB persistent storage
- **Kibana**: 8.5.1 with LoadBalancer access
- **Fluent Bit**: DaemonSet for container log collection
- **Index Pattern**: `fluent-bit*` for log visualization

#### Monitoring Stack

- **Prometheus**: Metrics collection and storage
- **Grafana**: Metrics visualization dashboards
- **Service Monitors**: Automatic discovery of metrics endpoints

#### GitOps

- **ArgoCD**: Application deployment and synchronization
- **LoadBalancer**: External access for UI and API

## 🔐 Security Best Practices

### **State Management**

- Terraform state stored in encrypted S3 bucket
- State locking with DynamoDB recommended
- Remote state prevents local state corruption

### **Network Security**

- Private subnets for workloads
- Public subnets only for load balancers
- Security groups with least privilege access
- NAT Gateway for secure outbound connectivity

### **Authentication & Authorization**

- OIDC provider for service account authentication
- IAM roles for service accounts (IRSA)
- Cluster RBAC with service accounts

## 🔧 Troubleshooting

### **Common Issues**

#### EBS CSI Driver Not Working

```bash
# Check EBS CSI driver pods
kubectl get pods -n kube-system | grep ebs

# Check storage classes
kubectl get storageclass
```

#### Kibana Not Accessible

```bash
# Check Kibana pod logs
kubectl logs -n elastic-stack -l kibana.k8s.elastic.co/name=kibana

# Check service status
kubectl get service kibana-kb-http -n elastic-stack
```

#### Elasticsearch Yellow Status

This is normal for single-node clusters. For production, increase replica count.

### **Useful Commands**

```bash
# Get all pods across namespaces
kubectl get pods --all-namespaces

# Check Terraform state
terraform state list

# View LoadBalancer services
kubectl get services --all-namespaces | grep LoadBalancer

# Check cluster resources
kubectl top nodes
kubectl top pods --all-namespaces
```

## 🧹 Cleanup

To destroy the infrastructure:

```bash
cd infrastructure/
terraform destroy
```

⚠️ **Warning**: This will permanently delete all resources including persistent data. Ensure you have backups of any important data.

## 📈 Scaling and Production Considerations

### **For Production Use:**

1. **Enable DynamoDB State Locking**:

   ```hcl
   terraform {
     backend "s3" {
       bucket         = "devops-cluster-state-bucket"
       key            = "terraform.tfstate"
       region         = "us-east-1"
       dynamodb_table = "terraform-state-lock"
       encrypt        = true
     }
   }
   ```

2. **Multi-Environment Setup**:

   - Use Terraform workspaces or separate state files
   - Environment-specific variable files
   - Separate AWS accounts for environments

3. **Enhanced Security**:

   - Enable AWS GuardDuty
   - Set up AWS Config for compliance
   - Implement pod security policies
   - Network policies for micro-segmentation

4. **Backup Strategy**:
   - Regular EBS snapshots
   - Elasticsearch backup to S3
   - ArgoCD application definitions in Git

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
- [ECK (Elastic Cloud on Kubernetes) Documentation](https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html)
- [Prometheus Operator Documentation](https://prometheus-operator.dev/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Helm Documentation](https://helm.sh/docs/)

---

**Built with ❤️ for modern DevOps practices**
