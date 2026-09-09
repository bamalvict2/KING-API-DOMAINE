#!/bin/bash

# ================================
#  Vérification du clavier
# ================================
echo "🔍 Vérification de la configuration du clavier..."
localectl status | grep -i "Layout"

echo ""
echo "Si tu veux changer le clavier, par exemple en FR :"
echo "sudo localectl set-x11-keymap fr"
echo ""

# ================================
#  Changement du hostname
# ================================
echo "🖥️ Changement du hostname"

read -p "➡️  Entre le nouveau hostname : " NEW_HOSTNAME

if [ -z "$NEW_HOSTNAME" ]; then
    echo "❌ Aucun hostname fourni. Abandon."
    exit 1
fi

echo "➡️ Nouveau hostname demandé : $NEW_HOSTNAME"

# Modification du hostname
sudo hostnamectl set-hostname "$NEW_HOSTNAME"

# Mise à jour de /etc/hosts
sudo sed -i "s/127.0.1.1.*/127.0.1.1   $NEW_HOSTNAME/" /etc/hosts

echo "✅ Hostname changé avec succès !"
echo "🔁 Un redémarrage est recommandé pour appliquer partout."
