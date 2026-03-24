#!/bin/bash
set -euo pipefail

echo "==> Creating argocd namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo "==> Installing Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "==> Waiting for Argo CD pods to be ready..."
kubectl wait --for=condition=Available deployment/argocd-server -n argocd --timeout=300s

echo "==> Patching argocd-server to NodePort on 30080..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort", "ports": [{"port": 80, "targetPort": 8080, "nodePort": 30080, "name": "http"}, {"port": 443, "targetPort": 8080, "nodePort": 30443, "name": "https"}]}}'

echo "==> Getting initial admin password..."
ARGO_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "✓ Argo CD installed!"
echo ""
echo "  UI:       https://localhost:30443"
echo "  User:     admin"
echo "  Password: ${ARGO_PWD}"
echo ""
echo "  CLI login:"
echo "  argocd login localhost:30443 --username admin --password '${ARGO_PWD}' --insecure"
