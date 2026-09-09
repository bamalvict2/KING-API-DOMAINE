#!/bin/bash

echo "=== 📡 STATUS NETWORKING ==="

echo "➡ tailscale status :"
tailscale status

echo "➡ tailscale netcheck :"
tailscale netcheck

echo "=== Fin du status NETWORKING ==="
