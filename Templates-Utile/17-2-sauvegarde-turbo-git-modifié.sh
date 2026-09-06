#!/bin/bash

# ============================
#   🧠 BernardOps — Git Cockpit PRO MAX
# ============================
   # Pense bête
   # git remote -v
   # git branch -vv
   # git status --short
   # git log --oneline --graph --decorate --all
   # git add -A
   # git commit -m "Message de commit"
   # git push -u origin $(git branch --show-current)
   
   #git remote set-url origin git@github.com:bamalvict2/RIEUX-KINGAO.git

   # git pull origin $(git branch --show-current)
   # git fetch origin
   # git merge origin/$(git branch --show-current)
   # git branch --merged
   # git branch --no-merged
   # git remote add origin <url>
   # git remote set-url origin <url>

# ============================

# Vérifier si on est dans un dépôt Git
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "❌ Ce dossier n'est pas un dépôt Git."
    exit 1
fi

repo_root=$(git rev-parse --show-toplevel)
echo "📁 Dépôt détecté : $repo_root"
echo ""

# Couleurs
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# ============================
#   🔧 Fonctions utilitaires
# ============================

pause() {
  echo ""
  read -p "Appuie sur Entrée pour continuer..." tmp
  echo ""
}

ask_yes_no() {
  local prompt="$1"
  local answer
  read -p "$prompt (y/n) : " answer
  case "$answer" in
    y|Y|yes|YES) return 0 ;;
    n|N|no|NO) return 1 ;;
    *) echo "❌ Réponse invalide."; return 2 ;;
  esac
}

# ============================
#   📡 Sous-menu Remote
# ============================

remote_menu() {
  while true; do
    echo -e "${CYAN}📡 MENU REMOTES${RESET}"
    echo "────────────────────────────────────────────"
    echo -e "${GREEN}1)${RESET} Lister les remotes"
    echo -e "${GREEN}2)${RESET} Ajouter un remote"
    echo -e "${GREEN}3)${RESET} Modifier l'URL d'un remote"
    echo -e "${GREEN}4)${RESET} Définir une URL de push différente"
    echo -e "${GREEN}5)${RESET} Renommer un remote"
    echo -e "${GREEN}6)${RESET} Supprimer un remote"
    echo -e "${GREEN}7)${RESET} Fetch depuis un remote"
    echo -e "${GREEN}8)${RESET} Pousser une branche vers un remote"
    echo -e "${GREEN}9)${RESET} Pruner les références distantes"
    echo -e "${YELLOW}b)${RESET} Retour au menu principal"
    echo "────────────────────────────────────────────"

    read -p "👉 Choisis une option remote : " rchoice

    case "$rchoice" in
      1) git remote -v ;;
      2)
        read -p "Nom du remote : " rname
        read -p "URL du remote : " rurl
        git remote add "$rname" "$rurl"
        ;;
      3)
        git remote -v
        read -p "Nom du remote : " rname
        read -p "Nouvelle URL : " newurl
        git remote set-url "$rname" "$newurl"
        ;;
      4)
        git remote -v
        read -p "Nom du remote : " rname
        read -p "URL de push : " pushurl
        git remote set-url --push "$rname" "$pushurl"
        ;;
      5)
        git remote -v
        read -p "Ancien nom : " oldname
        read -p "Nouveau nom : " newname
        git remote rename "$oldname" "$newname"
        ;;
      6)
        git remote -v
        read -p "Nom du remote : " rname
        git remote remove "$rname"
        ;;
      7)
        git remote -v
        read -p "Nom du remote : " rname
        git fetch "$rname"
        ;;

      8)        
        git branch -vv
        read -p "Nom du remote : " rname
        read -p "Branche locale : " branch

        echo -n "Définir l'upstream (ENTER = non, URL/branche = oui) : "
        read upstream

        if [[ -z "$upstream" ]]; then
        # Pas d’upstream → push normal
          git push "$rname" "$branch"
        else
          # Upstream automatique
          git push -u "$rname" "$branch"
        fi
        ;;

      9)
        git remote -v
        read -p "Nom du remote : " rname
        git remote prune "$rname"
        ;;
      b|B) break ;;
      *) echo "❌ Option inconnue." ;;
    esac

    pause
  done
}

# ============================
#   ⚡ MENU TURBO
# ============================

