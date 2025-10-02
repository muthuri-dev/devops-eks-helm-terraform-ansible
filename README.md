# DevOps EKS Infrastructure with Terraform, Helm & Ansible

A production-ready DevOps infrastructure solution featuring Amazon EKS cluster with comprehensive observability stack, monitoring, logging, GitOps, and auto-scaling using Infrastructure as Code (IaC) principles.

## 🏗️ Architecture Overview

This project implements a complete production-grade EKS infrastructure with observability and GitOps:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                  AWS Cloud                                       │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                              VPC (10.0.0.0/16)                              │ │
│  │                                                                             │ │
│  │  ┌─────────────────┐                           ┌─────────────────┐          │ │
│  │  │   Public Subnet │                           │   Public Subnet │          │ │
│  │  │   (us-east-1a)  │                           │   (us-east-1b)  │          │ │
│  │  │                 │                           │                 │          │ │
│  │  │  ┌─────────────┐│                           │┌─────────────────┐         │ │
│  │  │  │ NAT Gateway ││                           ││  Load Balancers │         │ │
│  │  │  │             ││                           ││ (Kibana/Grafana)│         │ │
│  │  │  └─────────────┘│                           │└─────────────────┘         │ │
│  │  └─────────────────┘                           └─────────────────┘          │ │
│  │           │                                              │                  │ │
│  │  ┌─────────────────┐                           ┌─────────────────┐          │ │
│  │  │  Private Subnet │                           │  Private Subnet │          │ │
│  │  │   (us-east-1a)  │                           │   (us-east-1b)  │          │ │
│  │  │                 │                           │                 │          │ │
│  │  │ ┌─────────────┐ │                           │ ┌─────────────┐ │          │ │
│  │  │ │ EKS Workers │ │                           │ │ EKS Workers │ │          │ │
│  │  │ │ (Auto-Scale)│ │                           │ │ (Auto-Scale)│ │          │ │
│  │  │ │┌───────────┐│ │                           │ │┌───────────┐│ │          │ │
│  │  │ ││ELK Stack  ││ │                           │ ││Monitoring ││ │          │ │
│  │  │ ││Prometheus ││ │                           │ ││ArgoCD     ││ │          │ │
│  │  │ ││Vault      ││ │                           │ ││Apps       ││ │          │ │
│  │  │ ││Fluent Bit ││ │                           │ ││PostgreSQL ││ │          │ │
│  │  │ │└───────────┘│ │                           │ │└───────────┘│ │          │ │
│  │  │ └─────────────┘ │                           │ └─────────────┘ │          │ │
│  │  └─────────────────┘                           └─────────────────┘          │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## 🎯 Features

### ✅ **Infrastructure Components**

- **Amazon EKS**: Managed Kubernetes cluster with auto-scaling worker nodes
- **Cluster Autoscaler**: Automatic node scaling based on pod demand
- **VPC Networking**: Production-grade networking with public/private subnets
- **EBS CSI Driver**: Persistent storage support with automatic provisioning
- **Load Balancers**: AWS ALB for external access to services

### ✅ **Container & Database**

- **Amazon ECR**: Container registry for Docker images with scanning and lifecycle management
- **CloudNativePG**: PostgreSQL operator for database workload management
- **HashiCorp Vault**: Secrets management with secure storage
- **Cert-Manager**: Automatic SSL certificate management with Let's Encrypt integration

### ✅ **Observability Stack**

- **ELK Stack**: Elasticsearch + Kibana with ECK operator for log aggregation
- **Fluent Bit**: Lightweight log collection from all containers
- **Prometheus**: Metrics collection and monitoring with persistent storage
- **Grafana**: Metrics visualization and dashboards with persistent storage
- **AlertManager**: Alert routing and management (configure via UI)

### ✅ **GitOps & DevOps**

- **ArgoCD**: GitOps continuous deployment
- **Terraform**: Infrastructure as Code with remote state
- **Helm**: Package management for Kubernetes applications

## 📁 Project Structure

