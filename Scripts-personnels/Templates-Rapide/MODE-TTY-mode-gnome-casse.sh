#!/bin/bash

SCRIPT="BernardOps.sh"

if [[ ! -f "$SCRIPT" ]]; then
    echo "❌ BernardOps.sh introuvable."
    exit 1
fi

echo "=== BernardOps V6.2 - Mode TTY ==="
echo "1) Sauvegarde"
echo "2) Restauration"
echo "3) Lister"
echo "4) Check"
echo "5) Quitter"
read c

case "$c" in
    1) ./$SCRIPT --mode CLI ;;
    2)
        echo -n "Archive : "; read a
        echo -n "Destination : "; read d
        ./$SCRIPT --mode CLI --restore "$a" "$d"
        ;;
    3) ./$SCRIPT --list ;;
    4) ./$SCRIPT --check ;;
    5) exit 0 ;;
esac
