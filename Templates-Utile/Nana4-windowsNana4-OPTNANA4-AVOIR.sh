#!/bin/bash
set -e

# ────────────────────────────────────────────────────────────────
# 🧠 BernardOps – Import Windows 11 → Ubuntu (Nana4)
# ────────────────────────────────────────────────────────────────

MOUNT_ROOT="/mnt/hgfs"
SHARE_NAME="Nana4"
SRC_WIN="$MOUNT_ROOT/$SHARE_NAME"
DEST_UBU="/opt/Nana4"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

banner() {
  clear
  echo -e "${CYAN}╔══════════════════════════════════════════════════════╗"
  echo -e "║ 🧠  BernardOps – Import Windows → Ubuntu (Nana4)     ║"
  echo -e "║ 📅  $(date '+%Y-%m-%d %H:%M')                         ║"
  echo -e "╚══════════════════════════════════════════════════════╝${NC}"
}

step() { echo -e "${CYAN}➡️  $1${NC}"; }
ok()   { echo -e "${GREEN}✔️  $1${NC}"; }
err()  { echo -e "${RED}❌  $1${NC}"; }

# ────────────────────────────────────────────────
# 1) MONTER TOUS LES PARTAGES VMWARE
# ────────────────────────────────────────────────

mount_all_vmware() {
  step "Montage automatique de tous les partages VMware"

  SHARES=$(vmware-hgfsclient)

  if [ -z "$SHARES" ]; then
    err "Aucun partage VMware détecté !"
    read -p "Appuie sur Entrée..."
    return 1
  fi

  sudo mkdir -p "$MOUNT_ROOT"

  for SHARE in $SHARES; do
    TARGET="$MOUNT_ROOT/$SHARE"
    echo "➡️  Montage : $SHARE → $TARGET"

    sudo mkdir -p "$TARGET"
    sudo mount -t fuse.vmhgfs-fuse ".host:/$SHARE" "$TARGET" -o allow_other 2>/dev/null

    if mountpoint -q "$TARGET"; then
      echo "✔️  Monté : $TARGET"
    else
      echo "❌  Échec du montage : $SHARE"
    fi
    echo
  done

  ok "Tous les partages VMware ont été montés."
  read -p "Appuie sur Entrée..."
}

# ────────────────────────────────────────────────
# 2) DÉMONTER TOUS LES PARTAGES VMWARE
# ────────────────────────────────────────────────

unmount_all_vmware() {
  step "Démontage de tous les partages VMware"

  if [ ! -d "$MOUNT_ROOT" ]; then
    err "Le dossier $MOUNT_ROOT n'existe pas."
    read -p "Appuie sur Entrée..."
    return 1
  fi

  for DIR in "$MOUNT_ROOT"/*; do
    [ -d "$DIR" ] || continue

    if mountpoint -q "$DIR"; then
      echo "➡️  Démontage : $DIR"
      sudo umount "$DIR" 2>/dev/null

      if mountpoint -q "$DIR"; then
        echo "❌  Échec du démontage : $DIR"
      else
        echo "✔️  Démonté : $DIR"
      fi
    fi
  done

  ok "Tous les partages VMware ont été démontés."
  read -p "Appuie sur Entrée..."
}

# ────────────────────────────────────────────────
# 3) NETTOYER LES DOSSIERS VIDES
# ────────────────────────────────────────────────

clean_empty_dirs() {
  step "Nettoyage des dossiers vides dans $MOUNT_ROOT"

  find "$MOUNT_ROOT" -mindepth 1 -type d -empty -print -delete

  ok "Nettoyage terminé."
  read -p "Appuie sur Entrée..."
}

# ────────────────────────────────────────────────
# 4) REMONTAGE PROPRE (DÉMONTER + MONTER)
# ────────────────────────────────────────────────

remount_vmware() {
  step "Remontage propre des partages VMware"
  unmount_all_vmware
  clean_empty_dirs
  mount_all_vmware
}

# ────────────────────────────────────────────────
# 5) IMPORT WINDOWS → UBUNTU (NANA4)
# ────────────────────────────────────────────────

check_windows_folder() {
  step "Vérification du dossier Windows"

  if [ ! -d "$SRC_WIN" ]; then
    err "Le dossier Windows $SRC_WIN n'existe pas !"
    read -p "Appuie sur Entrée..."
    return 1
  fi

  ok "Dossier Windows trouvé"
  read -p "Appuie sur Entrée..."
}

reset_ubuntu_folder() {
  step "Préparation du dossier Ubuntu Nana4"
  sudo rm -rf "$DEST_UBU"
  sudo mkdir -p "$DEST_UBU"
  ok "Dossier Ubuntu prêt"
  read -p "Appuie sur Entrée..."
}

copy_win_to_ubuntu() {
  step "Copie Windows → Ubuntu"
  sudo cp -r "$SRC_WIN/"* "$DEST_UBU/"
  ok "Import terminé"
  read -p "Appuie sur Entrée..."
}

full_import() {
  remount_vmware || return
  check_windows_folder || return
  reset_ubuntu_folder
  copy_win_to_ubuntu
  echo -e "${GREEN}🎉 Import Windows → Ubuntu (Nana4) terminé avec succès !${NC}"
  read -p "Appuie sur Entrée..."
}

# ────────────────────────────────────────────────
# 6) NETTOYER LE DOSSIER WINDOWS NANA4 (AVEC SUDO)
# ────────────────────────────────────────────────

clean_windows_nana4() {
  step "Nettoyage du dossier Windows Nana4"

  if [ ! -d "$SRC_WIN" ]; then
    err "Le dossier Windows $SRC_WIN n'existe pas ou n'est pas monté !"
    read -p "Appuie sur Entrée..."
    return 1
  fi

  echo -e "${RED}⚠️ ATTENTION : Cette action va VIDER le dossier Windows Nana4 !${NC}"
  echo -e "${YELLOW}Cela supprimera tous les fichiers dans : $SRC_WIN${NC}"
  read -p "Écris OUI pour confirmer : " confirm

  if [ "$confirm" = "OUI" ]; then
    sudo rm -rf "$SRC_WIN"/*
    ok "Dossier Windows Nana4 vidé."
  else
    err "Nettoyage annulé."
  fi

  read -p "Appuie sur Entrée..."
}

# ────────────────────────────────────────────────
# MENU
# ────────────────────────────────────────────────

menu() {
  banner
  echo -e "${YELLOW}Que veux‑tu faire ?${NC}"
  echo "1) Monter TOUS les partages VMware"
  echo "2) Démonter TOUS les partages VMware"
  echo "3) Nettoyer les dossiers vides"
  echo "4) Remontage propre (démonter + monter)"
  echo "5) Vérifier le dossier Windows"
  echo "6) Réinitialiser le dossier Ubuntu Nana4"
  echo "7) Copier Windows → Ubuntu"
  echo "8) Import complet (toutes étapes)"
  echo "9) Vider le dossier Windows Nana4"
  echo "0) Quitter"
  echo -n "> "
  read choice

  case $choice in
    1) mount_all_vmware ;;
    2) unmount_all_vmware ;;
    3) clean_empty_dirs ;;
    4) remount_vmware ;;
    5) check_windows_folder ;;
    6) reset_ubuntu_folder ;;
    7) copy_win_to_ubuntu ;;
    8) full_import ;;
    9) clean_windows_nana4 ;;
    0) exit 0 ;;
    *) echo -e "${RED}Option invalide${NC}" ;;
  esac

  echo -e "${YELLOW}Appuie sur Entrée pour revenir au menu...${NC}"
  read
  menu
}

menu
