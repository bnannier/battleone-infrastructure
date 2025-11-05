#!/bin/bash

# GitHub Secrets Setup Script for BattleOne Infrastructure
# This script uses GitHub CLI to set up all required secrets

set -e

echo "🔑 Setting up GitHub secrets for BattleOne Infrastructure deployment..."
echo ""

# Check if GitHub CLI is installed and authenticated
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI is not installed. Please install it first:"
    echo "   brew install gh  # macOS"
    echo "   # Or visit: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI. Please authenticate first:"
    echo "   gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is installed and authenticated"
echo ""

# Function to set secret with prompt
set_secret() {
    local secret_name=$1
    local description=$2
    local example=$3
    local required=$4
    
    echo "📝 Setting up: $secret_name"
    echo "   Description: $description"
    if [ -n "$example" ]; then
        echo "   Example: $example"
    fi
    echo ""
    
    if [ "$required" = "required" ]; then
        read -s -p "   Enter value for $secret_name: " secret_value
        echo ""
        
        if [ -z "$secret_value" ]; then
            echo "   ❌ $secret_name is required and cannot be empty!"
            exit 1
        fi
    else
        read -s -p "   Enter value for $secret_name (optional): " secret_value
        echo ""
    fi
    
    if [ -n "$secret_value" ]; then
        echo "$secret_value" | gh secret set "$secret_name"
        echo "   ✅ $secret_name set successfully"
    else
        echo "   ⏭️  Skipping $secret_name (will use default)"
    fi
    echo ""
}

# Set up required secrets
echo "🚀 Setting up required secrets..."
echo ""

set_secret "DO_SSH_PRIVATE_KEY" \
    "SSH private key for droplet access" \
    "-----BEGIN OPENSSH PRIVATE KEY-----..." \
    "required"

set_secret "DO_DROPLET_IP" \
    "DigitalOcean droplet IP address" \
    "167.99.184.98" \
    "required"

set_secret "DO_USERNAME" \
    "SSH username for droplet" \
    "root" \
    "required"

set_secret "POSTGRES_PASSWORD" \
    "PostgreSQL database password (secure)" \
    "" \
    "required"

set_secret "REDIS_PASSWORD" \
    "Redis cache password (secure)" \
    "" \
    "required"

echo "🔧 Setting up optional secrets..."
echo ""

set_secret "POSTGRES_DB" \
    "PostgreSQL database name" \
    "battleone" \
    "optional"

set_secret "POSTGRES_USER" \
    "PostgreSQL username" \
    "battleone_user" \
    "optional"

set_secret "KRATOS_LOG_LEVEL" \
    "Kratos logging level" \
    "warn" \
    "optional"

echo "🎉 GitHub secrets setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Go to GitHub Actions: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/actions"
echo "2. Run the 'Deploy Infrastructure to DigitalOcean' workflow"
echo "3. Monitor the deployment progress"
echo ""
echo "🔍 To verify secrets were set:"
echo "   gh secret list"
echo ""
echo "🔗 Infrastructure will be deployed to: \$DO_DROPLET_IP:4433/health/ready"