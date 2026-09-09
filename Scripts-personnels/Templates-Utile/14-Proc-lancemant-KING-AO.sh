 #!/usr/bin/env bash

# ============================
#  MENU COCKPIT 1-9
# ============================

pause() {
    echo ""
    read -p "⏸  Appuie sur ENTER pour continuer..."
}

build_image() {
    echo "🔧 Build de l'image Docker..."
    docker build -t kingao/app .
    echo "✔ Build terminé"
    pause
}

check_image() {
    echo "🔍 Vérification des images existantes..."
    docker images | grep kingao
    echo "✔ Vérification terminée"
    pause
}

run_container() {
    echo "🚀 Lancement du conteneur..."
    docker compose up -d
    echo "✔ Conteneur lancé"
    pause
}

logs_container() {
    echo "📜 Logs du conteneur..."
    docker compose logs --tail=50
    pause
}

stop_container() {
    echo "🛑 Arrêt du conteneur..."
    docker compose down
    echo "✔ Conteneur arrêté"
    pause
}

rebuild_full() {
    echo "♻ Reconstruction complète..."
    docker compose down
    docker compose build --no-cache
    docker compose up -d
    echo "✔ Reconstruction complète OK"
    pause
}

menu() {
    clear
    echo "=============================="
    echo "   COCKPIT KING-AO 1 → 9"
    echo "=============================="
    echo "1) Build image"
    echo "2) Vérifier image"
    echo "3) Lancer conteneur"
    echo "4) Logs"
    echo "5) Stop conteneur"
    echo "6) Rebuild complet"
    echo "9) Quitter"
    echo "=============================="
    echo ""
}

while true; do
    menu
    read -p "Sélection : " choice
    case $choice in
        1) build_image ;;
        2) check_image ;;
        3) run_container ;;
        4) logs_container ;;
        5) stop_container ;;
        6) rebuild_full ;;
        9) echo "👋 Fin du cockpit"; exit 0 ;;
        *) echo "❌ Choix invalide"; pause ;;
    esac
done