```
devops-eks-helm-terraform-ansible/
├── infrastructure/                    # Terraform IaC configurations
│   ├── 01-provider.tf                # Multi-provider configuration (AWS, Helm, Kubernetes, kubectl, TLS)
│   ├── 02-backend.tf                 # S3 backend with state locking
│   ├── 03-variables.tf               # Variable definitions with defaults
│   ├── 04-vpc-networking.tf          # VPC, subnets, NAT gateway, security groups
│   ├── 05-eks-cluster.tf             # EKS cluster configuration
│   ├── 06-ebs-csi.tf                 # EBS CSI driver with OIDC provider
│   ├── 07-nodegroup.tf               # EKS node groups with auto-scaling
│   ├── 08-monitoring.tf              # Prometheus, Grafana, AlertManager (UI config)
│   ├── 09-argocd.tf                  # ArgoCD GitOps platform
│   ├── 10-logging.tf                 # ECK-based ELK stack
│   ├── 11-outputs.tf                 # Infrastructure outputs
│   ├── 12-ecr.tf                     # Amazon ECR container registry
│   ├── 13-cloudnative-pg.tf          # CloudNativePG PostgreSQL operator
│   ├── 14-cert-manager.tf            # Cert-Manager for SSL certificates
│   ├── 15-vault.tf                   # HashiCorp Vault deployment
│   ├── 16-cluster-autoscaler.tf      # Cluster autoscaler with YAML deployment
│   └── cluster-autoscaler-deployment.yaml  # Cluster autoscaler YAML manifest
├── helm/                             # Helm charts for applications
├── ansible/                          # Ansible playbooks and roles
├── application/                      # Application source code
├── .gitignore                       # Comprehensive ignore rules
└── README.md                        # This documentation
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

### 2. Configure Variables (Optional)

All variables have sensible defaults in `infrastructure/03-variables.tf`. You can override them if needed:

- **Email**: `muthurikennedy082@gmail.com` (default for Let's Encrypt)
- **Region**: `us-east-1` (default)
- **Cluster**: `production_eks` (default)

### 3. Deploy Infrastructure

```bash
cd infrastructure/

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

**What gets deployed:**

- ✅ EKS cluster with auto-scaling nodes (2-12 nodes)
- ✅ Cluster autoscaler with YAML deployment
- ✅ Monitoring stack (Prometheus + Grafana + AlertManager)
- ✅ ELK stack for logging
- ✅ Vault for secrets management
- ✅ ArgoCD for GitOps
- ✅ PostgreSQL operator
- ✅ Cert-manager for SSL

### 4. Configure kubectl

```bash
# Update kubeconfig for EKS cluster
aws eks update-kubeconfig --region us-east-1 --name production_eks

# Verify cluster access
kubectl get nodes

# Check all pods are running
kubectl get pods --all-namespaces
```

## 🌐 Service Access

### **Grafana Dashboard (Metrics & Monitoring)**

```bash
# Get Grafana LoadBalancer URL
kubectl get service prometheus-stack-grafana -n monitoring

# Access Grafana
# Username: admin
# Password: admin123!
```

**Setting up Alerts in Grafana:**

1. Open Grafana in your browser
2. Go to **Alerting** → **Notification channels**
3. Add **Email** notification channel
4. Configure SMTP settings through the UI
5. Create alert rules for your dashboards

### **Prometheus (Metrics Storage)**

```bash
# Get Prometheus LoadBalancer URL
kubectl get service prometheus-stack-kube-prom-prometheus -n monitoring

# Access Prometheus UI for queries and targets
```

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

### **HashiCorp Vault (Secrets Management)**

```bash
# Get Vault LoadBalancer URL
kubectl get service vault -n vault

# Access Vault UI
# Initialize with 3 key shares, 2 key threshold (recommended for demo)
```

**Vault Setup:**

1. Open Vault UI in browser
2. Initialize with your preferred key shares/threshold
3. **Save the unseal keys and root token securely**
4. Unseal Vault with the required number of keys
5. Login with root token

### **ArgoCD Dashboard (GitOps)**

```bash
# Get ArgoCD LoadBalancer URL
kubectl get service argocd-server -n argocd

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### **AlertManager (Alert Management)**

```bash
# Port-forward to access AlertManager
kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-alertmanager 9093:9093

