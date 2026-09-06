#!/bin/bash

# ───────────────────────────────────────────────
# 🧭 BernardOps – Archive modules → HOME → SAVE-KING-AO
# ───────────────────────────────────────────────

# Dossiers à sauvegarder (chemins réels)
ROOT_DIR="/opt/KING-AO"
CSHARP_DIR="/home/$USER/Nana2"

T3_DIRS=(
    "$ROOT_DIR"
    "/etc"
    "$CSHARP_DIR"
)

ARCHIVE_NAME="T3-Modules-Backup-$(date '+%Y%m%d-%H%M').tar.gz"
ARCHIVE_PATH="$HOME/$ARCHIVE_NAME"

MOUNT_POINT="/mnt/SAVE-KING-AO"
SHARE_NAME=".host:/SAVE-KING-AO"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

step() { echo -e "${CYAN}➡️  $1${NC}"; }
ok()   { echo -e "${GREEN}✔️  $1${NC}"; }
err()  { echo -e "${RED}❌  $1${NC}"; exit 1; }
pause(){ echo -e "${YELLOW}⏸️  Appuie sur Entrée pour continuer...${NC}"; read; }

# DEBUG : afficher les chemins
step "DEBUG : Vérification des chemins"
echo "ROOT_DIR      = $ROOT_DIR"
echo "NANA2         = $CSHARP_DIR"
echo "ARCHIVE_PATH  = $ARCHIVE_PATH"
echo "MOUNT_POINT   = $MOUNT_POINT"
pause

# 1️⃣ Création de l’archive
step "Création de l’archive des modules dans HOME"
sudo tar -czf "$ARCHIVE_PATH" --ignore-failed-read "${T3_DIRS[@]}" \
  || err "Échec de la création de l’archive"
ok "Archive créée : $ARCHIVE_PATH"
pause

# 2️⃣ Préparation du point de montage
step "Préparation du point de montage"
sudo mkdir -p "$MOUNT_POINT" || err "Impossible de créer $MOUNT_POINT"
ok "Point de montage prêt"
pause

# 3️⃣ Montage du partage Windows
step "Montage du dossier partagé Windows"

if mountpoint -q "$MOUNT_POINT"; then
    ok "Déjà monté"
else
    sudo mount -t fuse.vmhgfs-fuse "$SHARE_NAME" "$MOUNT_POINT" \
      -o allow_other,uid=$(id -u),gid=$(id -g) \
      || err "Impossible de monter le partage Windows"
    ok "Partage Windows monté"
fi
pause

# 4️⃣ Copie vers Windows
step "Copie de l’archive vers Windows"
sudo cp "$ARCHIVE_PATH" "$MOUNT_POINT/" \
  || err "Échec de la copie vers Windows"
ok "Archive copiée dans Windows : $MOUNT_POINT/$ARCHIVE_NAME"
pause

echo -e "${GREEN}🎉 Sauvegarde T3 (modules) terminée avec succès !${NC}"
