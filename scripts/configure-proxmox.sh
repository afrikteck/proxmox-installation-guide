#!/bin/bash

#===============================================================================
# AFRIKTECK Proxmox Configuration Script
# 
# Propriété intellectuelle: AFRIKTECK - Datacenter Solutions
# Copyright: © 2024 AFRIKTECK - Tous droits réservés
# Contact: contact@afrikteck.com
#===============================================================================

# Variables de configuration
readonly SCRIPT_VERSION="1.0.0"
readonly COMPANY="AFRIKTECK"

# Couleurs
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')] WARN: $1${NC}"
}

error() {
    echo -e "${RED}[$(date '+%H:%M:%S')] ERROR: $1${NC}"
}

# Suppression de la notification de souscription
remove_subscription_notice() {
    log "Suppression de la notification de souscription..."
    
    local js_file="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"
    
    if [[ -f "$js_file" ]]; then
        cp "$js_file" "${js_file}.backup.$(date +%Y%m%d)"
        sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" "$js_file"
        log "Notification de souscription supprimée"
    else
        warn "Fichier JavaScript Proxmox non trouvé"
    fi
}

# Configuration des templates de conteneurs
setup_container_templates() {
    log "Configuration des templates de conteneurs..."
    
    # Téléchargement des templates populaires
    local templates=(
        "debian-12-standard"
        "ubuntu-22.04-standard"
        "alpine-3.18-default"
    )
    
    for template in "${templates[@]}"; do
        log "Téléchargement du template: $template"
        pveam update
        pveam available | grep "$template" | head -1 | awk '{print $2}' | xargs -r pveam download local
    done
}

# Configuration du stockage
configure_storage() {
    log "Configuration du stockage..."
    
    # Création d'un répertoire pour les ISOs
    mkdir -p /var/lib/vz/template/iso
    
    # Configuration des permissions
    chown -R root:www-data /var/lib/vz/
    chmod -R 755 /var/lib/vz/
    
    log "Stockage configuré"
}

# Configuration des utilisateurs et groupes
setup_users() {
    log "Configuration des utilisateurs Proxmox..."
    
    # Création du groupe AFRIKTECK
    pveum group add afrikteck-admins -comment "Administrateurs AFRIKTECK"
    
    # Configuration des permissions
    pveum acl modify / -group afrikteck-admins -role Administrator
    
    log "Groupes d'utilisateurs configurés"
}

# Optimisations système
system_optimizations() {
    log "Application des optimisations système..."
    
    # Configuration du swappiness
    echo "vm.swappiness=10" >> /etc/sysctl.conf
    
    # Configuration des limites de fichiers
    echo "* soft nofile 65536" >> /etc/security/limits.conf
    echo "* hard nofile 65536" >> /etc/security/limits.conf
    
    # Application immédiate
    sysctl -p
    
    log "Optimisations appliquées"
}

# Configuration du monitoring
setup_monitoring() {
    log "Configuration du monitoring..."
    
    # Installation de htop et iotop
    apt install -y htop iotop nethogs
    
    # Configuration des alertes email (basique)
    cat > /etc/cron.d/proxmox-monitoring << 'EOF'
# Monitoring AFRIKTECK Proxmox
*/5 * * * * root /usr/bin/pvesh get /nodes/$(hostname)/status | grep -q '"status":"online"' || echo "Proxmox node $(hostname) offline" | mail -s "AFRIKTECK Alert: Proxmox Offline" contact@afrikteck.com
EOF
    
    log "Monitoring configuré"
}

# Sauvegarde de la configuration
backup_config() {
    log "Sauvegarde de la configuration..."
    
    local backup_dir="/root/afrikteck-backup-$(date +%Y%m%d)"
    mkdir -p "$backup_dir"
    
    # Sauvegarde des fichiers de configuration
    cp -r /etc/pve "$backup_dir/"
    cp /etc/network/interfaces "$backup_dir/"
    cp /etc/hosts "$backup_dir/"
    
    # Création d'un script de restauration
    cat > "$backup_dir/restore.sh" << 'EOF'
#!/bin/bash
# Script de restauration AFRIKTECK
echo "Restauration de la configuration Proxmox..."
cp -r pve /etc/
cp interfaces /etc/network/
cp hosts /etc/
echo "Restauration terminée - Redémarrage requis"
EOF
    
    chmod +x "$backup_dir/restore.sh"
    
    log "Sauvegarde créée dans: $backup_dir"
}

# Fonction principale
main() {
    echo "==============================================================================="
    echo "                AFRIKTECK Proxmox Configuration Script v$SCRIPT_VERSION"
    echo "                        Datacenter Solutions - Libreville, Gabon"
    echo "==============================================================================="
    echo ""
    
    # Vérification des privilèges
    if [[ $EUID -ne 0 ]]; then
        error "Ce script doit être exécuté en tant que root"
        exit 1
    fi
    
    # Vérification que Proxmox est installé
    if ! command -v pvesh &> /dev/null; then
        error "Proxmox VE n'est pas installé"
        exit 1
    fi
    
    log "Début de la configuration post-installation..."
    
    # Exécution des configurations
    remove_subscription_notice
    setup_container_templates
    configure_storage
    setup_users
    system_optimizations
    setup_monitoring
    backup_config
    
    echo ""
    echo "==============================================================================="
    echo "                    CONFIGURATION TERMINÉE - AFRIKTECK"
    echo "==============================================================================="
    echo "Toutes les configurations ont été appliquées avec succès."
    echo ""
    echo "Prochaines étapes recommandées:"
    echo "1. Redémarrer le système: reboot"
    echo "2. Accéder à l'interface web: https://$(hostname -I | awk '{print $1}'):8006"
    echo "3. Créer vos premières VMs/Conteneurs"
    echo ""
    echo "© 2024 AFRIKTECK - Datacenter Solutions"
    echo "Propriété intellectuelle AFRIKTECK - afrikteck.com"
    echo "==============================================================================="
}

# Gestion des erreurs
trap 'error "Erreur ligne $LINENO"; exit 1' ERR

# Lancement
main "$@"