turbo_menu() {
  while true; do
    echo -e "${YELLOW}⚡ MODE TURBO — BernardOps${RESET}"
    echo "────────────────────────────────────────────"
    echo -e "${GREEN}1)${RESET} Turbo Push"
    echo -e "${GREEN}2)${RESET} Turbo Pull"
    echo -e "${GREEN}3)${RESET} Turbo Sync"
    echo -e "${GREEN}4)${RESET} Turbo Status"
    echo -e "${GREEN}5)${RESET} Turbo Commit"
    echo -e "${GREEN}6)${RESET} Turbo Branch Creator"
    echo -e "${GREEN}7)${RESET} Turbo Clean"
    echo -e "${GREEN}8)${RESET} Turbo Merge"
    echo -e "${GREEN}9)${RESET} Turbo Deploy"
    echo -e "${GREEN}10)${RESET} Turbo Backup"
    echo -e "${GREEN}11)${RESET} Turbo Fix"
    echo -e "${GREEN}12)${RESET} Turbo Restore"
    echo -e "${YELLOW}b)${RESET} Retour au menu principal"
    echo "────────────────────────────────────────────"

    read -p "👉 Choisis une option turbo : " tchoice

    case "$tchoice" in
      1) turbo_push ;;
      2) turbo_pull ;;
      3) turbo_sync ;;
      4) turbo_status ;;
      5) turbo_commit ;;
      6) turbo_branch_creator ;;
      7) turbo_clean ;;
      8) turbo_merge ;;
      9) turbo_deploy ;;
      10) turbo_backup ;;
      11) turbo_fix ;;
      12) turbo_restore ;;
      b|B) return ;;
      *) echo "❌ Option inconnue." ;;
    esac

    pause
  done
}


# ============================
#   ⚡ FONCTIONS UTILITAIRES
# ============================

check_ssh_key() {
  if ! ssh-add -l >/dev/null 2>&1; then
    echo "❌ Aucune clé SSH chargée !"
    echo "👉 Charge ta clé : ssh-add ~/.ssh/id_ed25519_SOLAIZE"
    return 1
  fi
  return 0
}

fix_remote_if_https() {
  remote="$1"
  url=$(git remote get-url "$remote")

  if [[ "$url" == https* ]]; then
    echo "⚠️ Remote HTTPS détecté → conversion automatique en SSH"
    ssh_url="git@github.com:${url#https://github.com/}"
    git remote set-url "$remote" "$ssh_url"
    echo "🔁 Remote converti : $ssh_url"
  fi
}

# ============================
#   ⚡ TURBO PUSH
# ============================

turbo_push() {
  branch=$(git branch --show-current)
  remote=$(git remote | head -n 1)

  echo "🚀 TURBO PUSH"
  echo "📌 Branche : $branch"
  echo "📡 Remote : $remote"

  check_ssh_key || return
  fix_remote_if_https "$remote"

  git push -u "$remote" "$branch"
  echo "✅ Turbo Push terminé."
}

# ============================
#   ⚡ TURBO PULL
# ============================

turbo_pull() {
  branch=$(git branch --show-current)
  remote=$(git remote | head -n 1)

  echo "⬇️ TURBO PULL"
  echo "📌 Branche : $branch"
  echo "📡 Remote : $remote"

  check_ssh_key || return
  fix_remote_if_https "$remote"

  git pull "$remote" "$branch"
  echo "✅ Turbo Pull terminé."
}

# ============================
#   ⚡ TURBO SYNC
# ============================

turbo_sync() {
  branch=$(git branch --show-current)
  remote=$(git remote | head -n 1)

  echo "🔁 TURBO SYNC"
  echo "📌 Branche : $branch"
  echo "📡 Remote : $remote"

  check_ssh_key || return
  fix_remote_if_https "$remote"

  git pull "$remote" "$branch"
  git push "$remote" "$branch"

  echo "✅ Turbo Sync terminé."
}

# ============================
#   📊 TURBO STATUS
# ============================

turbo_status() {
  echo "📊 TURBO STATUS"
  git status --short
}

# ============================
#   📝 TURBO COMMIT
# ============================

turbo_commit() {
  echo "📝 TURBO COMMIT"
  git status --short

  # Vérification modifications
  if git diff --quiet && git diff --cached --quiet; then
    echo "⚠️ Rien à commit."
    return
  fi

  read -p "Message de commit rapide : " msg

  if [[ -z "$msg" ]]; then
    echo "❌ Message vide → commit annulé."
    return
  fi

  git add -A
  git commit -m "$msg"

  branch=$(git branch --show-current)
  remote=$(git remote | head -n 1)

  check_ssh_key || return
  fix_remote_if_https "$remote"

  echo "⬆️ Push automatique..."
  git push "$remote" "$branch"

  echo "✅ Turbo Commit terminé."
}

