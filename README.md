# Production EKS Infrastructure with Terraform, Helm & GitOps

A production-ready Kubernetes infrastructure on Amazon EKS featuring comprehensive observability, automated CI/CD with GitOps, centralized logging, metrics monitoring, secrets management, and SSL certificate automation.

<img width="2362" height="1507" alt="Image" src="https://github.com/user-attachments/assets/9d50db51-4317-4cf5-b381-a8ae79d19591" />

## 🏗️ Architecture Overview

### High-Level Infrastructure Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                  AWS Cloud                                       │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                            VPC (10.0.0.0/16)                                │ │
│  │                                                                             │ │
│  │  ┌──────────────────┐                          ┌──────────────────┐         │ │
│  │  │  Public Subnet   │                          │  Public Subnet   │         │ │
│  │  │  (us-east-1a)    │                          │  (us-east-1b)    │         │ │
│  │  │                  │                          │                  │         │ │
│  │  │  ┌─────────────┐ │                          │ ┌──────────────┐ │         │ │
│  │  │  │ NAT Gateway │ │                          │ │NGINX Ingress │ │         │ │
│  │  │  │             │ │                          │ │  Controller  │ │         │ │
│  │  │  └─────────────┘ │                          │ │  (LoadBalancer)          │ │
│  │  └──────────────────┘                          │ └──────────────┘ │         │ │
│  │           │                                     └──────────────────┘        │ │
│  │           │                                              │                  │ │
│  │  ┌──────────────────┐                          ┌──────────────────┐         │ │
│  │  │ Private Subnet   │                          │ Private Subnet   │         │ │
│  │  │  (us-east-1a)    │                          │  (us-east-1b)    │         │ │
│  │  │                  │                          │                  │         │ │
│  │  │ ┌──────────────┐ │                          │ ┌──────────────┐ │         │ │
│  │  │ │ EKS Workers  │ │                          │ │ EKS Workers  │ │         │ │
│  │  │ │ (Auto-Scale) │ │                          │ │ (Auto-Scale) │ │         │ │
│  │  │ │              │ │                          │ │              │ │         │ │
│  │  │ │ ┌──────────┐ │ │                          │ │ ┌──────────┐ │ │         │ │
│  │  │ │ │ArgoCD    │ │ │                          │ │ │Prometheus│ │ │         │ │
│  │  │ │ │Vault     │ │ │                          │ │ │Grafana   │ │ │         │ │
│  │  │ │ │Kibana    │ │ │                          │ │ │Apps      │ │ │         │ │
│  │  │ │ │PostgreSQL│ │ │                          │ │ │Fluent Bit│ │ │         │ │
│  │  │ │ └──────────┘ │ │                          │ │ └──────────┘ │ │         │ │
│  │  │ └──────────────┘ │                          │ └──────────────┘ │         │ │
│  │  └──────────────────┘                          └──────────────────┘         │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                          Amazon ECR (Container Registry)                    │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│                              GitHub Repository                                   │
│  ┌────────────────────┐              ┌──────────────────────┐                   │
│  │ Application Code   │              │   Helm Charts        │                   │
│  │  (Dev/Main Branch) │              │  (values.yaml)       │                   │
│  └────────────────────┘              └──────────────────────┘                   │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Traffic Flow Architecture

