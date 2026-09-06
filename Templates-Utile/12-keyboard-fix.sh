#!/bin/bash

# ============================================================
# 🧠 BernardOps — Fix clavier Ubuntu (VMware + GNOME)
# ============================================================

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

echo -e "${YELLOW}🔧 Correction du clavier Ubuntu (VMware + GNOME)...${RESET}"

# 1) Désactiver Sticky Keys (touches rémanentes)
echo -e "${BLUE}➡️ Désactivation des touches rémanentes...${RESET}"
gsettings set org.gnome.desktop.a11y.keyboard stickykeys-enable false

# 2) Verrouiller layout clavier en FR uniquement
echo -e "${BLUE}➡️ Verrouillage du layout clavier en FR...${RESET}"
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'fr')]"

# 3) Désactiver la mémorisation NumLock / CapsLock virtuelle
echo -e "${BLUE}➡️ Neutralisation NumLock/CapsLock virtuels...${RESET}"
gsettings set org.gnome.desktop.peripherals.keyboard remember-numlock-state false
gsettings set org.gnome.desktop.peripherals.keyboard numlock-state false

# 4) Vérifier si Caps Lock virtuel est actif
LED=$(xset q | grep "LED mask" | awk '{print $3}')

if [ "$LED" = "00000002" ]; then
    echo -e "${YELLOW}⚠️ Caps Lock virtuel détecté → correction...${RESET}"
    xdotool key Caps_Lock
else
    echo -e "${GREEN}✔ Aucun Caps Lock virtuel détecté${RESET}"
fi

# 5) Vérifier si Shift virtuel est bloqué (cas VMware)
echo -e "${BLUE}➡️ Vérification Shift virtuel...${RESET}"
xdotool keyup Shift_L
xdotool keyup Shift_R

echo -e "${GREEN}✔ Clavier stabilisé !${RESET}"
echo -e "${GREEN}✔ Layout FR verrouillé${RESET}"
echo -e "${GREEN}✔ Sticky Keys désactivées${RESET}"
echo -e "${GREEN}✔ Caps/Shift virtuels neutralisés${RESET}"

echo -e "${YELLOW}🔐 Tu peux maintenant taper ton mot de passe sans galère.${RESET}"