# ============================
#   🌱 TURBO BRANCH CREATOR
# ============================

turbo_branch_creator() {
  echo "🌱 TURBO BRANCH CREATOR"
  read -p "Nom de la nouvelle branche : " newb

  git checkout -b "$newb"

  remote=$(git remote | head -n 1)
  fix_remote_if_https "$remote"

  git push -u "$remote" "$newb"

  echo "✅ Branche '$newb' créée et poussée."
}

# ============================
#   🧹 TURBO CLEAN
# ============================

turbo_clean() {
  echo "🧹 TURBO CLEAN — Nettoyage avancé"

  current=$(git branch --show-current)

  echo "🧽 Suppression des branches locales fusionnées..."
  git branch --merged | grep -v "$current" | grep -v "\*" | while read b; do
    echo "🗑️ Suppression locale : $b"
    git branch -d "$b"
  done

  echo "🧽 Nettoyage des branches distantes obsolètes..."
  remote=$(git remote | head -n 1)
  git remote prune "$remote"

  echo "✅ Turbo Clean terminé."
}

# ============================
#   🔀 TURBO MERGE
# ============================

turbo_merge() {
  echo "🔀 TURBO MERGE — Fusion Express"

  current=$(git branch --show-current)
  echo "📌 Branche actuelle : $current"
  git branch

  read -p "Fusionner quelle branche dans $current ? " src

  if ! git show-ref --verify --quiet "refs/heads/$src"; then
    echo "❌ La branche '$src' n'existe pas."
    return
  fi

  git merge "$src"

  if [ $? -ne 0 ]; then
    echo "⚠️ Conflits détectés ! Résous-les puis commit."
    return
  fi

  echo "✅ Fusion réussie."

  read -p "⬆️ Pousser la fusion ? (y/n) : " pushok
  case "$pushok" in
    y|Y|yes|YES)
      remote=$(git remote | head -n 1)
      fix_remote_if_https "$remote"
      git push "$remote" "$current"
      echo "🚀 Fusion poussée."
      ;;
    *)
      echo "⏭️ Push annulé."
      ;;
  esac
}

# ============================
#   🚀 TURBO DEPLOY
# ============================

turbo_deploy() {
  echo "🚀 TURBO DEPLOY — Déploiement automatique"
  echo "────────────────────────────────────────────"

  echo "1) Lancer deploy.sh local"
  echo "2) Déployer via SSH"
  echo "3) Docker Compose (up -d)"
  echo "4) Docker Compose (pull + up)"
  echo "b) Retour"
  echo ""

  read -p "👉 Choisis une option deploy : " dchoice

  case "$dchoice" in
    1)
      if [ -f "./deploy.sh" ]; then
        chmod +x ./deploy.sh
        ./deploy.sh
        echo "✅ Déploiement local terminé."
      else
        echo "❌ Aucun fichier deploy.sh trouvé."
      fi
      ;;
    2)
      read -p "Adresse SSH (ex: user@serveur) : " sshaddr
      read -p "Commande à exécuter sur le serveur : " sshcmd
      ssh "$sshaddr" "$sshcmd"
      echo "✅ Déploiement SSH terminé."
      ;;
    3)
      docker compose up -d
      echo "🐳 Docker lancé."
      ;;
    4)
      docker compose pull
      docker compose up -d
      echo "🐳 Docker mis à jour et relancé."
      ;;
    b|B) return ;;
    *) echo "❌ Option inconnue." ;;
  esac
}

# ============================
#   💾 TURBO BACKUP
# ============================

turbo_backup() {
  echo "💾 TURBO BACKUP — Sauvegarde rapide"
  echo "────────────────────────────────────────────"

  ts=$(date +"%Y-%m-%d_%H-%M-%S")
  backup_dir="backup_$ts"

  mkdir "$backup_dir"
  git archive --format=tar HEAD | gzip > "$backup_dir/repo.tar.gz"

  echo "📦 Sauvegarde créée dans : $backup_dir/repo.tar.gz"
  echo "✅ Turbo Backup terminé."
}

# ============================
#   🛠️ TURBO FIX
# ============================

