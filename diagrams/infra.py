#!/usr/bin/env python3
"""
EKS Infrastructure Diagrams Generator
Generates visual infrastructure diagrams as PNG files
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EKS, EC2, AutoScaling
from diagrams.aws.network import VPC, PublicSubnet, PrivateSubnet, NATGateway, ELB, Route53
from diagrams.aws.storage import S3
from diagrams.aws.database import RDS
from diagrams.aws.security import IAM, SecretsManager
from diagrams.k8s.compute import Pod, Deployment, StatefulSet, DaemonSet
from diagrams.k8s.network import Service, Ingress
from diagrams.k8s.storage import PV, PVC, StorageClass
from diagrams.k8s.rbac import ServiceAccount
from diagrams.onprem.gitops import Argocd
from diagrams.onprem.monitoring import Prometheus, Grafana
from diagrams.onprem.logging import Fluentbit
from diagrams.elastic.elasticsearch import Elasticsearch, Kibana
from diagrams.onprem.vcs import Github
from diagrams.onprem.ci import GithubActions
from diagrams.onprem.container import Docker
from diagrams.programming.framework import React
from diagrams.generic.database import SQL
from diagrams.custom import Custom
import os

# Create output directory
os.makedirs("output", exist_ok=True)

# ============================================================================
# DIAGRAM 1: High-Level Infrastructure Architecture
# ============================================================================
def create_high_level_architecture():
    with Diagram(
        "High-Level EKS Infrastructure",
        filename="output/01_high_level_architecture",
        show=False,
        direction="TB",
        graph_attr={
            "fontsize": "20",
            "bgcolor": "white",
            "pad": "0.5",
        }
    ):
        users = React("Internet Users")
        github = Github("GitHub Repository")
        
        with Cluster("AWS Cloud"):
            route53 = Route53("Route 53 DNS")
            
            with Cluster("VPC (10.0.0.0/16)"):
                with Cluster("Availability Zone 1"):
                    public_subnet_1 = PublicSubnet("Public Subnet")
                    nat_1 = NATGateway("NAT Gateway")
                    private_subnet_1 = PrivateSubnet("Private Subnet")
                    
                    with Cluster("EKS Worker Node 1"):
                        argocd_pod = Pod("ArgoCD")
                        vault_pod = Pod("Vault")
                        kibana_pod = Pod("Kibana")
                
                with Cluster("Availability Zone 2"):
                    public_subnet_2 = PublicSubnet("Public Subnet")
                    elb = ELB("Load Balancer")
                    private_subnet_2 = PrivateSubnet("Private Subnet")
                    
                    with Cluster("EKS Worker Node 2"):
                        prometheus_pod = Pod("Prometheus")
                        grafana_pod = Pod("Grafana")
                        app_pod = Pod("Applications")
                
                eks = EKS("EKS Cluster")
                
                public_subnet_1 >> nat_1 >> private_subnet_1
                public_subnet_2 >> elb
            
            ecr = S3("Amazon ECR")
        
        users >> route53 >> elb
        github >> ecr
        ecr >> Edge(label="Pull Images") >> eks

# ============================================================================
# DIAGRAM 2: Complete Traffic Flow
# ============================================================================
def create_traffic_flow():
    with Diagram(
        "Traffic Flow - User to Pod",
        filename="output/02_traffic_flow",
        show=False,
        direction="TB"
    ):
        user = React("User Browser")
        
        with Cluster("AWS"):
            dns = Route53("DNS Resolution")
            lb = ELB("Load Balancer")
            
            with Cluster("EKS Cluster"):
                with Cluster("Ingress Layer"):
                    ingress_1 = Pod("NGINX Ingress 1")
                    ingress_2 = Pod("NGINX Ingress 2")
                    ingress_3 = Pod("NGINX Ingress 3")
                
                ingress_resource = Ingress("Ingress Resources")
                
                with Cluster("Services"):
                    argocd_svc = Service("ArgoCD Service")
                    grafana_svc = Service("Grafana Service")
                    vault_svc = Service("Vault Service")
                
                with Cluster("Pods"):
                    argocd_pod_1 = Pod("ArgoCD Pod 1")
                    argocd_pod_2 = Pod("ArgoCD Pod 2")
                    grafana_pod = Pod("Grafana Pod")
                    vault_pod = Pod("Vault Pod")
        
        user >> Edge(label="1. HTTPS Request") >> dns
        dns >> Edge(label="2. Resolve IP") >> lb
        lb >> Edge(label="3. Forward") >> [ingress_1, ingress_2, ingress_3]
        
        ingress_1 >> Edge(label="4. Route by domain") >> ingress_resource
        ingress_resource >> [argocd_svc, grafana_svc, vault_svc]
        
        argocd_svc >> [argocd_pod_1, argocd_pod_2]
        grafana_svc >> grafana_pod
        vault_svc >> vault_pod

# ============================================================================
# DIAGRAM 3: CI/CD Pipeline
# ============================================================================
def create_cicd_pipeline():
    with Diagram(
        "CI/CD Pipeline - GitOps Flow",
        filename="output/03_cicd_pipeline",
        show=False,
        direction="LR"
    ):
        with Cluster("Developer Workflow"):
            dev_code = Github("Dev Branch")
            pr = Github("Pull Request")
            main = Github("Main Branch")
        
        with Cluster("GitHub Actions"):
            workflow = GithubActions("Workflow")
            
            with Cluster("Build Process"):
                build = Docker("Build Image")
                vault = SecretsManager("Get Secrets from Vault")
        
        with Cluster("AWS"):
            ecr = S3("Amazon ECR")
        
        with Cluster("Helm Charts"):
            helm_repo = Github("Helm Repository")
            values = Github("values.yaml")
        
        with Cluster("ArgoCD"):
            argocd = Argocd("ArgoCD Server")
            sync = Argocd("Sync Engine")
        
        with Cluster("Kubernetes"):
            deployment = Deployment("Deployment")
            pods = Pod("New Pods")
        
        dev_code >> pr >> main >> workflow
        workflow >> vault >> build
        build >> Edge(label="Push Image") >> ecr
        workflow >> Edge(label="Update tag") >> values
        values >> helm_repo
        helm_repo >> Edge(label="Detect changes") >> argocd
        argocd >> sync >> deployment >> pods

# ============================================================================
# DIAGRAM 4: EFK Stack
# ============================================================================
def create_efk_stack():
    with Diagram(
        "EFK Logging Stack",
        filename="output/04_efk_stack",
        show=False,
        direction="TB"
    ):
        with Cluster("Kubernetes Cluster"):
            with Cluster("Worker Node 1"):
                fb_1 = Fluentbit("Fluent Bit DS")
                app_1 = Pod("App Pod 1")
                app_2 = Pod("App Pod 2")
            
            with Cluster("Worker Node 2"):
                fb_2 = Fluentbit("Fluent Bit DS")
                app_3 = Pod("App Pod 3")
                app_4 = Pod("App Pod 4")
            
            with Cluster("Worker Node 3"):
                fb_3 = Fluentbit("Fluent Bit DS")
                app_5 = Pod("App Pod 5")
                app_6 = Pod("App Pod 6")
            
            with Cluster("Storage"):
                es = Elasticsearch("Elasticsearch")
            
            with Cluster("Visualization"):
                kibana = Kibana("Kibana Dashboard")
        
        [app_1, app_2] >> fb_1
        [app_3, app_4] >> fb_2
        [app_5, app_6] >> fb_3
        
        [fb_1, fb_2, fb_3] >> Edge(label="Forward logs") >> es
        es >> Edge(label="Query") >> kibana

# ============================================================================
# DIAGRAM 5: Prometheus & Grafana Monitoring
# ============================================================================
def create_monitoring_stack():
    with Diagram(
        "Prometheus & Grafana Monitoring",
        filename="output/05_monitoring_stack",
        show=False,
        direction="TB"
    ):
        with Cluster("Metrics Sources"):
            node_exporter = Pod("Node Exporter")
            kube_state = Pod("kube-state-metrics")
            cadvisor = Pod("cAdvisor")
            app_metrics = Pod("App Metrics")
        
        with Cluster("Prometheus"):
            prom_server = Prometheus("Prometheus Server")
            pvc = PVC("20GB Storage")
        
        with Cluster("Visualization"):
            grafana = Grafana("Grafana")
            grafana_pvc = PVC("10GB Storage")
        
        [node_exporter, kube_state, cadvisor, app_metrics] >> \
            Edge(label="Scrape every 30s") >> prom_server
        
        prom_server >> pvc
        prom_server >> Edge(label="PromQL queries") >> grafana
        grafana >> grafana_pvc

# ============================================================================
# DIAGRAM 6: Vault Secrets Management
# ============================================================================
def create_vault_architecture():
    with Diagram(
        "Vault Secrets Management",
        filename="output/06_vault_secrets",
        show=False,
        direction="TB"
    ):
        with Cluster("HashiCorp Vault"):
            vault = SecretsManager("Vault Server")
            vault_pvc = PVC("5GB Storage")
            
            with Cluster("Secrets"):
                aws_creds = IAM("AWS Credentials")
                ecr_creds = IAM("ECR Details")
                db_creds = SQL("DB Credentials")
                api_keys = IAM("API Keys")
        
        with Cluster("Consumers"):
            github_actions = GithubActions("GitHub Actions")
            app_pods = Pod("Application Pods")
            operators = Pod("Operators")
        
        vault >> [aws_creds, ecr_creds, db_creds, api_keys]
        vault >> vault_pvc
        
        aws_creds >> Edge(label="Read") >> github_actions
        ecr_creds >> Edge(label="Read") >> github_actions
        db_creds >> Edge(label="Inject") >> app_pods
        api_keys >> Edge(label="Sync") >> operators

# ============================================================================
# DIAGRAM 7: ArgoCD GitOps
# ============================================================================
def create_argocd_gitops():
    with Diagram(
        "ArgoCD GitOps Workflow",
        filename="output/07_argocd_gitops",
        show=False,
        direction="LR"
    ):
        with Cluster("Git Repositories"):
            helm_repo = Github("Helm Charts")
            app_repo = Github("Application Code")
        
        with Cluster("ArgoCD"):
            argocd_server = Argocd("ArgoCD Server")
            argocd_controller = Argocd("Application Controller")
            repo_server = Argocd("Repository Server")
        
        with Cluster("Kubernetes"):
            desired_state = Deployment("Desired State")
            actual_state = Deployment("Actual State")
            resources = Pod("K8s Resources")
        
        helm_repo >> Edge(label="Poll every 3m") >> argocd_controller
        argocd_controller >> repo_server
        repo_server >> Edge(label="Render") >> desired_state
        argocd_controller >> Edge(label="Compare") >> [desired_state, actual_state]
        argocd_controller >> Edge(label="Sync") >> resources
        resources >> actual_state

# ============================================================================
# DIAGRAM 8: Database Management (CloudNativePG)
# ============================================================================
def create_database_architecture():
    with Diagram(
        "CloudNativePG PostgreSQL",
        filename="output/08_database_architecture",
        show=False,
        direction="TB"
    ):
        with Cluster("CloudNativePG"):
            operator = Pod("PostgreSQL Operator")
        
        with Cluster("PostgreSQL Cluster"):
            primary = StatefulSet("Primary Instance")
            replica_1 = StatefulSet("Replica 1")
            replica_2 = StatefulSet("Replica 2")
            
            primary_pvc = PVC("10GB")
            replica_1_pvc = PVC("10GB")
            replica_2_pvc = PVC("10GB")
        
        with Cluster("Services"):
            rw_svc = Service("Read-Write Service")
            ro_svc = Service("Read-Only Service")
        
        with Cluster("Backup"):
            s3 = S3("S3 Backup")
        
        with Cluster("Applications"):
            write_app = Pod("Write App")
            read_app = Pod("Read App")
        
        operator >> [primary, replica_1, replica_2]
        primary >> Edge(label="Stream WAL") >> [replica_1, replica_2]
        
        primary >> primary_pvc
        replica_1 >> replica_1_pvc
        replica_2 >> replica_2_pvc
        
        rw_svc >> primary
        ro_svc >> [replica_1, replica_2]
        
        primary >> Edge(label="Backup") >> s3
        
        write_app >> rw_svc
        read_app >> ro_svc

# ============================================================================
# DIAGRAM 9: Cluster Autoscaling
# ============================================================================
def create_cluster_autoscaling():
    with Diagram(
        "Cluster Autoscaling",
        filename="output/09_cluster_autoscaling",
        show=False,
        direction="TB"
    ):
        with Cluster("Kubernetes"):
            scheduler = Pod("Scheduler")
            pending_pods = Pod("Pending Pods")
            ca = Pod("Cluster Autoscaler")
        
        with Cluster("AWS"):
            asg = AutoScaling("Auto Scaling Group")
            ec2_1 = EC2("EC2 Instance 1")
            ec2_2 = EC2("EC2 Instance 2")
            ec2_3 = EC2("EC2 Instance 3")
        
        scheduler >> Edge(label="Detect unschedulable") >> pending_pods
        pending_pods >> Edge(label="Trigger scale") >> ca
        ca >> Edge(label="Request scale up") >> asg
        asg >> Edge(label="Launch") >> [ec2_1, ec2_2, ec2_3]
        [ec2_1, ec2_2, ec2_3] >> Edge(label="Join cluster") >> scheduler

# ============================================================================
# DIAGRAM 10: Ingress Controller Multi-App
# ============================================================================
def create_ingress_multi_app():
    with Diagram(
        "NGINX Ingress - Multiple Applications",
        filename="output/10_ingress_multi_app",
        show=False,
        direction="TB"
    ):
        with Cluster("Internet"):
            user_1 = React("User argocd")
            user_2 = React("User grafana")
            user_3 = React("User vault")
            user_4 = React("User app")
        
        lb = ELB("Load Balancer")
        
        with Cluster("Ingress Controller"):
            nginx = Pod("NGINX Pods")
        
        with Cluster("Ingress Resources"):
            ing_1 = Ingress("argocd-ingress")
            ing_2 = Ingress("grafana-ingress")
            ing_3 = Ingress("vault-ingress")
            ing_4 = Ingress("app-ingress")
        
        with Cluster("Services"):
            svc_1 = Service("argocd-server")
            svc_2 = Service("grafana")
            svc_3 = Service("vault")
            svc_4 = Service("app-service")
        
        with Cluster("Pods"):
            pod_1 = Pod("ArgoCD")
            pod_2 = Pod("Grafana")
            pod_3 = Pod("Vault")
            pod_4 = Pod("Application")
        
        [user_1, user_2, user_3, user_4] >> lb >> nginx
        nginx >> [ing_1, ing_2, ing_3, ing_4]
        
        ing_1 >> svc_1 >> pod_1
        ing_2 >> svc_2 >> pod_2
        ing_3 >> svc_3 >> pod_3
        ing_4 >> svc_4 >> pod_4

# ============================================================================
# DIAGRAM 11: Complete Observability Stack
# ============================================================================
def create_observability_stack():
    with Diagram(
        "Complete Observability Stack",
        filename="output/11_observability_stack",
        show=False,
        direction="TB"
    ):
        with Cluster("Applications"):
            app_pods = Pod("Application Pods")
        
        with Cluster("Log Collection"):
            fluent_bit = Fluentbit("Fluent Bit")
        
        with Cluster("Metrics Collection"):
            prometheus = Prometheus("Prometheus")
        
        with Cluster("Storage"):
            elasticsearch = Elasticsearch("Elasticsearch")
            prom_storage = PVC("Prometheus TSDB")
        
        with Cluster("Visualization"):
            kibana = Kibana("Kibana")
            grafana = Grafana("Grafana")
        
        app_pods >> Edge(label="Logs") >> fluent_bit
        app_pods >> Edge(label="Metrics") >> prometheus
        
        fluent_bit >> elasticsearch
        prometheus >> prom_storage
        
        elasticsearch >> kibana
        prom_storage >> grafana

# ============================================================================
# DIAGRAM 12: Security Architecture
# ============================================================================
def create_security_architecture():
    with Diagram(
        "Security Architecture",
        filename="output/12_security_architecture",
        show=False,
        direction="TB"
    ):
        user = React("User")
        
        with Cluster("Edge Security"):
            lb = ELB("Load Balancer")
        
        with Cluster("Network Security"):
            vpc = VPC("VPC")
            public_sg = PublicSubnet("Public SG")
            private_sg = PrivateSubnet("Private SG")
        
        with Cluster("Ingress Security"):
            nginx = Pod("NGINX Ingress")
            tls = IAM("TLS Certificates")
        
        with Cluster("K8s Security"):
            rbac = ServiceAccount("RBAC")
            pss = Pod("Pod Security")
        
        with Cluster("Application"):
            app_pod = Pod("Application Pod")
            secrets = SecretsManager("Secrets")
        
        user >> lb >> vpc >> public_sg >> private_sg
        private_sg >> nginx >> tls
        tls >> rbac >> pss >> app_pod >> secrets

# ============================================================================
# Main execution
# ============================================================================
def main():
    print("Generating infrastructure diagrams...")
    print("=" * 60)
    
    diagrams_to_generate = [
        ("High-Level Architecture", create_high_level_architecture),
        ("Traffic Flow", create_traffic_flow),
        ("CI/CD Pipeline", create_cicd_pipeline),
        ("EFK Stack", create_efk_stack),
        ("Monitoring Stack", create_monitoring_stack),
        ("Vault Secrets", create_vault_architecture),
        ("ArgoCD GitOps", create_argocd_gitops),
        ("Database Architecture", create_database_architecture),
        ("Cluster Autoscaling", create_cluster_autoscaling),
        ("Ingress Multi-App", create_ingress_multi_app),
        ("Observability Stack", create_observability_stack),
        ("Security Architecture", create_security_architecture),
    ]
    
    for idx, (name, func) in enumerate(diagrams_to_generate, 1):
        try:
            print(f"{idx}. Generating {name}...", end=" ")
            func()
            print("✓ Done")
        except Exception as e:
            print(f"✗ Error: {e}")
    
    print("=" * 60)
    print(f"All diagrams generated in './output' directory")
    print("\nGenerated files:")
    
    for i in range(1, 13):
        filename = f"0{i}_" if i < 10 else f"{i}_"
        print(f"  - output/{filename}*.png")

if __name__ == "__main__":
    main()