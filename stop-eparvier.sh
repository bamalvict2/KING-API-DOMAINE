#!/bin/bash

stop_api() {
    echo "[EPARVIER] Arrêt API..."
    docker compose -f /home/EPARVIER/docker-compose.yml stop solaizeapi
}

stop_cockpit() {
    echo "[EPARVIER] Arrêt Cockpit..."
    docker compose -f /home/EPARVIER/docker-compose.yml stop solaizeCockpit
}

main() {
    stop_api
    stop_cockpit
    echo "[EPARVIER] API + COCKPIT arrêtés."
}

main