turbo_fix() {
  echo "🛠️ TURBO FIX — Résolution automatique des conflits"
  echo "────────────────────────────────────────────"

  echo "1) Garder version locale (ours)"
  echo "2) Garder version distante (theirs)"
  echo "3) Auto-merge si possible"
  echo "b) Retour"
  echo ""

  read -p "👉 Choisis une option fix : " fchoice

  case "$fchoice" in
    1)
      git checkout --ours .
      git add .
      echo "🐻 Version locale conservée."
      ;;
    2)
      git checkout --theirs .
      git add .
      echo "🌍 Version distante conservée."
      ;;
    3)
      git merge --strategy-option=ours
      git merge --strategy-option=theirs
      echo "🤖 Tentative d’auto-merge effectuée."
      ;;
    b|B) return ;;
    *) echo "❌ Option inconnue." ;;
  esac

  echo "📌 Termine avec : git commit"
}

# ============================
#   ♻️ TURBO RESTORE
# ============================

turbo_restore() {
  echo "♻️ TURBO RESTORE — Retour rapide"
  echo "────────────────────────────────────────────"

  echo "1) Revenir au commit précédent (HEAD~1)"
  echo "2) Revenir à un commit précis"
  echo "3) Revenir à un tag"
  echo "4) Restaurer depuis un stash"
  echo "b) Retour"
  echo ""

  read -p "👉 Choisis une option restore : " rchoice

  case "$rchoice" in
    1)
      git reset --hard HEAD~1
      echo "↩️ Retour à HEAD~1 effectué."
      ;;
    2)
      read -p "ID du commit : " cid
      git reset --hard "$cid"
      echo "↩️ Restauré au commit $cid."
      ;;
    3)
      git tag
      read -p "Nom du tag : " tag
      git checkout "$tag"
      echo "🏷️ Restauré au tag $tag."
      ;;
    4)
      git stash list
      read -p "Numéro du stash (ex: stash@{0}) : " st
      git stash apply "$st"
      echo "📦 Stash restauré."
      ;;
    b|B) return ;;
    *) echo "❌ Option inconnue." ;;
  esac
}







# ============================
#   🧭 Menu principal
# ============================

while true; do
  echo -e "${CYAN}🧭 MENU GIT BERNARDOPS PRO MAX${RESET}"
  echo "────────────────────────────────────────────"
  echo -e "${GREEN}1)${RESET} Voir fichiers modifiés / non suivis"
  echo -e "${GREEN}2)${RESET} Voir statut Git complet"
  echo -e "${GREEN}3)${RESET} Voir les 5 derniers commits"
  echo -e "${GREEN}4)${RESET} Voir log graphique"
  echo -e "${YELLOW}5)${RESET} Ajouter + Commit"
  echo -e "${YELLOW}6)${RESET} Nettoyer les branches locales fusionnées"
  echo -e "${YELLOW}7)${RESET} Fusionner une branche"
  echo -e "${CYAN}8)${RESET} Menu Remote"
  echo -e "${YELLOW}15)${RESET} Mode Turbo"
  echo -e "${RED}0)${RESET} Quitter"
  echo "────────────────────────────────────────────"

  read -p "👉 Choisis une option : " choix

  case "$choix" in

    1)
      echo "📦 Fichiers modifiés / non suivis :"
      git status --short
      ;;

    2)
      echo "📊 Statut Git complet :"
      git status
      ;;

    3)
      echo "🧾 Derniers commits :"
      git log -n 5 --oneline --graph --decorate
      ;;

    4)
      echo "📈 Log graphique :"
      git log --oneline --graph --decorate --all
      ;;

    5)
      git status --short
      ask_yes_no "Ajouter et committer ?"
      if [ $? -eq 0 ]; then
        git add -A
        read -p "Message de commit : " msg
        git commit -m "$msg"
        echo "✅ Commit effectué."
      fi
      ;;

    6)
      current=$(git branch --show-current)
      echo "🧹 Nettoyage des branches fusionnées dans $current"
      git branch --merged | grep -v "\*" | grep -v "$current" | while read b; do
        echo "🗑️ Suppression : $b"
        git branch -d "$b"
      done
      echo "✅ Nettoyage terminé."
      ;;

    7)
      current=$(git branch --show-current)
      echo "📍 Branche actuelle : $current"
      git branch
      read -p "Fusionner quelle branche dans $current ? " src
      git merge "$src"
      ;;

    8)
      remote_menu
      ;;

    15)
      turbo_menu
      ;;

    0)
      echo "🧠 BernardOps terminé. Bon vol, Bernard 🐅"
      exit 0
      ;;

    *)
      echo "❌ Option inconnue."
      ;;
  esac

  pause
done
 
 



