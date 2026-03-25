#!/bin/bash

#===============================================================================
# AFRIKTECK - Script de diagnostic des problèmes de boot Proxmox
#===============================================================================

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== DIAGNOSTIC DES PROBLÈMES DE BOOT PROXMOX ===${NC}"
echo ""

# 1. Vérification du kernel actuel
echo -e "${YELLOW}1. Kernel actuel:${NC}"
uname -r
if uname -r | grep -q "pve"; then
    echo -e "${GREEN}✓ Kernel PVE détecté${NC}"
else
    echo -e "${RED}✗ Kernel standard (non-PVE)${NC}"
fi
echo ""

# 2. Vérification des kernels installés
echo -e "${YELLOW}2. Kernels installés:${NC}"
dpkg -l | grep -E "(pve-kernel|proxmox-kernel)" || echo "Aucun kernel PVE trouvé"
echo ""

# 3. Configuration GRUB
echo -e "${YELLOW}3. Configuration GRUB:${NC}"
grep "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub
echo ""

# 4. Vérification de la configuration réseau
echo -e "${YELLOW}4. Configuration réseau:${NC}"
if grep -q "cycle found involving iface vmbr0" /var/log/ifupdown2/*/ifupdown2.debug.log 2>/dev/null; then
    echo -e "${RED}✗ Erreur de cycle détectée dans la configuration réseau${NC}"
    echo "Fichier /etc/network/interfaces:"
    cat /etc/network/interfaces
else
    echo -e "${GREEN}✓ Pas d'erreur de cycle réseau détectée${NC}"
fi
echo ""

# 5. Logs de boot récents
echo -e "${YELLOW}5. Erreurs dans les logs de boot récents:${NC}"
journalctl -b -0 --no-pager | grep -i -E "(error|fail|panic)" | head -5
echo ""

# 6. État des services Proxmox
echo -e "${YELLOW}6. Services Proxmox:${NC}"
for service in pvedaemon pveproxy pve-cluster; do
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        echo -e "${GREEN}✓ $service: actif${NC}"
    else
        echo -e "${RED}✗ $service: inactif${NC}"
    fi
done
echo ""

# 7. Recommandations
echo -e "${BLUE}=== RECOMMANDATIONS ===${NC}"
if ! uname -r | grep -q "pve"; then
    echo -e "${YELLOW}• Redémarrer sur le kernel PVE depuis GRUB${NC}"
fi

if grep -q "cycle found involving iface vmbr0" /var/log/ifupdown2/*/ifupdown2.debug.log 2>/dev/null; then
    echo -e "${YELLOW}• Corriger la configuration réseau dans /etc/network/interfaces${NC}"
fi

echo -e "${YELLOW}• Vérifier les logs: journalctl -b -1${NC}"
echo -e "${YELLOW}• En cas de blocage au boot: ajouter 'nomodeset' aux paramètres GRUB${NC}"
