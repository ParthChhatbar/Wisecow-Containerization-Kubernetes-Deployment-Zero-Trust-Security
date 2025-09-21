# Wisecow – Containerization, Kubernetes Deployment & Zero-Trust Security

This project demonstrates the **containerization**, **Kubernetes deployment**, **GitHub Actions CI/CD**, and **Zero-Trust security** (via KubeArmor) of the [Wisecow](https://github.com/nyrahul/wisecow) application.  
The goal is to automate the entire pipeline from code changes to deployment on a Kubernetes cluster, secured with TLS and optional runtime enforcement.

---

## 📑 Table of Contents
- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Features](#features)
- [Repository Structure](#repository-structure)
- [Setup Instructions](#setup-instructions)
  - [1. Prerequisites](#1-prerequisites)
  - [2. Clone the Repository](#2-clone-the-repository)
  - [3. Build and Run with Docker](#3-build-and-run-with-docker)
  - [4. Deploy to Kubernetes](#4-deploy-to-kubernetes)
  - [5. TLS/Ingress Configuration](#5-tlsingress-configuration)
  - [6. CI/CD Workflow](#6-cicd-workflow)
  - [7. Optional: KubeArmor Zero-Trust Policy](#7-optional-kubearmor-zero-trust-policy)
- [Secrets Configuration](#secrets-configuration)
- [License](#license)

---

## Project Overview
The Wisecow app generates random quotes and audio (cowsay + fortune).  
This project:
1. **Dockerizes** the app for portability.
2. Deploys it on a **Kubernetes cluster** (Minikube/Kind or any managed cluster).
3. Implements **GitHub Actions** to automate:
   - Docker image build & push to a container registry (GHCR or Docker Hub).
   - Automatic deployment to Kubernetes after successful image build.
4. Secures traffic with **TLS** using `cert-manager` and Kubernetes Ingress.
5. (Optional) Enforces a **Zero-Trust policy** using KubeArmor to prevent unauthorized actions inside the container.

---

## Architecture
```
Developer Commit → GitHub → GitHub Actions CI/CD →
Docker Image Build → Container Registry →
Kubernetes Deployment → TLS-secured Service
(Optional) → KubeArmor Runtime Enforcement
```

---

## Features
- **Containerization**: Dockerfile builds a lean, production-ready image.
- **Kubernetes Deployment**: Deployment, Service, and Ingress manifests included.
- **TLS Security**: Automated certificate management with `cert-manager`.
- **CI/CD Pipeline**: GitHub Actions builds, pushes, and deploys on each commit.
- **Zero-Trust Runtime**: Optional KubeArmor policy restricts unauthorized access.

---

## Repository Structure
```
.
├─ .github/
│  └─ workflows/
│     └─ ci-cd.yml         # GitHub Actions pipeline
├─ k8s/
│  ├─ deployment.yaml      # Wisecow Deployment
│  ├─ service.yaml         # Wisecow Service
│  ├─ ingress.yaml         # Ingress + TLS
│  ├─ issuer.yaml          # ClusterIssuer (Let's Encrypt)
│  └─ kubearmor-policy.yaml# Optional Zero-Trust policy
├─ wisecow.sh              # Wisecow application script
├─ Dockerfile              # Container image definition
└─ README.md               # Project documentation
```

---

## Setup Instructions

### 1. Prerequisites
- **Docker** installed and running
- **kubectl** configured for your cluster
- **Minikube / Kind / Managed K8s** cluster
- **Helm** (for installing cert-manager)
- **GitHub Account & PAT** (if using Docker Hub or GHCR)

### 2. Clone the Repository
```bash
git clone https://github.com/ParthChhatbar/Wisecow-Containerization-Kubernetes-Deployment-Zero-Trust-Security.git
cd Wisecow-Containerization-Kubernetes-Deployment-Zero-Trust-Security
```

### 3. Build and Run with Docker
```bash
docker build -t wisecow:latest .
docker run -p 8000:8000 wisecow:latest
```
Visit: [http://localhost:8000](http://localhost:8000)

### 4. Deploy to Kubernetes
Apply manifests in order:
```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

Check resources:
```bash
kubectl get pods
kubectl get svc
```

### 5. TLS/Ingress Configuration
Install `cert-manager`:
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```
Create ClusterIssuer & Ingress:
```bash
kubectl apply -f k8s/issuer.yaml
kubectl apply -f k8s/ingress.yaml
```

Ensure your DNS points to the cluster load balancer (or use a Minikube tunnel).

### 6. CI/CD Workflow
The GitHub Actions pipeline (`.github/workflows/ci-cd.yml`) performs:
1. **Build & Push**: Builds the Docker image and pushes to GHCR/Docker Hub on every commit to `main`.
2. **Deploy**: Uses the Kubernetes config stored in GitHub Secrets to apply manifests.

#### Required Secrets
| Secret Name       | Purpose                                   |
|-------------------|--------------------------------------------|
| `KUBECONFIG_DATA` | Base64-encoded kubeconfig for cluster access |
| `DOCKER_USERNAME` | Docker Hub username (if using Docker Hub)   |
| `DOCKER_PASSWORD` | Docker Hub token/password                   |

> For GHCR, `GITHUB_TOKEN` is sufficient if using the same repo.

### 7. Optional: KubeArmor Zero-Trust Policy
1. Install KubeArmor in the cluster:
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/kubearmor/KubeArmor/main/install/kubearmor-operator.yaml
   kubectl apply -f https://raw.githubusercontent.com/kubearmor/KubeArmor/main/install/kubearmor-daemonset.yaml
   ```
2. Apply the policy:
   ```bash
   kubectl apply -f k8s/kubearmor-policy.yaml
   ```
3. Attempt restricted operations inside the pod to generate violations (view via `kubectl logs` or KubeArmor CLI).

---

## Secrets Configuration
### Encode Kubeconfig
Linux/Mac:
```bash
cat ~/.kube/config | base64 --wrap=0
```
Windows PowerShell:
```powershell
[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((Get-Content $env:USERPROFILE + "\.kube\config" -Raw)))
```
Copy the single line output into the GitHub Secret `KUBECONFIG_DATA`.

---

## License
This project is licensed under the [MIT License](LICENSE).

Backed by a GitHub Actions CI/CD pipeline

Secured with optional KubeArmor zero-trust runtime policies

This project showcases a complete, production-ready DevOps deployment workflow.
