#!/bin/bash

echo "🔍 Pré-vol EPARVIER PRO"
echo "------------------------"

docker ps --format "table {{.Names}}\t{{.Status}}"

echo ""
echo "✔️ Vérification terminée."

