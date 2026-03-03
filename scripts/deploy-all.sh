#!/bin/bash
# Auto Company - Master Deployment Script
# Run this script to deploy all products
# Usage: ./scripts/deploy-all.sh

set -e

echo "=========================================="
echo "   Auto Company - Deployment Script"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Node.js
check_node() {
    echo "Checking Node.js..."
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        echo -e "${GREEN}✓${NC} Node.js $NODE_VERSION found"
        return 0
    else
        echo -e "${RED}✗${NC} Node.js not found. Please install Node.js v18+"
        return 1
    fi
}

# Check GitHub CLI
check_gh() {
    echo "Checking GitHub CLI..."
    if command -v gh &> /dev/null; then
        if gh auth status &> /dev/null; then
            echo -e "${GREEN}✓${NC} GitHub CLI authenticated"
            return 0
        else
            echo -e "${YELLOW}!${NC} GitHub CLI not authenticated"
            echo "  Run: gh auth login"
            return 1
        fi
    else
        echo -e "${RED}✗${NC} GitHub CLI not found"
        return 1
    fi
}

# Check Wrangler
check_wrangler() {
    echo "Checking Wrangler..."
    if command -v wrangler &> /dev/null; then
        if wrangler whoami &> /dev/null; then
            echo -e "${GREEN}✓${NC} Wrangler authenticated"
            return 0
        else
            echo -e "${YELLOW}!${NC} Wrangler not authenticated"
            echo "  Run: wrangler login"
            return 1
        fi
    else
        echo -e "${YELLOW}!${NC} Wrangler not found, checking local install..."
        LOCAL_WRANGLER="$HOME/.local/npm-global/bin/wrangler"
        if [ -f "$LOCAL_WRANGLER" ]; then
            export PATH="$HOME/.local/node/node-v20.11.0-linux-x64/bin:$PATH"
            if "$LOCAL_WRANGLER" whoami &> /dev/null; then
                echo -e "${GREEN}✓${NC} Local Wrangler authenticated"
                return 0
            else
                echo -e "${YELLOW}!${NC} Local Wrangler not authenticated"
                echo "  Run: PATH=~/.local/node/node-v20.11.0-linux-x64/bin:\$PATH ~/.local/npm-global/bin/wrangler login"
                return 1
            fi
        fi
        return 1
    fi
}

# Deploy WebhookBin Pro to Cloudflare Workers
deploy_webhookbin() {
    echo ""
    echo "=========================================="
    echo "   Deploying WebhookBin Pro"
    echo "=========================================="

    WEBHOOKBIN_DIR="/mnt/c/Users/17503/Auto-Company/projects/webhookbin-pro"

    if [ ! -d "$WEBHOOKBIN_DIR" ]; then
        echo -e "${RED}✗${NC} WebhookBin Pro files not found at $WEBHOOKBIN_DIR"
        return 1
    fi

    cd "$WEBHOOKBIN_DIR"

    # Set PATH for local Node if needed
    if [ -d "$HOME/.local/node/node-v20.11.0-linux-x64" ]; then
        export PATH="$HOME/.local/node/node-v20.11.0-linux-x64/bin:$PATH"
    fi

    # Create D1 database if it doesn't exist
    echo "Checking D1 database..."
    if ! wrangler d1 list 2>/dev/null | grep -q "webhookbin-pro"; then
        echo "Creating D1 database..."
        wrangler d1 create webhookbin-pro || true
    fi

    # Deploy to Cloudflare Workers
    if wrangler deploy; then
        echo -e "${GREEN}✓${NC} WebhookBin Pro deployed successfully!"
        echo "  URL: https://webhookbin-pro.maxmiksa.workers.dev"
        return 0
    else
        echo -e "${RED}✗${NC} Deployment failed"
        return 1
    fi
}

