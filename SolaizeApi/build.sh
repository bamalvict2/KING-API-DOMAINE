#!/bin/bash

echo "[EPARVIER] Build SolaizeApi..."

# Hash Git pour versionner l'image
GIT_HASH=$(git rev-parse --short HEAD)

# Build Shared (obligatoire)
dotnet build ../Solaize.Shared/Solaize.Shared.csproj -c Release

# Publish API
dotnet publish -c Release -o out

# Build Docker image
docker build -f ../Dockerfile.Api -t solaizeapi:$GIT_HASH .

# Tag latest
docker tag solaizeapi:$GIT_HASH solaizeapi:latest

echo "[EPARVIER] SolaizeApi build OK → version $GIT_HASH"

