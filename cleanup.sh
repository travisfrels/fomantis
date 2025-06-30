#!/bin/bash

# fomantis Cleanup Script
# This script removes the fomantis serverless demo environment

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

print_status "Starting fomantis cleanup..."

# Check if kind cluster exists
if kind get clusters | grep -q "knative"; then
    print_status "Deleting Knative kind cluster..."
    kind delete clusters knative
    print_success "Knative cluster deleted successfully!"
else
    print_warning "Knative cluster not found. It may have been already deleted."
fi

# Optional: Remove Docker images (uncomment if you want to clean up images too)
# print_status "Removing Docker images..."
# docker rmi travisfrels/analyze-sentiment:latest 2>/dev/null || print_warning "analyze-sentiment image not found"
# docker rmi travisfrels/analyze-profanity:latest 2>/dev/null || print_warning "analyze-profanity image not found"
# docker rmi travisfrels/persist-comment:latest 2>/dev/null || print_warning "persist-comment image not found"
# docker rmi travisfrels/fomantis-api:latest 2>/dev/null || print_warning "fomantis-api image not found"
# docker rmi travisfrels/fomantis-app:latest 2>/dev/null || print_warning "fomantis-app image not found"

print_success "fomantis cleanup completed!"
print_status "All resources have been removed."