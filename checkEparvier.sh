#!/bin/bash

check_images() {
    echo "[EPARVIER] Vérification des images..."
    docker images | grep solaizeapi || echo "Image solaizeapi manquante"
    docker images | grep solaizeCockpit || echo "Image solaizeCockpit manquante"
}

check_containers() {
    echo "[EPARVIER] Vérification des conteneurs..."
    docker ps -a | grep solaizeapi
    docker ps -a | grep solaizeCockpit
}

main() {
    check_images
    check_containers
    echo "[EPARVIER] Vérifications terminées."
}

main
