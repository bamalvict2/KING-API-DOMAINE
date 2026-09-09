#!/bin/bash

# ============================================
# EPARVIER — BUILD SCRIPT (modulaire KING‑AO)
# ============================================

build_api() {
    echo "[EPARVIER] Build de l'image SolaizeAPI..."
    docker build -t solaizeapi /home/EPARVIER/SolaizeAPI
}

build_cockpit() {
    echo "[EPARVIER] Build de l'image SolaizeCockpit..."
    docker build -t solaizeCockpit /home/EPARVIER/SolaizeCockpit
}

main() {
    build_api
    build_cockpit
    echo "[EPARVIER] ET [COCKPIT] Images construites."
}

main
