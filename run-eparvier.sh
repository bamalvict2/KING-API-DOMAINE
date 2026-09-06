#!/bin/bash
 
set -e
 
echo "=== Mongo ==="
docker compose -f docker-compose-eparvier-mongo.yml up -d
 
echo "=== API ==="
docker compose -f docker-compose-eparvier-api.yml up -d
 
echo "=== Cockpit ==="
docker compose -f docker-compose-eparvier-cockpit.yml up -d
 
echo "EPARVIER démarré avec succès."