```
                                    Internet User
                                         │
                                         │ HTTPS Request
                                         │ (*.shipcodes.tech)
                                         ▼
                              ┌──────────────────────┐
                              │   Route 53 / DNS     │
                              │  (Domain Resolution) │
                              └──────────────────────┘
                                         │
                                         │
                                         ▼
                              ┌──────────────────────┐
                              │   AWS Load Balancer  │
                              │  (Created by NGINX)  │
                              └──────────────────────┘
                                         │
                                         │
                    ┌────────────────────┼────────────────────┐
                    │                    │                    │
                    ▼                    ▼                    ▼
         ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
         │  EKS Worker Node │ │  EKS Worker Node │ │  EKS Worker Node │
         │                  │ │                  │ │                  │
         │ ┌──────────────┐ │ │ ┌──────────────┐ │ │ ┌──────────────┐ │
         │ │NGINX Ingress │ │ │ │NGINX Ingress │ │ │ │NGINX Ingress │ │
         │ │  Controller  │ │ │ │  Controller  │ │ │ │  Controller  │ │
         │ │   (DaemonSet)│ │ │ │   (DaemonSet)│ │ │ │   (DaemonSet)│ │
         │ └──────────────┘ │ │ └──────────────┘ │ │ └──────────────┘ │
         └──────────────────┘ └──────────────────┘ └──────────────────┘
                    │                    │                    │
                    │ SSL Termination    │                    │
                    │ (Let's Encrypt)    │                    │
                    └────────────────────┼────────────────────┘
                                         │
                              ┌──────────▼──────────┐
                              │  Ingress Resources  │
                              │  (Route by Domain)  │
                              └─────────────────────┘
                                         │
              ┌──────────────────────────┼──────────────────────────┐
              │                          │                          │
              ▼                          ▼                          ▼
    ┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
    │ ArgoCD Service   │      │ Grafana Service  │      │  Vault Service   │
    │ (ClusterIP)      │      │ (ClusterIP)      │      │  (ClusterIP)     │
    └──────────────────┘      └──────────────────┘
              │                          │                          │
              ▼                          ▼                          ▼
    ┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
    │  ArgoCD Pods     │      │  Grafana Pods    │      │   Vault Pods     │
    │  (Deployment)    │      │  (StatefulSet)   │      │  (StatefulSet)   │
    └──────────────────┘      └──────────────────┘      └──────────────────┘
```

### Request/Response Flow Detail

```
1. User Request:
   https://argocd.shipcodes.tech
          │
          ▼
2. DNS Resolution:
   Cloudflare → AWS Load Balancer IP
          │
          ▼
3. Load Balancer:
   Distributes to NGINX Ingress on any worker node
          │
          ▼
4. NGINX Ingress Controller:
   - Reads Ingress resource
   - Checks host: argocd.shipcodes.tech
   - Terminates SSL (Let's Encrypt cert)
   - Routes to backend service
          │
          ▼
5. Kubernetes Service:
   argocd-server (ClusterIP) on port 80
          │
          ▼
6. Pod Selection:
   Service selects healthy ArgoCD pod via label selector
          │
          ▼
7. ArgoCD Pod:
   Processes request and generates response
          │
          ▼
8. Response Path (Reverse):
   Pod → Service → Ingress → Load Balancer → User
```

## 🎯 Complete Infrastructure Components

### ✅ Core Kubernetes Infrastructure

- **Amazon EKS Cluster**: Managed Kubernetes control plane
- **EKS Node Groups**: Auto-scaling worker nodes (2-12 nodes)
- **Cluster Autoscaler**: Automatic node scaling based on pod demand
- **VPC & Networking**: Production-grade multi-AZ setup
- **EBS CSI Driver**: Persistent storage with dynamic provisioning
- **Metrics Server**: Resource metrics for HPA and monitoring

### ✅ Ingress & Networking

- **NGINX Ingress Controller**: Centralized ingress with SSL termination
- **Cert-Manager**: Automatic SSL certificate provisioning via Let's Encrypt
- **DNS Integration**: Domain-based routing (\*.shipcodes.tech)
- **Load Balancer**: AWS NLB/ALB for external traffic

### ✅ Observability Stack

#### Logging (EFK Stack)

- **Elasticsearch**: Centralized log storage and indexing
- **Fluent Bit**: Lightweight log collector (DaemonSet on all nodes)
- **Kibana**: Log visualization and analysis dashboard

#### Monitoring

- **Prometheus**: Metrics collection and storage
- **Grafana**: Metrics visualization and alerting
- **Service Discovery**: Automatic scraping of Kubernetes metrics

### ✅ GitOps & CI/CD

- **ArgoCD**: GitOps continuous deployment
- **GitHub Actions**: CI pipeline for build and push
- **Helm Charts**: Application packaging and versioning

### ✅ Secrets & Database

- **HashiCorp Vault**: Centralized secrets management
- **CloudNativePG**: PostgreSQL operator for database workloads
- **Amazon ECR**: Private container registry

## 📁 Project Structure

