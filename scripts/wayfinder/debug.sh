#!/usr/bin/env bash
set -o errexit

helm install minnow ../../chart  --force --namespace wayfinder --set komodor-agent.apiKey=$KOMOKW_API_KEY --set komodor-agent.clusterName=wayfinder-demo --dry-run --debug
