#!/bin/bash
set -euo pipefail

# Check if the repo URL has been updated
if grep -q "YOUR_USERNAME" argocd/nginx-app.yaml; then
  echo "⚠️  You need to update the repoURL in argocd/nginx-app.yaml first!"
  echo ""
  echo "   Option A: Push this repo to GitHub and update the URL"
  echo "   Option B: Deploy directly without GitOps (see below)"
  echo ""
  read -p "Deploy directly without GitOps for now? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "==> Deploying nginx directly..."
    kubectl apply -f apps/nginx/
    kubectl wait --for=condition=Available deployment/nginx -n demo --timeout=120s
    echo ""
    echo "✓ nginx deployed directly!"
    echo "  Test: kubectl port-forward svc/nginx -n demo 9090:80"
    echo "  Then: curl http://localhost:9090"
    exit 0
  else
    echo "Update the repoURL and try again."
    exit 1
  fi
fi

echo "==> Deploying Argo CD Application..."
kubectl apply -f argocd/nginx-app.yaml

echo "==> Waiting for sync..."
argocd app wait nginx-demo --timeout 120 --insecure 2>/dev/null || echo "(CLI wait skipped — check the UI)"

echo ""
echo "✓ App deployed via Argo CD!"
echo "  Check: argocd app get nginx-demo --insecure"
echo "  Test:  kubectl port-forward svc/nginx -n demo 9090:80"