```
devops-eks-infrastructure/
├── infrastructure/                    # Terraform IaC
│   ├── 01-provider.tf                # Provider configuration
│   ├── 02-backend.tf                 # S3 backend with state
│   ├── 03-variables.tf               # Variable definitions
│   ├── 04-vpc-networking.tf          # VPC, subnets, NAT
│   ├── 05-eks-cluster.tf             # EKS cluster
│   ├── 06-ebs-csi.tf                 # EBS CSI driver
│   ├── 07-nodegroup.tf               # Auto-scaling node groups
│   ├── 08-monitoring.tf              # Prometheus & Grafana
│   ├── 09-argocd.tf                  # ArgoCD with Ingress
│   ├── 10-logging.tf                 # EFK stack
│   ├── 11-nginx-ingress.tf           # NGINX Ingress Controller
│   ├── 12-cert-manager.tf            # Cert-Manager
│   ├── 13-vault.tf                   # Vault with Ingress
│   ├── 14-ecr.tf                     # Amazon ECR
│   ├── 15-cloudnative-pg.tf          # PostgreSQL operator
│   ├── 16-cluster-autoscaler.tf      # Cluster autoscaler
│   ├── 17-metrics-server.tf          # Metrics server
│   └── 18-outputs.tf                 # Infrastructure outputs
├── helm-charts/                      # Application Helm charts
│   └── myapp/
│       ├── Chart.yaml
│       ├── values.yaml               # Updated by CI/CD
│       └── templates/
├── application/                      # Application source code
│   ├── src/
│   ├── Dockerfile
│   └── requirements.txt
├── .github/
│   └── workflows/
│       └── deploy.yml               # GitHub Actions workflow
└── README.md
```

## 🔄 Complete CI/CD Pipeline Flow

### Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           Developer Workflow                                    │
└─────────────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
                              ┌──────────────────────┐
                              │  1. Developer Push   │
                              │  to 'dev' branch     │
                              └──────────────────────┘
                                         │
                                         ▼
                              ┌──────────────────────┐
                              │  2. Create PR        │
                              │  dev → main          │
                              └──────────────────────┘
                                         │
                                         ▼
                              ┌──────────────────────┐
                              │  3. Code Review &    │
                              │  Merge to main       │
                              └──────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         GitHub Actions Workflow                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  Step 1: Checkout Code                                                          │
│  ├─ actions/checkout@v3                                                         │
│  └─ Fetches repository code                                                     │
│                                                                                 │
│  Step 2: Authenticate with Vault                                                │
│  ├─ Connect to Vault (vault.shipcodes.tech)                                     │
│  ├─ Retrieve AWS credentials                                                    │
│  └─ Get ECR registry details                                                    │
│                │                                                                │
│                ▼                                                                │
│         ┌────────────┐                                                          │
│         │   Vault    │                                                          │
│         │  Secrets:  │                                                          │
│         │  - AWS_KEY │                                                          │
│         │  - AWS_SEC │                                                          │
│         │  - ECR_URI │                                                          │
│         └────────────┘                                                          │
│                │                                                                │
│  Step 3: Build Docker Image                                                     │
│  ├─ docker build -t myapp:$GITHUB_SHA                                           │
│  └─ Tag with commit SHA for versioning                                          │
│                                                                                 │
│  Step 4: Push to Amazon ECR                                                     │
│  ├─ aws ecr get-login-password                                                  │
│  ├─ docker tag myapp:$SHA $ECR_URI/myapp:$SHA                                   │
│  └─ docker push $ECR_URI/myapp:$SHA                                             │
│                │                                                                │
│                ▼                                                                │
│         ┌────────────┐                                                          │
│         │ Amazon ECR │                                                          │
│         │   Image:   │                                                          │
│         │ myapp:abc1 │                                                          │
│         └────────────┘                                                          │
│                │                                                                │
│  Step 5: Update Helm Chart                                                      │
│  ├─ Checkout helm-charts repository                                             │
│  ├─ Update values.yaml with new image tag                                       │
│  │  image:                                                                      │
│  │    repository: $ECR_URI/myapp                                                │
│  │    tag: abc123def456  # New commit SHA                                       │
│  ├─ git commit -m "Update image to abc123"                                      │
│  └─ git push to helm-charts repo                                                │
│                                                                                 |
└─────────────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           ArgoCD GitOps Sync                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  Step 1: Detect Changes                                                         │
│  ├─ ArgoCD monitors helm-charts repository                                      │
│  ├─ Detects values.yaml change                                                  │
│  └─ Triggers sync (auto or manual)                                              │
│                                                                                 │
│  Step 2: Sync Application                                                       │
│  ├─ Renders Helm chart with new values                                          │
│  ├─ Compares with cluster state                                                 │
│  └─ Applies changes to EKS cluster                                              │
│                                                                                 │
│  Step 3: Rolling Update                                                         │
│  ├─ Kubernetes Deployment rollout                                               │
│  ├─ Pull new image from ECR                                                     │
│  ├─ Create new pods with new image                                              │
│  ├─ Wait for health checks                                                      │
│  └─ Terminate old pods                                                          │
│                                                                                 │
│  Step 4: Health Verification                                                    │
│  ├─ Check pod readiness probes                                                  │
│  ├─ Verify service endpoints                                                    │
│  └─ Application accessible via ingress                                          │
│                                                                                 |
└─────────────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
                              ┌──────────────────────┐
                              │  Application Live!   │
                              │  https://api         │
                              │  .shipcodes.tech     │
                              └──────────────────────┘
