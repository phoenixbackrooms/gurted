#!/bin/bash

echo "Building Gurted Search Engine Server..."

echo "Stopping existing container..."
docker compose down

echo "Building Docker image..."
docker compose build --no-cache --parallel

echo "Starting services..."
docker compose up -d

echo "Container logs (press Ctrl+C to stop following):"
docker compose logs -f search-engine