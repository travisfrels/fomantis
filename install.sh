#!/bin/bash

# fomantis Installation Script
# This script automates the setup process for the fomantis serverless demo

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

# Function to wait for service to be ready
wait_for_service() {
    local service_name=$1
    local namespace=${2:-default}
    print_status "Waiting for $service_name to be ready..."
    kubectl wait --for=condition=Ready --timeout=300s ksvc/$service_name -n $namespace
}

print_status "Starting fomantis installation..."

# Verify prerequisites
print_status "Verifying prerequisites..."
check_command docker
check_command node
check_command kn
check_command kubectl
check_command kind

print_status "Prerequisites verified successfully!"

# Display versions
print_status "Installed versions:"
docker -v
node -v
kn version
kn quickstart version 2>/dev/null || echo "kn quickstart not available"
kind version

# Create the Knative Control Plane in Docker
print_status "Creating Knative control plane with kind..."
kn quickstart kind

# Wait a bit for the cluster to be ready
print_status "Waiting for cluster to be ready..."
sleep 10

# Create the Broker
print_status "Creating the broker..."
kubectl apply -f ./config/broker.yaml

# Create the Analyze Sentiment Function
print_status "Building and deploying Analyze Sentiment function..."
docker build -t travisfrels/analyze-sentiment ./functions/analyze-sentiment
docker push travisfrels/analyze-sentiment
kubectl apply -f ./functions/analyze-sentiment/func.yaml
wait_for_service "analyze-sentiment-service"

# Create the Analyze Profanity Function
print_status "Building and deploying Analyze Profanity function..."
docker build -t travisfrels/analyze-profanity ./functions/analyze-profanity
docker push travisfrels/analyze-profanity
kubectl apply -f ./functions/analyze-profanity/func.yaml
wait_for_service "analyze-profanity-service"

# Create the Comment Analysis Sequence and Trigger
print_status "Creating comment analysis sequence..."
kubectl apply -f ./functions/config/comment-analysis-sequence.yaml

# Test the Analyze Sentiment and Analyze Profanity Functions
print_status "Testing Analyze Sentiment function..."
curl http://analyze-sentiment-service.default.127.0.0.1.sslip.io -v -k -H "Content-Type: application/json" -d '{ "data": { "comment": "I love Knative" } }' || print_warning "Sentiment function test failed"

print_status "Testing Analyze Profanity function..."
curl http://analyze-profanity-service.default.127.0.0.1.sslip.io -v -k -H "Content-Type: application/json" -d '{ "data": { "comment": "I love Knative" } }' || print_warning "Profanity function test failed"

# Create the Persist Comment Function
print_status "Building and deploying Persist Comment function..."
docker build -t travisfrels/persist-comment ./functions/persist-comment
docker push travisfrels/persist-comment
kubectl apply -f ./functions/persist-comment/func.yaml
wait_for_service "persist-comment-service"

# Create the Persist Comment Trigger
print_status "Creating persist comment trigger..."
kubectl apply -f ./functions/config/persist-comment-trigger.yaml

# Test the Persist Comment Function
print_status "Testing Persist Comment function..."
curl http://persist-comment-service.default.127.0.0.1.sslip.io -v -k -H "Content-Type: application/json" -d '{ "data": { "comment": "I love Knative" } }' || print_warning "Persist comment function test failed"

# Create the Backend API
print_status "Building and deploying Backend API..."
docker build -t travisfrels/fomantis-api ./backend
docker push travisfrels/fomantis-api
kubectl apply -f ./backend/service.yaml
wait_for_service "fomantis-api-service"

# Create the Frontend APP
print_status "Building and deploying Frontend App..."
docker build -t travisfrels/fomantis-app ./frontend
docker push travisfrels/fomantis-app
kubectl apply -f ./frontend/service.yaml
wait_for_service "fomantis-app-service"

print_success "fomantis installation completed successfully!"
print_status ""
print_status "To access the application:"
print_status "1. Port-forward the backend API (in a separate terminal):"
print_status "   kubectl port-forward svc/fomantis-api-service 3001:3001"
print_status ""
print_status "2. Port-forward the frontend app (in another separate terminal):"
print_status "   kubectl port-forward svc/fomantis-app-service 3000:3000"
print_status ""
print_status "3. Open your browser to: http://localhost:3000"
print_status ""
print_status "To test the backend API:"
print_status "   curl -X GET http://localhost:3001/health-check -v -k"
print_status ""
print_status "To cleanup when done:"
print_status "   kind delete clusters knative"