#!/bin/bash

start_api() {
    echo "[EPARVIER] Démarrage API..."
    docker compose -f /home/EPARVIER/docker-compose.yml up -d solaizeapi
}

start_cockpit() {
    echo "[EPARVIER] Démarrage Cockpit..."
    docker compose -f /home/EPARVIER/docker-compose.yml up -d solaizeCockpit
}

main() {
    start_api
    start_cockpit
    echo "[EPARVIER] API + COCKPIT démarrés."
}

main