# Access at http://localhost:9093
```

**Configure Email Alerts:**

1. Port-forward to AlertManager
2. Configure notification receivers via UI
3. Set up routing rules for different alert severities

### **Cluster Autoscaler (Auto-scaling)**

```bash
# Check cluster autoscaler status
kubectl get pods -n kube-system | grep cluster-autoscaler

# View autoscaler logs
kubectl logs -n kube-system deployment/cluster-autoscaler

# Check current node count
kubectl get nodes
```

**Auto-scaling Features:**

- ✅ Automatic node scaling (2-12 nodes)
- ✅ Auto-discovery of Auto Scaling Groups
- ✅ Pod-driven scaling decisions
- ✅ IRSA authentication for AWS API access

### **Elasticsearch (Direct Access)**

```bash
# Port-forward to access Elasticsearch
kubectl port-forward service/elasticsearch-es-http 9200:9200 -n elastic-stack

# Test cluster health
curl -X GET "localhost:9200/_cluster/health?pretty"

# Check indices
curl -X GET "localhost:9200/_cat/indices?v"
```

### **Amazon ECR (Container Registry)**

```bash
# Get ECR login command
terraform output ecr_login_command

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com

# Build and push example
docker build -t devops-app:latest .
docker tag devops-app:latest YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/devops-app:latest
docker push YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/devops-app:latest
```

### **CloudNativePG (PostgreSQL)**

```bash
# Check operator status
kubectl get pods -n cnpg-system

# Create a simple PostgreSQL cluster
kubectl apply -f - <<EOF
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: my-postgres
  namespace: default
spec:
  instances: 1
  storage:
    size: 1Gi
EOF

# Check cluster status
kubectl get cluster
```

### **Cert-Manager (SSL Certificates)**

```bash
# Check cert-manager status
kubectl get pods -n cert-manager

# View available certificate issuers
kubectl get clusterissuers

# Check certificates across all namespaces
kubectl get certificates -A

# Example: Enable SSL for your Ingress
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app
            port:
              number: 80
EOF

# Check certificate creation progress
kubectl describe certificate myapp-tls
```

## 📊 Infrastructure Components Details

### **EKS Cluster Configuration**

- **Cluster Name**: `production_eks`
- **Version**: Latest supported EKS version
- **Node Groups**: Auto-scaling (2-12 nodes) across multiple AZs
- **Instance Types**: Optimized for cost and performance
- **Cluster Autoscaler**: YAML-based deployment with IRSA authentication

### **Auto-scaling Configuration**

- **Cluster Autoscaler**: v1.30.0 with auto-discovery
- **Node Scaling**: 2 minimum, 12 maximum nodes
- **Scaling Triggers**: Pod resource requests and scheduling failures
- **AWS Integration**: IRSA for secure AWS API access
- **Tags**: Auto-discovery via `k8s.io/cluster-autoscaler/enabled` and cluster name tags

### **VPC Configuration**

- **CIDR Block**: `10.0.0.0/16`
- **Availability Zones**: 2 AZs for high availability
- **Public Subnets**: 2 subnets for load balancers and NAT gateways
- **Private Subnets**: 2 subnets for EKS worker nodes

### **Storage Configuration**

- **EBS CSI Driver**: Latest version with OIDC authentication
- **Storage Class**: `gp2` (default)
- **Persistent Volumes**: Automatic provisioning for stateful apps
- **Monitoring Storage**: Prometheus (20Gi), Grafana (10Gi), AlertManager (5Gi)

### **Observability Stack Details**

#### Monitoring Stack

- **Prometheus**: Metrics collection with 15-day retention and persistent storage
- **Grafana**: Visualization dashboards with persistent storage (admin/admin123!)
- **AlertManager**: Alert routing and management (configure via UI)
- **Service Discovery**: Automatic metrics endpoint discovery

#### ELK Stack (Logging)

- **Elasticsearch**: 8.5.1 with 5GB persistent storage
- **Kibana**: 8.5.1 with LoadBalancer access
- **Fluent Bit**: DaemonSet for container log collection
- **Index Pattern**: `fluent-bit*` for log visualization

### **Secrets Management**

#### HashiCorp Vault

- **Version**: 0.31.0 (latest Helm chart)
- **Storage**: Persistent 5Gi storage
- **Access**: LoadBalancer for UI access
- **High Availability**: Single instance (can be scaled)
- **Integration**: Ready for application secret injection

### **Security & SSL Configuration**

#### Cert-Manager

- **Version**: v1.15.3 (OCI Helm chart)
- **Certificate Authority**: Let's Encrypt production
- **Email Notifications**: Configurable via variables
- **Challenge Method**: HTTP-01 validation
- **Auto-Renewal**: 60 days before expiration
- **ClusterIssuer**: `letsencrypt-prod` for production certificates

### **Database Management**

#### CloudNativePG

- **PostgreSQL Operator**: Latest version
- **High Availability**: Multi-instance cluster support
- **Backup Integration**: Built-in backup and recovery
- **Monitoring**: Prometheus metrics integration

### **GitOps**

#### ArgoCD

- **Version**: Latest stable release
- **Access**: LoadBalancer for UI and CLI access
- **Authentication**: Initial admin user with generated password
- **Repository Integration**: Git-based application deployment

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

#### Cluster Autoscaler Not Scaling

```bash
# Check cluster autoscaler pod status
kubectl get pods -n kube-system | grep cluster-autoscaler

