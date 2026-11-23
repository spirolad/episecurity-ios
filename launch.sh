#!/usr/bin/env bash
set -e

# Navigate to the project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ENV_FILE=".env.docker"

# Ensure .env.docker exists, copy from .env.docker.example if missing
if [ ! -f "$ENV_FILE" ]; then
    if [ -f ".env.docker.example" ]; then
        echo "Info: $ENV_FILE not found. Creating $ENV_FILE from .env.docker.example..."
        cp .env.docker.example "$ENV_FILE"
    else
        echo "Error: Neither $ENV_FILE nor .env.docker.example was found!" >&2
        exit 1
    fi
fi

# If no arguments provided, default to starting with build
if [ $# -eq 0 ]; then
    echo "Starting EpiBrother Docker containers with $ENV_FILE..."
    exec docker compose --env-file "$ENV_FILE" up --build
else
    exec docker compose --env-file "$ENV_FILE" "$@"
fi
