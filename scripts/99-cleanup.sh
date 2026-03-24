#!/bin/bash
set -euo pipefail

echo "==> Deleting k3d cluster 'poc-cluster'..."
k3d cluster delete poc-cluster

echo ""
echo "✓ Cluster deleted. All resources cleaned up."
