#!/bin/bash

# Test Docker Username Detection Script
# This script shows what Docker username would be detected without making any changes

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "Testing Docker username detection methods..."
print_status ""

# Test Method 1: Docker system info
print_status "Method 1: Docker system info"
if command -v docker > /dev/null 2>&1 && docker info > /dev/null 2>&1; then
    username1=$(docker system info 2>/dev/null | grep -i "username" | awk '{print $2}' | head -1 2>/dev/null || echo "")
    if [ -n "$username1" ]; then
        print_success "Found: $username1"
    else
        print_warning "No username found in docker system info"
    fi
else
    print_warning "Docker not available or not running"
fi

# Test Method 2: Docker config file with Python
print_status ""
print_status "Method 2: Docker config file (Python parsing)"
if [ -f "$HOME/.docker/config.json" ]; then
    if command -v python3 > /dev/null 2>&1; then
        username2=$(python3 -c "
import json
import sys
try:
    with open('$HOME/.docker/config.json', 'r') as f:
        config = json.load(f)
    auths = config.get('auths', {})
    for registry, auth_info in auths.items():
        if 'index.docker.io' in registry or 'docker.io' in registry:
            if 'username' in auth_info:
                print(auth_info['username'])
                sys.exit(0)
            elif 'auth' in auth_info:
                import base64
                try:
                    decoded = base64.b64decode(auth_info['auth']).decode('utf-8')
                    username = decoded.split(':')[0]
                    print(username)
                    sys.exit(0)
                except:
                    pass
except:
    pass
" 2>/dev/null || echo "")
        if [ -n "$username2" ]; then
            print_success "Found: $username2"
        else
            print_warning "No username found in Docker config (Python method)"
        fi
    else
        print_warning "Python3 not available"
    fi
else
    print_warning "Docker config file not found at $HOME/.docker/config.json"
fi

# Test Method 3: Docker config file with jq
print_status ""
print_status "Method 3: Docker config file (jq parsing)"
if [ -f "$HOME/.docker/config.json" ]; then
    if command -v jq > /dev/null 2>&1; then
        username3=$(jq -r '.auths["https://index.docker.io/v1/"].username // empty' "$HOME/.docker/config.json" 2>/dev/null || echo "")
        if [ -n "$username3" ]; then
            print_success "Found: $username3"
        else
            print_warning "No username found in Docker config (jq method)"
        fi
    else
        print_warning "jq not available"
    fi
else
    print_warning "Docker config file not found"
fi

# System username suggestion
print_status ""
print_status "System username suggestion: $(whoami)"

print_status ""
print_status "Current Docker login status:"
if command -v docker > /dev/null 2>&1; then
    docker system info 2>/dev/null | grep -E "(Username|Registry)" || print_warning "No Docker login information found"
else
    print_warning "Docker not available"
fi

print_status ""
print_status "To configure your Docker username, run: ./configure-docker-username.sh"