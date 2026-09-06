#!/bin/bash
set -euo pipefail

# Usage:
#   Rebase-dans-REPO-local.sh [REPO_DIR] [FINAL_BRANCH]
# Examples:
#   Rebase-dans-REPO-local.sh /home/bamalvict/EPARVIER/EPARVIER SynyheseTotal-KING1
#   Rebase-dans-REPO-local.sh /home/bamalvict/EPARVIER/EPARVIER
#   Rebase-dans-REPO-local.sh

# 1) Détection du repo (argument > env REPO_DIR > autodétection relative > fallback)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_REPO="$HOME/EPARVIER"
REPO_DIR="${1:-${REPO_DIR:-$DEFAULT_REPO}}"

# 2) Branche finale (argument 2 ou interactive fallback)
BRANCH_ARG="${2:-}"
if [ -n "$BRANCH_ARG" ]; then
  FINAL_BRANCH="$BRANCH_ARG"
else
  read -p "Entrez le nom de la branche finale (ou appuyez sur Entrée pour utiliser la branche courante) : " FINAL_BRANCH
  FINAL_BRANCH="${FINAL_BRANCH:-}"
fi

# 3) Aller dans le repo
cd "$REPO_DIR" || { echo "Repo introuvable: $REPO_DIR"; exit 1; }
echo "Répertoire courant: $(pwd)"

# 4) Vérifications préalables
if [ -n "$(git status --porcelain)" ]; then
  echo "Working tree non propre. Fais git add && git commit avant de lancer ce script."
  git status --porcelain
  exit 1
fi

# 5) Déterminer la branche courante si nécessaire
if [ -z "$FINAL_BRANCH" ]; then
  FINAL_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
fi
echo "Branche finale choisie: $FINAL_BRANCH"

# 6) Détecter upstream main vs master sur origin
UPSTREAM=""
if git ls-remote --exit-code --heads origin main >/dev/null 2>&1; then
  UPSTREAM="origin/main"
elif git ls-remote --exit-code --heads origin master >/dev/null 2>&1; then
  UPSTREAM="origin/master"
fi
echo "Upstream détecté: ${UPSTREAM:-(aucun main/master trouvé)}"

# 7) Création / sélection de la branche finale localement
git checkout -B "$FINAL_BRANCH"

# 8) Récupération distante
git fetch origin

# 9) Rebase si upstream détecté
if [ -n "$UPSTREAM" ]; then
  echo "Rebase de $FINAL_BRANCH sur $UPSTREAM (avec autostash)"
  git rebase --autostash "$UPSTREAM" || {
    echo "!!! Conflits détectés pendant le rebase."
    echo "Résous les conflits puis exécute : git rebase --continue"
    exit 1
  }
else
  echo "Aucun upstream main/master détecté sur origin — pas de rebase automatique."
fi

# 10) Push sécurisé
echo "Push de $FINAL_BRANCH vers origin (force-with-lease)"
git push origin "$FINAL_BRANCH" --force-with-lease

echo "=== FINI ==="
echo "Branche '$FINAL_BRANCH' mise à jour et poussée."