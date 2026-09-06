#!/bin/bash
 
echo "=== Cockpit ==="
docker compose -f docker-compose-eparvier-cockpit.yml down
 
echo "=== API ==="
docker compose -f docker-compose-eparvier-api.yml down
 
echo "=== Mongo ==="
docker compose -f docker-compose-eparvier-mongo.yml down
 
echo "EPARVIER arrêté."