# Deploy Free Tools to GitHub Pages
deploy_free_tools() {
    echo ""
    echo "=========================================="
    echo "   Deploying Free Tools to GitHub Pages"
    echo "=========================================="

    REPO_DIR="/mnt/c/Users/17503/Auto-Company"

    cd "$REPO_DIR"

    # Add all free tools
    git add projects/index.html
    git add projects/saas-pricing-calculator.html
    git add projects/churn-calculator.html
    git add projects/burn-rate-calculator.html
    git add projects/nomorezoomfatigue-validation/

    # Check if there are changes to commit
    if git diff --cached --quiet; then
        echo -e "${GREEN}✓${NC} Free tools already up to date"
        return 0
    fi

    # Commit and push
    git commit -m "chore: update free tools deployment"
    git push origin main

    echo -e "${GREEN}✓${NC} Free tools pushed to GitHub"
    echo "  GitHub Actions will deploy automatically"
    echo "  Landing Page:    https://maxmiksa.github.io/Auto-Company/"
    echo "  Pricing Calc:    https://maxmiksa.github.io/Auto-Company/projects/saas-pricing-calculator.html"
    echo "  Churn Analyzer:  https://maxmiksa.github.io/Auto-Company/projects/churn-calculator.html"
    echo "  Burn Rate Calc:  https://maxmiksa.github.io/Auto-Company/projects/burn-rate-calculator.html"
    return 0
}

# Main execution
main() {
    echo "Step 1: Checking prerequisites..."
    echo ""

    NODE_OK=true
    GH_OK=true
    WRANGLER_OK=true

    check_node || NODE_OK=false
    check_gh || GH_OK=false
    check_wrangler || WRANGLER_OK=false

    echo ""
    echo "=========================================="
    echo "   Prerequisites Summary"
    echo "=========================================="

    if [ "$NODE_OK" = true ]; then
        echo -e "Node.js:      ${GREEN}OK${NC}"
    else
        echo -e "Node.js:      ${RED}MISSING${NC}"
    fi

    if [ "$GH_OK" = true ]; then
        echo -e "GitHub CLI:   ${GREEN}AUTHENTICATED${NC}"
    else
        echo -e "GitHub CLI:   ${YELLOW}NOT AUTHENTICATED${NC}"
    fi

    if [ "$WRANGLER_OK" = true ]; then
        echo -e "Wrangler:     ${GREEN}AUTHENTICATED${NC}"
    else
        echo -e "Wrangler:     ${YELLOW}NOT AUTHENTICATED${NC}"
    fi

    echo ""

    # Deploy what we can
    DEPLOYED_WEBHOOKBIN=false
    DEPLOYED_FREE_TOOLS=false

    if [ "$WRANGLER_OK" = true ]; then
        deploy_webhookbin && DEPLOYED_WEBHOOKBIN=true
    else
        echo -e "${YELLOW}Skipping WebhookBin Pro (Wrangler not authenticated)${NC}"
        echo "To authenticate: wrangler login"
    fi

    if [ "$GH_OK" = true ]; then
        deploy_free_tools && DEPLOYED_FREE_TOOLS=true
    else
        echo -e "${YELLOW}Skipping Free Tools (GitHub not authenticated)${NC}"
        echo "To authenticate: gh auth login"
    fi

    echo ""
    echo "=========================================="
    echo "   Deployment Summary"
    echo "=========================================="

    if [ "$DEPLOYED_WEBHOOKBIN" = true ]; then
        echo -e "WebhookBin Pro:     ${GREEN}DEPLOYED${NC} → https://webhookbin-pro.maxmiksa.workers.dev"
    else
        echo -e "WebhookBin Pro:     ${YELLOW}PENDING${NC} (needs wrangler login)"
    fi

    if [ "$DEPLOYED_FREE_TOOLS" = true ]; then
        echo -e "Free Tools:         ${GREEN}DEPLOYED${NC} → https://maxmiksa.github.io/Auto-Company/"
    else
        echo -e "Free Tools:         ${YELLOW}PENDING${NC} (needs gh auth login)"
    fi

    echo ""

    if [ "$DEPLOYED_WEBHOOKBIN" = true ] || [ "$DEPLOYED_FREE_TOOLS" = true ]; then
        echo -e "${GREEN}Deployment partially or fully successful!${NC}"
        return 0
    else
        echo -e "${YELLOW}No deployments made. Please authenticate and try again.${NC}"
        echo ""
        echo "Quick start:"
        echo "  1. PATH=~/.local/node/node-v20.11.0-linux-x64/bin:\$PATH ~/.local/npm-global/bin/wrangler login"
        echo "  2. gh auth login"
        echo "  3. ./scripts/deploy-all.sh"
        return 1
    fi
}

main "$@"
