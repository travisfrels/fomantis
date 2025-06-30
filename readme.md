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

## Test the analyze-sentiment and analzye-profanity Functions

```bash
curl http://analyze-sentiment-service.default.127.0.0.1.sslip.io -v -k -H "Content-Type: application/json" -d "{ \"data\": { \"comment\": \"I love Knative\" } }"
curl http://analyze-profanity-service.default.127.0.0.1.sslip.io -v -k -H "Content-Type: application/json" -d "{ \"data\": { \"comment\": \"I love Knative\" } }"
```