```

## 📊 EFK Stack Architecture (Logging)

### EFK Stack Components

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            EFK Logging Stack                                     │
└─────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│  EKS Node 1      │  │  EKS Node 2      │  │  EKS Node 3      │
│                  │  │                  │  │                  │
│ ┌──────────────┐ │  │ ┌──────────────┐ │  │ ┌──────────────┐ │
│ │ Fluent Bit   │ │  │ │ Fluent Bit   │ │  │ │ Fluent Bit   │ │
│ │ (DaemonSet)  │ │  │ │ (DaemonSet)  │ │  │ │ (DaemonSet)  │ │
│ └──────┬───────┘ │  │ └──────┬───────┘ │  │ └──────┬───────┘ │
│        │         │  │        │         │  │        │         │
│ ┌──────▼───────┐ │  │ ┌──────▼───────┐ │  │ ┌──────▼───────┐ │
│ │  App Pod 1   │ │  │ │  App Pod 3   │ │  │ │  App Pod 5   │ │
│ │  logs/*.log  │ │  │ │  logs/*.log  │ │  │ │  logs/*.log  │ │
│ └──────────────┘ │  │ └──────────────┘ │  │ └──────────────┘ │
│ ┌──────────────┐ │  │ ┌──────────────┐ │  │ ┌──────────────┐ │
│ │  App Pod 2   │ │  │ │  App Pod 4   │ │  │ │  App Pod 6   │ │
│ │  logs/*.log  │ │  │ │  logs/*.log  │ │  │ │  logs/*.log  │ │
│ └──────────────┘ │  │ └──────────────┘ │  │ └──────────────┘ │
└────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘
         │                     │                     │
         │  Parse & Forward    │                     │
         └─────────────────────┼─────────────────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   Elasticsearch     │
                    │   (StatefulSet)     │
                    │                     │
                    │  • Index: fluent-*  │
                    │  • Storage: 5GB     │
                    │  • Replicas: 1      │
                    └─────────────────────┘
                               │
                               │ Query & Visualize
                               ▼
                    ┌─────────────────────┐
                    │      Kibana         │
                    │   (Deployment)      │
                    │                     │
                    │  kibana.shipcodes   │
                    │       .tech         │
                    └─────────────────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   NGINX Ingress     │
                    │   (SSL Enabled)     │
                    └─────────────────────┘
```

### Fluent Bit Log Collection Process

```
1. Fluent Bit DaemonSet:
   - Deployed on EVERY node in the cluster
   - Runs as privileged pod with host access
   - Mounts /var/log/containers from host

2. Log Collection:
   - Reads container logs: /var/log/containers/*.log
   - Parses JSON format from container runtime
   - Extracts metadata: pod, namespace, container name

3. Log Processing:
   - Filters: Remove system logs if needed
   - Parsers: JSON, regex for custom formats
   - Enrichment: Add Kubernetes metadata

4. Log Forwarding:
   - Protocol: HTTP/HTTPS
   - Destination: Elasticsearch service
   - Index: kubernetes-
   - Buffering: Local disk for reliability

5. Elasticsearch Storage:
   - Creates daily indices
   - Applies mapping for log fields
   - Stores with retention policy
```

### Kibana Log Visualization Setup

1. Access Kibana at `https://kibana.shipcodes.tech`
2. Navigate to **Management** → **Index Patterns**
3. Create index pattern: `kubernetes*`
4. Select time field: `@timestamp`
5. Go to **Discover** to view logs
6. Create visualizations and dashboards

## 📈 Prometheus & Grafana Monitoring

