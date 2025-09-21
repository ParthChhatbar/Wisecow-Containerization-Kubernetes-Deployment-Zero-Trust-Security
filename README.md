1️⃣ Docker Build & Local Test

Build and run the Wisecow container locally:

docker build -t wisecow-app .
docker run -p 4499:4499 wisecow-app


Visit: http://localhost:4499

2️⃣ Kubernetes Deployment
Apply manifests
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml

3️⃣ TLS Setup
Local (Self-Signed)

For local clusters (Minikube/Kind), create a self-signed certificate:

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -subj "/CN=wisecow.local/O=wisecow" \
  -keyout wisecow.key -out wisecow.crt

kubectl create secret tls wisecow-tls \
  --cert=wisecow.crt --key=wisecow.key


Update /etc/hosts to map wisecow.local to your cluster IP.

Access the app at https://wisecow.local
 (accept browser warning).

Production (Let’s Encrypt)

Install cert-manager:

kubectl apply --validate=false \
  -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml


Edit k8s/cluster-issuer.yaml with your email and apply:

kubectl apply -f k8s/cluster-issuer.yaml


Update k8s/ingress.yaml with your real domain and apply:

kubectl apply -f k8s/ingress.yaml


Cert-manager will automatically provision and renew TLS certificates.

4️⃣ CI/CD with GitHub Actions

The workflow .github/workflows/ci-cd.yml automates:

Build & Push – Builds the Docker image and pushes to a container registry (GitHub Container Registry or Docker Hub) on every push to main.

Deploy – Applies Kubernetes manifests to update the cluster automatically.
5️⃣ Zero-Trust Security with KubeArmor
Install KubeArmor
kubectl apply -f https://kubearmor.io/docs/latest/install/kubearmor/kubearmor-operator.yaml
kubectl apply -f https://kubearmor.io/docs/latest/install/kubearmor/kubearmor-ds.yaml
kubectl get pods -n kubearmor

Apply Zero-Trust Policy
kubectl apply -f k8s/kubearmor-policy.yaml


This policy:

Blocks all file writes except the Wisecow script

Restricts process execution to only required binaries

Limits network traffic to the Wisecow service port

Testing Policy Violations

Exec into a Wisecow pod:

kubectl exec -it <wisecow-pod> -- /bin/bash


Attempt forbidden actions (e.g., creating files, external network calls).
KubeArmor logs the violations in real time.

✅ End Goal

By following this repository and README:

Wisecow is fully containerized

Deployed on Kubernetes with automated TLS

Backed by a GitHub Actions CI/CD pipeline

Secured with optional KubeArmor zero-trust runtime policies

This project showcases a complete, production-ready DevOps deployment workflow.
