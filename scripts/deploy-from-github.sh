#!/bin/bash

#===============================================================================
# AFRIKTECK Proxmox Deployment Script - GitHub Integration
# 
# Propriété intellectuelle: AFRIKTECK - Datacenter Solutions
# Copyright: © 2024 AFRIKTECK - Tous droits réservés
# Contact: contact@afrikteck.com
#
# Ce script permet le déploiement automatique de Proxmox depuis GitHub
#===============================================================================

# Configuration
readonly GITHUB_REPO="https://raw.githubusercontent.com/afrikteck/proxmox-installation-guide/main"
readonly SCRIPT_VERSION="1.0.0"
readonly TEMP_DIR="/tmp/afrikteck-proxmox-deploy"

# Couleurs
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
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

info() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')] INFO: $1${NC}"
}

# Banner AFRIKTECK
show_banner() {
    clear
    echo "==============================================================================="
    echo "                    AFRIKTECK Proxmox Remote Deployment"
    echo "                         Version $SCRIPT_VERSION"
    echo "                    Datacenter Solutions - Libreville, Gabon"
    echo "                              afrikteck.com"
    echo "==============================================================================="
    echo ""
}

# Vérification des prérequis
check_prerequisites() {
    log "Vérification des prérequis..."
    
    # Vérification root
    if [[ $EUID -ne 0 ]]; then
        error "Ce script doit être exécuté en tant que root"
        exit 1
    fi
    
    # Vérification de la connectivité Internet
    if ! ping -c 1 github.com &>/dev/null; then
        error "Pas de connexion Internet - Impossible d'accéder à GitHub"
        exit 1
    fi
    
    # Installation des outils nécessaires
    if ! command -v curl &>/dev/null; then
        log "Installation de curl..."
        apt update && apt install -y curl
    fi
    
    if ! command -v wget &>/dev/null; then
        log "Installation de wget..."
        apt install -y wget
    fi
    
    log "Prérequis vérifiés avec succès"
}

# Téléchargement des scripts depuis GitHub
download_scripts() {
    log "Téléchargement des scripts AFRIKTECK depuis GitHub..."
    
    # Création du répertoire temporaire
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    # Téléchargement du script principal
    log "Téléchargement du script d'installation principal..."
    curl -fsSL "$GITHUB_REPO/scripts/install-proxmox.sh" -o install-proxmox.sh || {
        error "Échec du téléchargement du script principal"
        exit 1
    }
    
    # Téléchargement du script de configuration
    log "Téléchargement du script de configuration..."
    curl -fsSL "$GITHUB_REPO/scripts/configure-proxmox.sh" -o configure-proxmox.sh || {
        error "Échec du téléchargement du script de configuration"
        exit 1
    }
    
    # Vérification de l'intégrité (signature AFRIKTECK)
    if ! grep -q "AFRIKTECK" install-proxmox.sh; then
        error "Script principal corrompu ou non authentique"
        exit 1
    fi
    
    # Permissions d'exécution
    chmod +x *.sh
    
    log "Scripts téléchargés et vérifiés avec succès"
}

# Vérification de la version Debian
check_debian_version() {
    log "Vérification de la compatibilité Debian..."
    
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        local debian_version=$VERSION_ID
        
        case $debian_version in
            "11"|"12"|"13")
                info "Debian $debian_version ($VERSION_CODENAME) détecté - Compatible"
                ;;
            *)
                warn "Debian $debian_version détecté - Compatibilité non garantie"
                read -p "Continuer malgré tout ? (y/N): " continue_anyway
                if [[ ! $continue_anyway =~ ^[Yy]$ ]]; then
                    exit 1
                fi
                ;;
        esac
    else
        error "Impossible de détecter la version Debian"
        exit 1
    fi
}

