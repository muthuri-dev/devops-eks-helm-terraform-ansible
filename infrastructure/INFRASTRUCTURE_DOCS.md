# Infrastructure Documentation

## 01-provider.tf

**Purpose:**  
Defines the required Terraform providers and configures AWS, Helm, Kubectl, Kubernetes, and TLS providers for the project.

**Key Details:**

- Specifies provider versions for AWS, Helm, Kubectl, Kubernetes, and TLS.
- Configures AWS provider with the region variable.
- Sets up Helm, Kubectl, and Kubernetes providers to authenticate with the EKS cluster using AWS CLI token authentication.

---

## 02-backend.tf

**Purpose:**  
Configures the Terraform backend to use an S3 bucket for storing the remote state.

**Key Details:**

- Uses S3 backend with bucket `devops-cluster-state-bucket` in region `us-east-1`.
- State file key is `terraform.tfstate`.

---

## 03-variables.tf

**Purpose:**  
Defines input variables for the Terraform configuration.

**Key Details:**

- `region`: AWS region (default: `us-east-1`).
- `vpc_cidr_block`: CIDR block for the VPC (default: `10.0.0.0/16`).
- `eks_cluster_name`: Name of the EKS cluster (default: `production_eks`).
- `letsencrypt_email`: Email for Let's Encrypt certificates.

---

## 04-vpc-networking.tf

**Purpose:**  
Creates the VPC, subnets, internet gateway, NAT gateway, and route tables for the AWS infrastructure.

**Key Details:**

- Defines a VPC with DNS support and hostnames enabled.
- Creates two public and two private subnets across available AZs.
- Sets up an internet gateway for public subnets and a NAT gateway for private subnets.
- Configures public and private route tables and associates them with the respective subnets.

---

## 05-eks-networking.tf

**Purpose:**  
Creates the IAM role and EKS cluster for Kubernetes workloads.

**Key Details:**

- Defines an IAM role for EKS with the necessary trust policy.
- Attaches the `AmazonEKSClusterPolicy` to the role.
- Provisions the EKS cluster with public and private endpoint access, using all subnets.
- Sets cluster version, access config, and tags.

---

## 06-ebs-csi.tf

**Purpose:**  
Sets up the EBS CSI driver for dynamic storage provisioning in EKS.

**Key Details:**

- Creates an IAM role for the EBS CSI driver with OIDC trust.
- Attaches the `AmazonEBSCSIDriverPolicy` to the role.
- Installs the EBS CSI driver as an EKS addon.
- Configures OIDC provider for service account authentication.

---

## 07-nodegroup.tf

**Purpose:**  
Provisions the EKS node group and its IAM role.

**Key Details:**

- Creates an IAM role for the node group and attaches required policies (`AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, `AmazonEC2ContainerRegistryReadOnly`).
- Provisions an EKS node group with specified instance types, scaling config, and subnet placement.

---

## 17-ingress-controller.tf

**Purpose:**  
Deploys the NGINX Ingress Controller using Helm.

**Key Details:**

- Uses the `ingress-nginx` Helm chart from the official repository.
- Installs into the `ingress-nginx` namespace (creates it if it doesn't exist).
- Sets the controller service type to `LoadBalancer` (exposes ingress to the internet).
- Depends on the EKS node group being available.

---

## 18-metrics-server.tf

**Purpose:**  
Deploys the Kubernetes Metrics Server for resource monitoring and HPA (Horizontal Pod Autoscaler) support.

**Key Details:**

- Uses the `metrics-server` Helm chart from the official repository.
- Installs into the `kube-system` namespace.
- Specifies chart version `3.12.1`.
- Depends on the EKS node group.

---

## 19-ec2-ansible.tf

**Purpose:**  
Provisions an EC2 instance to be used as an Ansible worker.

**Key Details:**

- Launches an EC2 instance with:
  - AMI: `ami-0c7217cdde317cfec`
  - Instance type: `t3.medium`
  - Public IP association enabled.
  - Placed in the first production public subnet.
  - Uses the SSH key named `key`.
  - Tagged as `ansible-worker`.
- Depends on the production VPC.

---

## cluster-autoscaler-deployment.yaml

**Purpose:**  
Deploys the Kubernetes Cluster Autoscaler and configures RBAC for it.

**Key Details:**

- **ServiceAccount:**
  - `cluster-autoscaler` in `kube-system` namespace.
  - Annotated with the IAM role ARN for EKS integration.
- **RBAC:**
  - ClusterRole and Role with permissions for autoscaler operations.
  - ClusterRoleBinding and RoleBinding to bind the ServiceAccount.
- **Deployment:**
  - Runs the `cluster-autoscaler` container (v1.30.0).
  - Configured with resource limits and security best practices.
  - Uses AWS as the cloud provider.
  - Auto-discovers node groups via ASG tags.
  - Mounts SSL certificates from the host.

---
