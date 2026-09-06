#!/bin/bash

COMPOSE_FILE="/opt/KING-AO/modules/EPARVIER/compose/docker-compose.yml"

pause() {
    read -p "⏸️  Appuie sur Entrée pour continuer..."
}

menu() {
    clear
    echo "=========================================="
    echo "🚀 MENU COCKPIT — WORKFLOW EPARVIER"
    echo "=========================================="
    echo "1) Vérifier l'état Git"
    echo "2) Créer un commit (générer hash)"
    echo "3) Récupérer le hash Git"
    echo "4) Build de l'image Docker"
    echo "5) Tag de l'image avec le hash"
    echo "6) Mettre à jour le docker-compose.yml"
    echo "7) Lancer EPARVIER (docker compose up)"
    echo "8) Workflow complet automatique"
    echo "0) Quitter"
    echo "------------------------------------------"
    read -p "👉 Choix : " CHOICE
}

while true; do
    menu

    case $CHOICE in

        1)
            echo "🔍 Vérification Git..."
            git status
            pause
            ;;

        2)
            echo "📝 Création du commit (hash Git)..."
            git add -A
            git commit -m "METIER-API-COCKPIT"
            echo "✔ Commit créé."
            pause
            ;;

        3)
            echo "🔢 Récupération du hash Git..."
            GIT_TAG=$(git rev-parse --short HEAD)
            echo "➡ Hash : $GIT_TAG"
            pause
            ;;

        4)
            echo "🏗 Build de l'image Docker..."
            docker build -t eparvier-metier:build .
            echo "✔ Build terminé."
            pause
            ;;

        5)
            echo "🏷 Tag de l'image..."
            GIT_TAG=$(git rev-parse --short HEAD)
            docker tag eparvier-metier:build eparvier-metier:$GIT_TAG
            echo "✔ Image taggée : eparvier-metier:$GIT_TAG"
            pause
            ;;

        6)
            echo "🛠 Mise à jour du compose..."
            GIT_TAG=$(git rev-parse --short HEAD)
            sed -i "s|image: eparvier-metier:.*|image: eparvier-metier:$GIT_TAG|g" $COMPOSE_FILE
            echo "✔ Compose mis à jour avec : $GIT_TAG"
            pause
            ;;

        7)
            echo "🚀 Lancement EPARVIER..."
            docker compose -f $COMPOSE_FILE up -d
            echo "✔ EPARVIER lancé."
            pause
            ;;

        8)
            echo "⚙️ Workflow complet automatique..."
            git add -A
            git commit -m "METIER-API-COCKPIT"
            GIT_TAG=$(git rev-parse --short HEAD)
            docker build -t eparvier-metier:build .
            docker tag eparvier-metier:build eparvier-metier:$GIT_TAG
            sed -i "s|image: eparvier-metier:.*|image: eparvier-metier:$GIT_TAG|g" $COMPOSE_FILE
            docker compose -f $COMPOSE_FILE up -d
            echo "✔ Workflow complet terminé."
            pause
            ;;

        0)
            echo "👋 Sortie cockpit."
            exit 0
            ;;

        *)
            echo "❌ Choix invalide."
            pause
            ;;
    esac
done
