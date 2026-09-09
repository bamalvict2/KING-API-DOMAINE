#!/usr/bin/env bash
# micro-helper.sh
# Petit script interactif pour :
# - créer ~/.config/micro (mkdir -p)
# - installer un settings.json basique
# - vérifier le chemin courant et lister les fichiers
# - afficher les fichiers récents, stat d'un fichier, rechercher des fichiers
# Usage: chmod +x micro-helper.sh && ./micro-helper.sh

CONFIG_DIR="$HOME/.config/micro"
SETTINGS_FILE="$CONFIG_DIR/settings.json"
DEFAULT_SETTINGS='{
  "tabsize": 2,
  "softwrap": true,
  "autosu": true,
  "syntax": "yaml",
  "backup": false,
  "mouse": true,
  "statusline": true,
  "ruler": false,
  "showwhitespace": false
}'

function pause() {
  read -r -p "Appuie sur Entrée pour continuer..."
}

function create_config_dir() {
  echo "Création du dossier de config : $CONFIG_DIR"
  mkdir -p "$CONFIG_DIR" && echo "OK : $CONFIG_DIR créé (ou existait déjà)."
  ls -ld "$CONFIG_DIR"
  pause
}

function install_settings() {
  echo "Installation de $SETTINGS_FILE"
  mkdir -p "$CONFIG_DIR"
  cat > "$SETTINGS_FILE" <<'JSON'
'"$DEFAULT_SETTINGS"'
JSON
  # Le here-doc ci‑dessous remplace correctement le contenu JSON
  # (on réécrit proprement en utilisant printf pour éviter l'expansion)
  printf '%s\n' "$DEFAULT_SETTINGS" > "$SETTINGS_FILE"
  echo "Fichier écrit : $SETTINGS_FILE"
  stat --format="Modifié : %y  Taille : %s bytes" "$SETTINGS_FILE" 2>/dev/null || ls -l "$SETTINGS_FILE"
  pause
}

function verify_path_and_list() {
  echo "Chemin courant (pwd) :"
  pwd
  echo
  echo "Liste des fichiers (ls -la) :"
  ls -la
  pause
}

function show_recent_files() {
  echo "5 fichiers les plus récents dans le dossier courant :"
  ls -lh --sort=time | head -n 10
  pause
}

function stat_file() {
  read -r -p "Nom du fichier à inspecter (ex: docker-compose.yml) : " f
  if [ -z "$f" ]; then echo "Aucun fichier fourni."; pause; return; fi
  if [ -e "$f" ]; then
    stat "$f"
  else
    echo "Fichier introuvable : $f"
  fi
  pause
}

function find_by_name() {
  read -r -p "Nom à rechercher (ex: docker-compose*.yml) : " pattern
  if [ -z "$pattern" ]; then echo "Aucun motif fourni."; pause; return; fi
  echo "Recherche de '$pattern' depuis le dossier courant..."
  find . -name "$pattern"
  pause
}

function grep_content() {
  read -r -p "Texte à rechercher dans les fichiers (ex: services:) : " txt
  if [ -z "$txt" ]; then echo "Aucun texte fourni."; pause; return; fi
  echo "Recherche récursive de '$txt' :"
  grep -R --line-number --color=auto "$txt" .
  pause
}

function create_system_dir() {
  read -r -p "Chemin système à créer (ex: /etc/monapp) : " sysdir
  if [ -z "$sysdir" ]; then echo "Aucun chemin fourni."; pause; return; fi
  echo "Création de $sysdir avec sudo (si nécessaire)..."
  sudo mkdir -p "$sysdir" && echo "OK : $sysdir créé."
  ls -ld "$sysdir"
  pause
}

function open_with_micro() {
  read -r -p "Fichier à ouvrir avec micro (chemin relatif ou absolu) : " mf
  if [ -z "$mf" ]; then echo "Aucun fichier fourni."; pause; return; fi
  micro "$mf"
}

while true; do
  clear
  cat <<'MENU'
Micro Helper - Menu
1) Créer ~/.config/micro
2) Installer settings.json par défaut
3) Vérifier chemin courant et lister fichiers (pwd, ls -la)
4) Afficher fichiers récents
5) Stat d'un fichier (stat)
6) Rechercher des fichiers par nom (find)
7) Rechercher du contenu dans les fichiers (grep)
8) Créer un répertoire système (sudo mkdir -p)
9) Ouvrir un fichier avec micro
0) Quitter
MENU
  read -r -p "Choix : " choice
  case "$choice" in
    1) create_config_dir ;;
    2) install_settings ;;
    3) verify_path_and_list ;;
    4) show_recent_files ;;
    5) stat_file ;;
    6) find_by_name ;;
    7) grep_content ;;
    8) create_system_dir ;;
    9) open_with_micro ;;
    0) echo "Au revoir."; exit 0 ;;
    *) echo "Choix invalide." ; pause ;;
  esac
done