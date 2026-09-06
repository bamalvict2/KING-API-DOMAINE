#!/bin/bash

# ───────────────────────────────────────────────
#  VMWARE DIRECT (SANS SOUS-MENU)
# ───────────────────────────────────────────────

vmware_direct() {
    echo "──────────────────────────────────────────────"
    echo " Vérification des partages VMware"
    echo "──────────────────────────────────────────────"

    # Si rien n'est monté → on monte automatiquement
    if [ -z "$(ls -A /mnt/hgfs 2>/dev/null)" ]; then
        echo "Aucun partage VMware détecté."
        echo "Montage en cours..."
        sudo vmhgfs-fuse -o allow_other /mnt/hgfs
        echo "Montage terminé."
    fi

    echo "──────────────────────────────────────────────"
    echo " Partages VMware (noms + permissions) :"
    echo "──────────────────────────────────────────────"

    ls -ld /mnt/hgfs/* 2>/dev/null | awk '{print $1, $9}'

    echo "──────────────────────────────────────────────"
    echo " Retour au menu KING‑AO"
    echo "──────────────────────────────────────────────"
}

# ───────────────────────────────────────────────
#  COPIE WINDOWS → UBUNTU
# ───────────────────────────────────────────────

copier_windows_vers_ubuntu() {
    echo "──────────────────────────────────────────────"
    echo " Vérification du montage Nana4"
    echo "──────────────────────────────────────────────"

    if [ -z "$(ls -A /mnt/hgfs/Nana4 2>/dev/null)" ]; then
        echo "⚠️  Nana4 est vide ou non monté ! Import annulé."
        return
    fi

    echo "──────────────────────────────────────────────"
    echo " Copie Windows → /opt/Nana4"
    echo "──────────────────────────────────────────────"
    sudo cp -r /mnt/hgfs/Nana4/* /opt/Nana4/

    echo "──────────────────────────────────────────────"
    echo " Vérification du contenu importé"
    echo "──────────────────────────────────────────────"
    ls -l /opt/Nana4
}

# ───────────────────────────────────────────────
#  DÉZIPPER KING‑AO (strip-components)
# ───────────────────────────────────────────────

dezipper_nana4() {
    echo "──────────────────────────────────────────────"
    echo " Décompression du backup KING-AO"
    echo "──────────────────────────────────────────────"

    if ! ls /opt/Nana4/Backup-KING-AO-*.tar.gz 1>/dev/null 2>&1; then
        echo "⚠️ Aucun backup KING-AO trouvé dans /opt/Nana4"
        return
    fi

    sudo tar --strip-components=1 -xvzf /opt/Nana4/Backup-KING-AO-*.tar.gz -C /opt/Nana4

    echo "──────────────────────────────────────────────"
    echo " Permissions"
    echo "──────────────────────────────────────────────"
    sudo chown -R $USER:$USER /opt/Nana4

    echo "──────────────────────────────────────────────"
    echo " Arborescence KING-AO"
    echo "──────────────────────────────────────────────"

    if command -v tree >/dev/null 2>&1; then
        tree /opt/Nana4
    else
        echo "Installez 'tree' avec : sudo apt install tree -y"
    fi
}

# ───────────────────────────────────────────────
#  LIMITER À 5 SAUVEGARDES
# ───────────────────────────────────────────────

limiter_sauvegardes_nana4() {
    echo "──────────────────────────────────────────────"
    echo " Limitation à 5 sauvegardes"
    echo "──────────────────────────────────────────────"

    sauvegardes=( $(ls -1t /mnt/hgfs/Nana4/Backup-KING-AO-*.tar.gz 2>/dev/null) )
    total=${#sauvegardes[@]}

    if [ "$total" -le 5 ]; then
        echo "Il y a $total sauvegardes, rien à supprimer."
        return
    fi

    for (( i=5; i<total; i++ )); do
        echo "Suppression : ${sauvegardes[$i]}"
        rm -f "${sauvegardes[$i]}"
    done

    echo "──────────────────────────────────────────────"
    echo " 5 sauvegardes conservées"
    echo "──────────────────────────────────────────────"
}

# ───────────────────────────────────────────────
#  MENU KING‑AO FINAL (1‑2‑3‑4‑0)
# ───────────────────────────────────────────────

while true; do
    echo ""
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║        MENU KING‑AO – Flux W11 → Ubuntu (Nana4)      ║"
    echo "╠══════════════════════════════════════════════════════╣"
    echo "1) Vérifier / Monter VMware (direct)"
    echo "2) Copier Windows → Ubuntu (avec étapes)"
    echo "3) Dézipper KING-AO (avec étapes)"
    echo "4) Garder 5 sauvegardes max dans Nana4 (supprimer N-6)"
    echo "0) Quitter"
    echo "╚══════════════════════════════════════════════════════╝"
    echo -n "Votre choix : "
    read choix

    case $choix in
        1) vmware_direct ;;
        2) copier_windows_vers_ubuntu ;;
        3) dezipper_nana4 ;;
        4) limiter_sauvegardes_nana4 ;;
        0) echo "Au revoir Bernard."; exit 0 ;;
        *) echo "Choix invalide." ;;
    esac
done
