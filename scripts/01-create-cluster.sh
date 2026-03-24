#!/bin/bash
set -euo pipefail

echo "==> Creating k3s cluster with k3d..."
k3d cluster create --config k3d-config.yaml

echo "==> Waiting for nodes to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s

echo "==> Cluster info:"
kubectl cluster-info
kubectl get nodes -o wide

echo ""
echo "✓ Cluster 'poc-cluster' is ready!"
