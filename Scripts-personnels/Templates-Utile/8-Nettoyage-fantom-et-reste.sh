#!/bin/bash

# --- Fonction de point d'arrêt fiable ---
pause_action() {
    read -r -p "⏸ Continuer cette action ? (o/N) : " confirm </dev/tty
    if [[ "$confirm" != "o" ]]; then
        echo "⛔ Action annulée"
        return 1
    fi
    return 0
}

echo ""
echo "🧹 KING‑AO FULL CLEAN — Mode interactif"
echo "----------------------------------------"

###############################################
# 1) Nettoyage HGFS (VMware)
###############################################
echo ""
echo "🔍 Vérification HGFS..."

mounted=$(mount | grep hgfs | awk '{print $3}')
real=$(vmware-hgfsclient)
hgfs_clean=1

for m in $mounted; do
    if [ "$m" = "/mnt/hgfs" ]; then
        continue
    fi

    name=$(basename "$m")

    if ! echo "$real" | grep -q "$name"; then
        echo "⚠️  HGFS phantom trouvé : $name"
        echo "→ Action : démonter et supprimer $m"

        if pause_action; then
            sudo umount -lf "$m"
            sudo rm -rf "$m"
        fi

        hgfs_clean=0
    fi
done

if [ $hgfs_clean -eq 1 ]; then
    echo "✔ HGFS clean"
fi


###############################################
# 2) Nettoyage /mnt (orphelins)
###############################################
echo ""
echo "🔍 Vérification /mnt..."

mnt_clean=1

for d in /mnt/*; do
    if [ "$d" = "/mnt/hgfs" ]; then
        continue
    fi

    if [ -d "$d" ] && ! mount | grep -q "$d"; then
        echo "⚠️  Orphelin trouvé : $(basename "$d")"
        echo "→ Action : suppression de $d"

        if pause_action; then
            sudo rm -rf "$d"
        fi

        mnt_clean=0
    fi
done

if [ $mnt_clean -eq 1 ]; then
    echo "✔ /mnt clean"
fi


###############################################
# 3) Nettoyage Nautilus (bookmarks invalides)
###############################################
echo ""
echo "🔍 Vérification Nautilus..."

bookmarks="$HOME/.config/gtk-3.0/bookmarks"
nautilus_clean=1

if [ -f "$bookmarks" ]; then
    tmp=$(mktemp)
    while IFS= read -r line; do
        if [[ "$line" == file://* ]]; then
            path=$(echo "$line" | sed 's|file://||')
            if [ ! -e "$path" ]; then
                echo "⚠️  Nautilus ghost : $line"
                echo "→ Action : suppression du bookmark"

                if pause_action; then
                    nautilus_clean=0
                    continue
                fi
            fi
        fi
        echo "$line" >> "$tmp"
    done < "$bookmarks"

    mv "$tmp" "$bookmarks"
fi

if [ $nautilus_clean -eq 1 ]; then
    echo "✔ Nautilus clean"
fi

nautilus -q 2>/dev/null


###############################################
# 4) Nettoyage HOME (espaces finaux)
###############################################
echo ""
echo "🔍 Vérification HOME..."

home_clean=1
phantoms=$(find "$HOME" -maxdepth 1 -name "* " -print)

if [[ -n "$phantoms" ]]; then
    echo "⚠️  Fantômes HOME détectés :"
    echo "$phantoms"
    echo "→ Action : renommer automatiquement"

    if pause_action; then
        while IFS= read -r f; do
            new=$(echo "$f" | sed 's/ *$//')
            mv "$f" "$new"
        done <<< "$phantoms"
    fi

    home_clean=0
fi

if [ $home_clean -eq 1 ]; then
    echo "✔ HOME clean"
fi


###############################################
# 5) Résultat final
###############################################
echo ""
echo "🏰 KING‑AO FULL CLEAN terminé."
echo "Tout le château est propre."
echo ""
