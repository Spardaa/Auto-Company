#!/bin/bash
# WebhookBin Pro - One-Command Deploy
# Run this script to authenticate and deploy in one go

set -e

echo "🚀 WebhookBin Pro Deploy Script"
echo "================================"
echo ""

# Setup PATH for Node v20
export PATH=~/.local/node/node-v20.11.0-linux-x64/bin:$PATH
WRANGLER=~/.local/npm-global/bin/wrangler

# Check if wrangler is authenticated
echo "📋 Checking authentication..."
if ! $WRANGLER whoami &>/dev/null; then
    echo ""
    echo "⚠️  Not authenticated. Starting login flow..."
    echo "   A browser window will open. Please authorize Cloudflare."
    echo ""
    $WRANGLER login
fi

echo ""
echo "✅ Authenticated!"
$WRANGLER whoami

echo ""
echo "📦 Deploying WebhookBin Pro to Cloudflare Pages..."
cd /tmp/webhookbin-pro

# Deploy to Cloudflare Pages
$WRANGLER pages deploy . --project-name=webhookbin-pro

echo ""
echo "🎉 Deployment complete!"
echo ""
echo "Your WebhookBin Pro landing page is now live at:"
echo "https://webhookbin-pro.pages.dev"
echo ""
echo "Next steps:"
echo "1. Test the landing page"
echo "2. Share on social media (see docs/marketing/HUMAN-HANDOFF.md)"
echo "3. Monitor signups via formsubmit.co"
echo ""
echo "7-Day GO Criteria:"
echo "- 50+ email signups OR"
echo "- 100+ GitHub stars OR"
echo "- 5+ sales (\$85+)"
