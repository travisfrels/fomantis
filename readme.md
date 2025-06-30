# fomantis

**fomantis** is an introduction to serverless programming using [Knative](https://knative.dev/).
This project is intended to be as simple as possible so that learning is easy. I also tried to rely
exclusively on open source projects. That being said this is **not** production ready code and
should not be used or scrutinized as such.

This project demonstrates:

- Building serverless function with Knative.
- Chaining and orchestrating functions to create workflows using Knative Eventing (Sequences and Triggers).
- Interacting with Knative Eventing via backend API (built with Node.js, Express, and CloudEvents).
- Async communication between backend and frontend using web sockets (built with Next.js and React).

## Verify Prequisites

```bash
docker -v
node -v
kn version
kn quickstart version
kind version
```

# Run the Demo

## Quick Setup (Recommended)

### Step 1: Configure Docker Username

First, configure your Docker username to replace the default 'travisfrels' username:

```bash
./configure-docker-username.sh
```

This script will:
- Automatically detect your Docker Hub username (if logged in)
- Prompt you to enter it manually if auto-detection fails
- Replace 'travisfrels' with your username in all relevant files

### Step 2: Run Installation

For a streamlined installation, use the provided install script:

```bash
./install.sh
```

This script automates all the setup steps below and provides helpful status messages throughout the process.

## Manual Setup

Alternatively, you can run the commands manually:

## Create the Knative Control Plane in Docker

```bash
kn quickstart kind
```

## Create the Broker

```bash
kubeclt apply -f ./config/broker.yaml
```

## Create the Analyze Sentiment Function

```bash
docker build -t travisfrels/analyze-sentiment ./functions/analyze-sentiment
docker push travisfrels/analyze-sentiment
kubectl apply -f ./funcions/analyze-sentiment/func.yaml
```

## Create the Analyze Profanity Function

```bash
docker build -t travisfrels/analyze-profanity ./functions/analyze-profanity
docker push travisfrels/analyze-profanity
kubectl apply -f ./funcions/analyze-profanity/func.yaml
```

## Create the Comment Analysis Sequence and Trigger

```bash
kubectl apply -f ./functions/config/comment-analysis-sequence.yaml
```

## Test the Analyze Sentiment and Analyze Profanity Functions

```bash
curl http://analyze-sentiment-service.default.127.0.0.1.sslip.io -v -k -H "Content-Type: application/json" -d "{ \"data\": { \"comment\": \"I love Knative\" } }"
curl http://analyze-profanity-service.default.127.0.0.1.sslip.io -v -k -H "Content-Type: application/json" -d "{ \"data\": { \"comment\": \"I love Knative\" } }"
```

## Create the Persist Comment Function

```bash
docker build -t travisfrels/persist-comment ./functions/persist-comment
docker push travisfrels/persist-comment
kubectl apply -f ./funcions/persist-comment/func.yaml
```

## Create the Persist Comment Trigger

```bash
kubectl apply -f ./functions/config/persist-comment-trigger.yaml
```

## Test the Persist Comment Function

```bash
curl http://persist-comment-service.default.127.0.0.1.sslip.io -v -k -H "Content-Type: application/json" -d "{ \"data\": { \"comment\": \"I love Knative\" } }"
```

## Create the Backend API

```bash
docker build -t travisfrels/fomantis-api ./backend
docker push travisfrels/fomantis-api
kubectl apply -f ./backend/service.yaml
```

## Port-Forward the Backend API Service

```bash
kubectl port-forward svc/fomantis-api-service 3001:3001
```

## Test the Backend API

```bash
curl -X GET http://localhost:3001/health-check -v -k
```

## Create the Frontend APP

```bash
docker build -t travisfrels/fomantis-app ./frontend
docker push travisfrels/fomantis-app
kubectl apply -f ./frontend/service.yaml
```

## Port-Forward the Frontend App Service

```bash
kubectl port-forward svc/fomantis-app-service 3000:3000
```

## Open Fomantis

[http://localhost:3000](http://localhost:3000)

# Cleanup

## Quick Cleanup (Recommended)

Use the provided cleanup script:

```bash
./cleanup.sh
```

## Manual Cleanup

Alternatively, delete the Knative control plane manually:

```bash
kind delete clusters knative
```
