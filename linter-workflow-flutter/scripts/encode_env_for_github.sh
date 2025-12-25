#!/bin/bash

# Script to encode .env files to base64 for GitHub secrets
# Usage: ./scripts/encode_env_for_github.sh <dev|uat|prod>

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo "Usage: ./scripts/encode_env_for_github.sh <dev|uat|prod|all>"
    echo ""
    echo "Examples:"
    echo "  ./scripts/encode_env_for_github.sh dev     # Encode .dev.env"
    echo "  ./scripts/encode_env_for_github.sh prod    # Encode .prod.env"
    echo "  ./scripts/encode_env_for_github.sh all     # Encode all .env files"
    echo ""
    echo "This will output base64-encoded content that you can paste into GitHub secrets."
    exit 1
fi

cd "$PROJECT_ROOT"

encode_env() {
    local ENV_TYPE=$1
    local ENV_FILE=".$ENV_TYPE.env"
    local SECRET_NAME="$(echo $ENV_TYPE | tr '[:lower:]' '[:upper:]')_ENV_BASE64"
    
    if [ ! -f "$ENV_FILE" ]; then
        echo -e "${RED}❌ Error: $ENV_FILE not found${NC}"
        return 1
    fi
    
    echo -e "${BLUE}======================================================"
    echo "📦 Encoding $ENV_FILE"
    echo -e "======================================================${NC}"
    echo ""
    
    # Show file contents (for verification)
    echo -e "${YELLOW}File contents:${NC}"
    cat "$ENV_FILE"
    echo ""
    echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
    echo ""
    
    # Encode to base64
    ENCODED=$(base64 -i "$ENV_FILE")
    
    echo -e "${GREEN}✅ Encoded successfully!${NC}"
    echo ""
    echo -e "${BLUE}GitHub Secret Name:${NC}"
    echo "$SECRET_NAME"
    echo ""
    echo -e "${BLUE}GitHub Secret Value (copy this):${NC}"
    echo "────────────────────────────────────────────────────"
    echo "$ENCODED"
    echo "────────────────────────────────────────────────────"
    echo ""
    echo -e "${YELLOW}How to update GitHub secret:${NC}"
    echo "1. Go to: https://github.com/YOUR_REPO/settings/secrets/actions"
    echo "2. Click on: $SECRET_NAME"
    echo "3. Click: 'Update secret'"
    echo "4. Paste the encoded value above"
    echo "5. Click: 'Update secret'"
    echo ""
    echo "======================================================"
    echo ""
}

# Process based on input
if [ "$1" == "all" ]; then
    encode_env "dev"
    encode_env "uat"
    encode_env "prod"
    
    echo -e "${GREEN}✅ All .env files encoded!${NC}"
    echo ""
    echo "Update these 3 secrets in GitHub:"
    echo "  - DEV_ENV_BASE64"
    echo "  - UAT_ENV_BASE64"
    echo "  - PROD_ENV_BASE64"
else
    encode_env "$1"
fi

