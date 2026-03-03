#!/bin/bash
# One-command authentication and deployment
# Run this in a terminal with browser access

set -e

echo "=========================================="
echo "  Auto Company - Quick Deploy"
echo "=========================================="
echo ""
echo "This script will:"
echo "  1. Authenticate with GitHub"
echo "  2. Authenticate with Cloudflare"
echo "  3. Deploy all products"
echo ""
read -p "Press Enter to continue..."

# Set up PATH
export PATH="$HOME/.local/node/node-v20.11.0-linux-x64/bin:$PATH"
WRANGLER="$HOME/.local/npm-global/bin/wrangler"

# Step 1: GitHub Auth
echo ""
echo "=== Step 1: GitHub Authentication ==="
if gh auth status &> /dev/null; then
    echo "Already authenticated with GitHub"
else
    echo "Launching GitHub login..."
    gh auth login
fi

# Step 2: Cloudflare Auth
echo ""
echo "=== Step 2: Cloudflare Authentication ==="
if "$WRANGLER" whoami &> /dev/null; then
    echo "Already authenticated with Cloudflare"
else
    echo "Launching Cloudflare login..."
    "$WRANGLER" login
fi

# Step 3: Deploy
echo ""
echo "=== Step 3: Deploying All Products ==="
cd /mnt/c/Users/17503/Auto-Company
./scripts/deploy-all.sh

echo ""
echo "=========================================="
echo "  Deployment Complete!"
echo "=========================================="
echo ""
echo "Your products are live at:"
echo "  Landing:    https://maxmiksa.github.io/Auto-Company/"
echo "  WebhookBin: https://webhookbin-pro.maxmiksa.workers.dev"
echo ""