# View autoscaler logs
kubectl logs -n kube-system deployment/cluster-autoscaler

# Check auto scaling group tags
aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[?contains(Tags[?Key==`k8s.io/cluster-autoscaler/enabled`].Value, `true`)].AutoScalingGroupName'

# Check pending pods that should trigger scaling
kubectl get pods --all-namespaces | grep Pending
```

#### Vault Authentication Issues

```bash
# Check Vault pod status
kubectl get pods -n vault

# Check Vault status
kubectl exec -n vault vault-0 -- vault status

# View Vault logs
kubectl logs -n vault vault-0

# If sealed, you need to unseal with your keys
kubectl exec -n vault vault-0 -- vault operator unseal <unseal-key>
```

#### Monitoring Alerts Not Working

```bash
# Check Grafana and AlertManager pods
kubectl get pods -n monitoring

# Access AlertManager to configure notifications
kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-alertmanager 9093:9093

# Check Prometheus targets
kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-prometheus 9090:9090
# Visit http://localhost:9090/targets
```

#### EBS CSI Driver Not Working

```bash
# Check EBS CSI driver pods
kubectl get pods -n kube-system | grep ebs

# Check storage classes
kubectl get storageclass

# Verify OIDC provider
aws eks describe-cluster --name production_eks --query 'cluster.identity.oidc.issuer'
```

#### Kibana Not Accessible

```bash
# Check Kibana pod logs
kubectl logs -n elastic-stack -l kibana.k8s.elastic.co/name=kibana

# Check service status
kubectl get service kibana-kb-http -n elastic-stack

# Check Elasticsearch cluster health
kubectl port-forward -n elastic-stack svc/elasticsearch-es-http 9200:9200
curl -X GET "localhost:9200/_cluster/health?pretty"
```

#### PostgreSQL Operator Issues

```bash
# Check CloudNativePG operator status
kubectl get pods -n cnpg-system

# View operator logs
kubectl logs -n cnpg-system -l app.kubernetes.io/name=cloudnative-pg

# Check PostgreSQL clusters
kubectl get clusters -A
```

### **Useful Commands**

```bash
# Get all pods across namespaces
kubectl get pods --all-namespaces

# Check all services with external access
kubectl get services --all-namespaces | grep LoadBalancer

# Monitor cluster autoscaler decisions
kubectl logs -n kube-system deployment/cluster-autoscaler -f

# Check node resource usage
kubectl top nodes
kubectl top pods --all-namespaces

# View all persistent volumes
kubectl get pv

# Check certificate status
kubectl get certificates -A

# Monitor Vault status
kubectl exec -n vault vault-0 -- vault status

# Check Terraform state
terraform state list

# View infrastructure outputs
terraform output
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