### Monitoring Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Prometheus Monitoring Stack                               │
└─────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────────┐
│                            Metrics Sources                                       │
├──────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │ Node Exporter│  │kube-state   │  │  cAdvisor   │  │   Custom    │            │
│  │             │  │  -metrics   │  │             │  │ App Metrics │            │
│  │ :9100/metrics  │ :8080/metrics  │ :10250/metrics │ :8080/metrics            │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘            │
│         │                 │                 │                 │                 │
│         │                 │                 │                 │                 │
│         └─────────────────┴─────────────────┴─────────────────┘                 │
│                                     │                                           │
│                           Service Discovery                                     │
│                      (Kubernetes API Integration)                               │
└──────────────────────────────────────┬───────────────────────────────────────────┘
                                       │
                                       │ Scrape every 30s
                                       ▼
                            ┌─────────────────────┐
                            │    Prometheus       │
                            │   (StatefulSet)     │
                            │                     │
                            │  • TSDB Storage     │
                            │  • Retention: 15d   │
                            │  • PVC: 20GB        │
                            │  • HA: Replicas     │
                            └─────────────────────┘
                                       │
                                       │ PromQL Queries
                                       ▼
                            ┌─────────────────────┐
                            │      Grafana        │
                            │   (StatefulSet)     │
                            │                     │
                            │  grafana.shipcodes  │
                            │       .tech         │
                            │                     │
                            │  • Dashboards       │
                            │  • Alerts           │
                            │  • PVC: 10GB        │
                            └─────────────────────┘
                                       │
                                       ▼
                            ┌─────────────────────┐
                            │   NGINX Ingress     │
                            │   (SSL Enabled)     │
                            └─────────────────────┘
```

### Key Metrics Collected

**Node Metrics (Node Exporter)**

- CPU usage per core
- Memory usage and available
- Disk I/O and space
- Network traffic

**Cluster Metrics (kube-state-metrics)**

- Pod status and restarts
- Deployment replicas
- Node status
- Resource requests/limits

**Container Metrics (cAdvisor)**

- Container CPU usage
- Container memory usage
- Container network I/O
- Container filesystem usage

### Grafana Dashboard Access

1. Access Grafana at `https://grafana.shipcodes.tech`
2. Login with configured credentials
3. Pre-configured dashboards:
   - **Kubernetes Cluster Monitoring**: Overall cluster health
   - **Node Exporter Full**: Detailed node metrics
   - **Pod Monitoring**: Per-pod resource usage
   - **Namespace Monitoring**: Resource usage by namespace

## 🔐 Security & Secrets Management

### Vault Integration

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ Vault Secrets Management │
└─────────────────────────────────────────────────────────────────────────────────┘

                            ┌─────────────────────┐
                            │   HashiCorp Vault   │
                            │   (StatefulSet)     │
                            │                     │
                            │  vault.shipcodes    │
                            │       .tech         │
                            └─────────────────────┘
                                       │
                    ┌──────────────────┼──────────────────┐
                    │                  │                  │
                    ▼                  ▼                  ▼
         ┌──────────────────┐ ┌──────────────┐ ┌──────────────────┐
         │ GitHub Actions   │ │ Application  │ │   Operators      │
         │                  │ │   Pods       │ │                  │
         │ • AWS Creds      │ │ • DB Creds   │ │ • API Keys       │
         │ • ECR Access     │ │ • API Keys   │ │ • Certificates   │
         │ • Deploy Keys    │ │ • Configs    │ │ • Tokens         │
         └──────────────────┘ └──────────────┘ └──────────────────┘
```

## SSL Certificate Management

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    Cert-Manager Certificate Flow                                 │
└─────────────────────────────────────────────────────────────────────────────────┘

                              ┌──────────────────────┐
                              │  Kubernetes Ingress  │
                              │  Created with TLS    │
                              │                      │
                              │  annotations:        │
                              │   cert-manager.io/   │
                              │   cluster-issuer:    │
                              │   letsencrypt-prod   │
                              └──────────────────────┘
                                         │
                                         │ Triggers
                                         ▼
                              ┌──────────────────────┐
                              │   Cert-Manager       │
                              │   (Deployment)       │
                              └──────────────────────┘
                                         │
                                         │ Creates
                                         ▼
                              ┌──────────────────────┐
                              │  Certificate Object  │
                              │  (CRD)               │
                              └──────────────────────┘
                                         │
                                         │ ACME Challenge
                                         ▼
                              ┌──────────────────────┐
                              │   Let's Encrypt CA   │
                              │   (HTTP-01)          │
                              └──────────────────────┘
                                         │
                                         │ Validates domain
                                         │ Issues certificate
                                         ▼
                              ┌──────────────────────┐
                              │  Kubernetes Secret   │
                              │  (TLS Certificate)   │
                              │                      │
                              │  - tls.crt           │
                              │  - tls.key           │
                              └──────────────────────┘
                                         │
                                         │ Mounted by
                                         ▼
                              ┌──────────────────────┐
                              │  NGINX Ingress       │
                              │  (SSL Termination)   │
                              └──────────────────────┘
```