# Sauvegarde du système avant installation
backup_system() {
    log "Création d'une sauvegarde système..."
    
    local backup_dir="/root/backup-pre-proxmox-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Sauvegarde des fichiers critiques
    cp /etc/network/interfaces "$backup_dir/" 2>/dev/null || true
    cp /etc/hosts "$backup_dir/" 2>/dev/null || true
    cp /etc/hostname "$backup_dir/" 2>/dev/null || true
    cp -r /etc/apt/sources.list* "$backup_dir/" 2>/dev/null || true
    
    # Liste des paquets installés
    dpkg --get-selections > "$backup_dir/packages.list"
    
    log "Sauvegarde créée dans: $backup_dir"
}

# Exécution de l'installation
run_installation() {
    log "Lancement de l'installation Proxmox VE..."
    
    # Exécution du script principal
    if [[ -f "$TEMP_DIR/install-proxmox.sh" ]]; then
        log "Exécution du script d'installation AFRIKTECK..."
        bash "$TEMP_DIR/install-proxmox.sh"
    else
        error "Script d'installation non trouvé"
        exit 1
    fi
}

# Configuration post-installation
run_configuration() {
    log "Lancement de la configuration post-installation..."
    
    # Attendre que Proxmox soit complètement installé
    if command -v pvesh &>/dev/null; then
        if [[ -f "$TEMP_DIR/configure-proxmox.sh" ]]; then
            log "Exécution du script de configuration AFRIKTECK..."
            bash "$TEMP_DIR/configure-proxmox.sh"
        else
            warn "Script de configuration non trouvé - Configuration manuelle requise"
        fi
    else
        info "Proxmox non encore installé - Configuration reportée"
    fi
}

# Nettoyage
cleanup() {
    log "Nettoyage des fichiers temporaires..."
    rm -rf "$TEMP_DIR"
    log "Nettoyage terminé"
}

# Affichage des informations finales
show_final_info() {
    echo ""
    echo "==============================================================================="
    echo "                    DÉPLOIEMENT TERMINÉ - AFRIKTECK"
    echo "==============================================================================="
    echo ""
    echo "Le déploiement Proxmox VE AFRIKTECK est terminé."
    echo ""
    echo "Informations importantes:"
    echo "• Interface Web: https://$(hostname -I | awk '{print $1}'):8006"
    echo "• Utilisateur: root"
    echo "• Mot de passe: [mot de passe root actuel]"
    echo ""
    echo "Documentation complète disponible sur:"
    echo "• GitHub: https://github.com/afrikteck/proxmox-installation-guide"
    echo "• Site web: https://afrikteck.com"
    echo ""
    echo "Support technique:"
    echo "• Email: contact@afrikteck.com"
    echo "• Issues GitHub: https://github.com/afrikteck/proxmox-installation-guide/issues"
    echo ""
    echo "© 2024 AFRIKTECK - Datacenter Solutions, Libreville, Gabon"
    echo "Propriété intellectuelle AFRIKTECK - Tous droits réservés"
    echo "==============================================================================="
}

# Fonction principale
main() {
    show_banner
    
    info "Démarrage du déploiement automatique Proxmox VE depuis GitHub"
    info "Repository: https://github.com/afrikteck/proxmox-installation-guide"
    echo ""
    
    # Étapes du déploiement
    check_prerequisites
    check_debian_version
    backup_system
    download_scripts
    
    # Confirmation avant installation
    echo ""
    warn "ATTENTION: Cette installation va modifier votre système"
    read -p "Continuer l'installation Proxmox VE ? (y/N): " confirm_install
    
    if [[ $confirm_install =~ ^[Yy]$ ]]; then
        run_installation
        run_configuration
        cleanup
        show_final_info
    else
        info "Installation annulée par l'utilisateur"
        cleanup
        exit 0
    fi
}

# Gestion des erreurs et interruptions
trap 'error "Installation interrompue"; cleanup; exit 130' INT TERM
trap 'error "Erreur ligne $LINENO: $BASH_COMMAND"; cleanup; exit 1' ERR

# Point d'entrée
main "$@"

#===============================================================================
# FIN DU SCRIPT DE DÉPLOIEMENT AFRIKTECK
#===============================================================================
