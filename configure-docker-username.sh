#!/bin/bash

# Docker Username Configuration Script
# This script detects the Docker username and replaces 'travisfrels' with the current user's Docker username

set -e  # Exit on any error

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

# Function to check if a command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 could not be found. Please install $1 before running this script."
        exit 1
    fi
}

# Function to get Docker username
get_docker_username() {
    local username=""
    
    # Method 1: Try to get username from docker whoami command
    if command -v docker > /dev/null 2>&1 && docker info > /dev/null 2>&1; then
        # Try docker system info first
        username=$(docker system info 2>/dev/null | grep -i "username" | awk '{print $2}' | head -1 2>/dev/null || echo "")
        
        # If that doesn't work, try a simple docker whoami-like approach
        if [ -z "$username" ]; then
            # Try to get username by attempting to access Docker Hub API
            username=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:library/hello-world:pull" 2>/dev/null | grep -o '"username":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "")
        fi
    fi
    
    # Method 2: Check Docker config file
    if [ -z "$username" ] && [ -f "$HOME/.docker/config.json" ]; then
        # More robust parsing of Docker config
        username=$(python3 -c "
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
    fi
    
    # Method 3: Try using jq if available and Python failed
    if [ -z "$username" ] && [ -f "$HOME/.docker/config.json" ] && command -v jq > /dev/null 2>&1; then
        username=$(jq -r '.auths["https://index.docker.io/v1/"].username // empty' "$HOME/.docker/config.json" 2>/dev/null || echo "")
    fi
    
    # Method 4: Check for current system username as fallback suggestion
    if [ -z "$username" ]; then
        local system_user=$(whoami)
        print_warning "Could not automatically detect Docker username."
        print_status "Suggestions:"
        print_status "  - Your system username: $system_user"
        print_status "  - Check if you're logged into Docker Hub: docker login"
        print_status ""
        print_status "Please enter your Docker Hub username:"
        read -p "Docker username: " username
        
        if [ -z "$username" ]; then
            print_error "Username cannot be empty."
            exit 1
        fi
    fi
    
    echo "$username"
}

# Function to perform find and replace in a file
replace_in_file() {
    local file="$1"
    local old_username="$2"
    local new_username="$3"
    
    if [ -f "$file" ]; then
        if grep -q "$old_username" "$file"; then
            print_status "Updating $file..."
            sed -i "s/$old_username/$new_username/g" "$file"
            print_success "Updated $file"
        else
            print_status "No changes needed in $file"
        fi
    else
        print_warning "File $file not found, skipping..."
    fi
}

print_status "Starting Docker username configuration..."

# Check prerequisites
check_command docker
check_command sed

# Get Docker username
print_status "Detecting Docker username..."
DOCKER_USERNAME=$(get_docker_username)

if [ -z "$DOCKER_USERNAME" ]; then
    print_error "Failed to get Docker username."
    exit 1
fi

print_success "Detected Docker username: $DOCKER_USERNAME"

# Verify Docker username (optional check)
print_status "Verifying Docker username..."
if command -v curl > /dev/null 2>&1; then
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "https://hub.docker.com/v2/users/$DOCKER_USERNAME/" 2>/dev/null || echo "000")
    if [ "$http_code" = "200" ]; then
        print_success "Docker username '$DOCKER_USERNAME' verified successfully!"
    elif [ "$http_code" = "404" ]; then
        print_warning "Docker username '$DOCKER_USERNAME' not found on Docker Hub."
        print_warning "Make sure this is correct or you may encounter push errors later."
    else
        print_warning "Could not verify Docker username (network issue or rate limit)."
    fi
else
    print_warning "curl not available, skipping username verification."
fi

# Confirm with user
print_status "This will replace 'travisfrels' with '$DOCKER_USERNAME' in all relevant files."
read -p "Do you want to continue? (y/N): " confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    print_status "Operation cancelled."
    exit 0
fi

OLD_USERNAME="travisfrels"

# List of files to update
FILES=(
    "install.sh"
    "cleanup.sh"
    "functions/analyze-sentiment/func.yaml"
    "functions/analyze-profanity/func.yaml"
    "functions/persist-comment/func.yaml"
    "backend/service.yaml"
    "frontend/service.yaml"
)

print_status "Updating files..."

# Update each file
for file in "${FILES[@]}"; do
    replace_in_file "$file" "$OLD_USERNAME" "$DOCKER_USERNAME"
done

print_success "Docker username configuration completed!"
print_status "All occurrences of '$OLD_USERNAME' have been replaced with '$DOCKER_USERNAME'"
print_status ""
print_status "Files updated:"
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  - $file"
    fi
done

print_status ""
print_status "You can now run the install script with your Docker username:"
print_status "  ./install.sh"