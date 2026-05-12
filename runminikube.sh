#!/bin/bash

status_minikube() {
  status=$(minikube status --format='{{.Host}}')

  if [ "$status" == "Running" ]; then
    echo "✅ Minikube is running"
  else
    echo "❌ Minikube is NOT running"
  fi
}


start_minikube() {
  echo "Checking Docker daemon..."

  if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Attempting to start Docker..."

    # Try Linux (systemd)
    if command -v systemctl > /dev/null 2>&1; then
      sudo systemctl start docker
    # Fallback for Mac
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      open -a Docker
    else
      echo "⚠️ Unable to determine how to start Docker automatically."
      exit 1
    fi

    echo "⏳ Waiting for Docker to start..."
    sleep 10

    # Recheck Docker
    if ! docker info > /dev/null 2>&1; then
      echo "❌ Failed to start Docker. Please start it manually."
      exit 1
    fi

    echo "✅ Docker started successfully"
  else
    echo "✅ Docker is already running"
  fi

  echo "Starting Minikube..."
  minikube delete --all && minikube start --driver=docker --vm=true
}


# ---- Argument Handling ----
case "$1" in
  start)
    start_minikube
    ;;
  status)
    status_minikube
    ;;

    echo "Usage: $0 {start|status|clean}"
    exit 1
    ;;
esac