## 🚀 Getting Started

Prerequisites
Install required tools:

```
# Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
```

# AWS CLI

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# kubectl

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Helm

```
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
AWS Configuration
bash# Configure AWS credentials
aws configure

# AWS Access Key ID: YOUR_ACCESS_KEY

# AWS Secret Access Key: YOUR_SECRET_KEY

# Default region: us-east-1

# Default output format: json

# Verify configuration
```

aws sts get-caller-identity

## 🏗️ Infrastructure Deployment

### Step 1: Initialize Terraform

```
cd infrastructure/
```

### Initialize Terraform with backend

```
terraform init
```

### Validate configuration

```
terraform validate
```

### Format configuration files

```
terraform fmt
```

### Step 2: Plan Infrastructure

```
# Review planned changes
terraform plan
```

# Save plan to file (optional)

```
terraform plan
```

### Step 3: Deploy Infrastructure

```
# Apply configuration
terraform apply
```

# Or apply saved plan

terraform apply
Deployment creates:

✅ EKS cluster with control plane

✅ VPC with public/private subnets

✅ NAT Gateway for private subnet internet access

✅ Auto-scaling node groups (2-12 nodes)

✅ NGINX Ingress Controller with LoadBalancer

✅ Cert-Manager with Let's Encrypt integration

✅ Prometheus & Grafana with persistent storage

✅ Elasticsearch, Kibana, and Fluent Bit

✅ ArgoCD with GitOps configuration

✅ HashiCorp Vault for secrets

✅ CloudNativePG PostgreSQL operator

✅ Amazon ECR repository

✅ Cluster Autoscaler

✅ Metrics Server

### Step 4: Configure kubectl

```
bash# Update kubeconfig for EKS cluster
aws eks update-kubeconfig --region us-east-1 --name production_eks
```

# Verify cluster access

```
kubectl cluster-info
```

# Check all nodes are ready

```
kubectl get nodes
```

# View all pods across namespaces

```
kubectl get pods --all-namespaces
🌐 Accessing Services
Get Service URLs
bash# Get all ingress URLs
kubectl get ingress --all-namespaces


# Expected output:

# NAMESPACE NAME HOSTS ADDRESS

# argocd argocd-ingress argocd.shipcodes.tech <LoadBalancer-DNS>

# monitoring grafana-ingress grafana.shipcodes.tech <LoadBalancer-DNS>

# elastic-stack kibana-ingress kibana.shipcodes.tech <LoadBalancer-DNS>

# vault vault-ingress vault.shipcodes.tech <LoadBalancer-DNS>
```

Configure DNS Records
For each service, create DNS A/CNAME records pointing to the LoadBalancer:
bash# Get LoadBalancer DNS
kubectl get service -n ingress-nginx ingress-nginx-controller

Create DNS records in Route 53 or your DNS provider like cloudflare:

argocd.shipcodes.tech → LoadBalancer DNS
grafana.shipcodes.tech → LoadBalancer DNS
kibana.shipcodes.tech → LoadBalancer DNS
vault.shipcodes.tech → LoadBalancer DNS

## 📦 Deploying Applications

Application Deployment Flow

```
Developer → GitHub (dev) → PR → Merge (main) → GitHub Actions
↓
┌───────────┴────────────┐
│ │
Vault Secrets Build Image
│ │
└───────────┬────────────┘
↓
Push to ECR
↓
Update Helm Chart (values.yaml)
↓
ArgoCD Detects
↓
Sync to EKS Cluster
↓
Application Deployed
↓
Accessible via Ingress
Create Application Helm Chart
```

## 📝 Best Practices

Security

Rotate Secrets Regularly: Update credentials in Vault periodically
Use RBAC: Implement least-privilege access controls
Enable Pod Security: Use Pod Security Standards
Network Policies: Restrict pod-to-pod communication
Image Scanning: Enable ECR image scanning
Audit Logging: Enable EKS control plane logging
