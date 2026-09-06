#!/bin/bash

echo "[EPARVIER] Build SolaizeCockpit..."

GIT_HASH=$(git rev-parse --short HEAD)

# Build Shared
dotnet build ../Solaize.Shared/Solaize.Shared.csproj -c Release

# Build Docker image
docker build -f ../Dockerfile.Cockpit -t solaizecockpit:$GIT_HASH .

# Tag latest
docker tag solaizecockpit:$GIT_HASH solaizecockpit:latest

echo "[EPARVIER] SolaizeCockpit build OK → version $GIT_HASH"
