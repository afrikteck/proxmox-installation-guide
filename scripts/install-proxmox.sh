#!/bin/bash

#===============================================================================
# AFRIKTECK Proxmox VE Auto-Installation Script
# 
# Propriété intellectuelle: AFRIKTECK - Datacenter Solutions
# Copyright: © 2026 AFRIKTECK - Tous droits réservés
# Société: AFRIKTECK, Libreville, Gabon
# Site web: afrikteck.com
# Contact: contact@afrikteck.com
#
# AVERTISSEMENT LÉGAL: Ce script est la propriété intellectuelle d'AFRIKTECK.
# Toute utilisation, modification ou distribution DOIT conserver ces mentions
# sous peine de poursuites légales.
#
# Attribution requise: "Basé sur les travaux d'AFRIKTECK (afrikteck.com)"
#===============================================================================

# Configuration des variables globales
readonly SCRIPT_VERSION="1.0.0"
readonly SCRIPT_NAME="AFRIKTECK Proxmox Auto-Installer"
readonly COMPANY="AFRIKTECK - Datacenter Solutions"
readonly LOCATION="Libreville, Gabon"
readonly WEBSITE="afrikteck.com"
readonly CONTACT_EMAIL="contact@afrikteck.com"

# Variables de configuration système
DEBIAN_VERSION=""
DEBIAN_CODENAME=""
PROXMOX_VERSION=""
PROXMOX_REPO_URL=""
GPG_KEY_URL=""
KERNEL_VERSION=""
NETWORK_INTERFACE=""
STATIC_IP=""
GATEWAY_IP=""
HOSTNAME_FQDN=""

# Couleurs pour l'affichage
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

#===============================================================================
# FONCTIONS UTILITAIRES
#===============================================================================

# Affichage du banner AFRIKTECK
show_banner() {
    clear
    echo -e "${PURPLE}===============================================================================${NC}"
    echo -e "${WHITE}                    ${SCRIPT_NAME}${NC}"
    echo -e "${CYAN}                         Version ${SCRIPT_VERSION}${NC}"
    echo -e "${YELLOW}                    ${COMPANY}${NC}"
    echo -e "${GREEN}                        ${LOCATION}${NC}"
    echo -e "${BLUE}                         ${WEBSITE}${NC}"
    echo -e "${PURPLE}===============================================================================${NC}"
    echo ""
}

# Logging avec timestamp
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "INFO")  echo -e "${GREEN}[${timestamp}] [INFO]${NC} $message" ;;
        "WARN")  echo -e "${YELLOW}[${timestamp}] [WARN]${NC} $message" ;;
        "ERROR") echo -e "${RED}[${timestamp}] [ERROR]${NC} $message" ;;
        "DEBUG") echo -e "${CYAN}[${timestamp}] [DEBUG]${NC} $message" ;;
    esac
}

# Vérification des privilèges root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log "ERROR" "Ce script doit être exécuté en tant que root"
        log "INFO" "Utilisez: sudo $0"
        exit 1
    fi
}

# Détection automatique de la version Debian
detect_debian_version() {
    log "INFO" "Détection de la version Debian..."
    
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        DEBIAN_VERSION=$VERSION_ID
        DEBIAN_CODENAME=$VERSION_CODENAME
        
        log "INFO" "Debian détecté: $DEBIAN_VERSION ($DEBIAN_CODENAME)"
    else
        log "ERROR" "Impossible de détecter la version Debian"
        exit 1
    fi
}

# Configuration automatique des repositories Proxmox selon la version Debian
configure_proxmox_repo() {
    log "INFO" "Configuration du repository Proxmox pour Debian $DEBIAN_VERSION..."
    
    case $DEBIAN_VERSION in
        "13")
            PROXMOX_VERSION="9"
            PROXMOX_REPO_URL="http://download.proxmox.com/debian/pve"
            GPG_KEY_URL="https://enterprise.proxmox.com/debian/proxmox-release-${DEBIAN_CODENAME}.gpg"
            ;;
        "12")
            PROXMOX_VERSION="8"
            PROXMOX_REPO_URL="http://download.proxmox.com/debian/pve"
            GPG_KEY_URL="https://enterprise.proxmox.com/debian/proxmox-release-${DEBIAN_CODENAME}.gpg"
            ;;
        "11")
            PROXMOX_VERSION="7"
            PROXMOX_REPO_URL="http://download.proxmox.com/debian/pve"
            GPG_KEY_URL="https://enterprise.proxmox.com/debian/proxmox-release-${DEBIAN_CODENAME}.gpg"
            ;;
        *)
            log "ERROR" "Version Debian $DEBIAN_VERSION non supportée"
            log "INFO" "Versions supportées: 11 (Bullseye), 12 (Bookworm), 13 (Trixie)"
            exit 1
            ;;
    esac
    
    log "INFO" "Configuration: Proxmox VE $PROXMOX_VERSION sur Debian $DEBIAN_VERSION"
}

# Prévention des blocages fsck
prevent_fsck_hang() {
    log "INFO" "Prévention des blocages fsck..."
    
    # Forcer fsck à ne pas être interactif
    tune2fs -c 0 -i 0 /dev/sda3 2>/dev/null || log "WARN" "Impossible de configurer tune2fs"
    
    # Désactiver fsck automatique au boot
    tune2fs -C 0 /dev/sda3 2>/dev/null || log "WARN" "Impossible de réinitialiser le compteur fsck"
    
    # Ajouter paramètres pour éviter fsck au boot
    # Détection de la carte graphique pour paramètres adaptés
    local gpu_vendor=$(lspci | grep -i vga | head -1)
    local grub_params="nomodeset acpi=on fsck.mode=skip"
    
    if echo "$gpu_vendor" | grep -qi "nvidia"; then
        grub_params="$grub_params nouveau.modeset=0"
    elif echo "$gpu_vendor" | grep -qi "amd\|ati"; then
        grub_params="$grub_params radeon.modeset=0 amdgpu.modeset=0"
    elif echo "$gpu_vendor" | grep -qi "intel"; then
        grub_params="$grub_params i915.modeset=0"
    fi
    
    sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*\"/GRUB_CMDLINE_LINUX_DEFAULT=\"$grub_params\"/" /etc/default/grub
    
    log "INFO" "Configuration fsck mise à jour"
}

# Détection automatique de la carte graphique et configuration GRUB
configure_grub_for_gpu() {
    log "INFO" "Détection de la carte graphique..."
    
    local gpu_vendor=$(lspci | grep -i vga | head -1)
    local grub_params="nomodeset acpi=on"
    
    if echo "$gpu_vendor" | grep -qi "nvidia"; then
        log "INFO" "Carte NVIDIA détectée - ajout paramètres spécifiques"
        grub_params="$grub_params nouveau.modeset=0"
    elif echo "$gpu_vendor" | grep -qi "amd\|ati"; then
        log "INFO" "Carte AMD/ATI détectée - ajout paramètres spécifiques"
        grub_params="$grub_params radeon.modeset=0 amdgpu.modeset=0"
    elif echo "$gpu_vendor" | grep -qi "intel"; then
        log "INFO" "Carte Intel détectée - configuration basique"
        grub_params="$grub_params i915.modeset=0"
    else
        log "INFO" "Carte graphique générique détectée"
    fi
    
    log "INFO" "Paramètres GRUB: $grub_params"
    
    # Configuration GRUB adaptative
    cat > /etc/default/grub << EOF
# Configuration GRUB optimisée pour Proxmox VE
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR=\`( . /etc/os-release && echo \${NAME} )\`
GRUB_CMDLINE_LINUX_DEFAULT="$grub_params"
GRUB_CMDLINE_LINUX="systemd.unified_cgroup_hierarchy=1"
GRUB_TERMINAL=console
GRUB_DISABLE_OS_PROBER=true
EOF
}

# Détection et correction des problèmes de boot
fix_boot_issues() {
    log "INFO" "Correction des problèmes de boot potentiels..."
    
    # Vérification du système de fichiers
    if ! mountpoint -q /boot/efi; then
        log "WARN" "Partition EFI non montée, tentative de montage..."
        mount /boot/efi 2>/dev/null || log "WARN" "Impossible de monter /boot/efi"
    fi
    
    # Configuration GRUB pour éviter les blocages
    log "INFO" "Configuration GRUB pour éviter les blocages au boot..."
    
    # Sauvegarde de la config GRUB
    cp /etc/default/grub /etc/default/grub.backup.$(date +%Y%m%d_%H%M%S)
    
    # Configuration GRUB adaptative selon la carte graphique
    configure_grub_for_gpu
    
    # Mise à jour GRUB
    update-grub
    
    log "INFO" "Configuration GRUB mise à jour"
}

# Détection du kernel PVE
check_pve_kernel() {
    if uname -r | grep -q "pve"; then
        log "INFO" "Kernel Proxmox VE détecté: $(uname -r)"
        return 0
    else
        log "INFO" "Kernel standard détecté: $(uname -r)"
        return 1
    fi
}

# Configuration réseau interactive
configure_network() {
    log "INFO" "Configuration du réseau..."
    
    # Détection automatique de l'interface principale
    NETWORK_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
    if [[ -z "$NETWORK_INTERFACE" ]]; then
        NETWORK_INTERFACE="ens18"  # Fallback pour VM
    fi
    
    # Configuration IP automatique basée sur l'IP actuelle
    CURRENT_IP=$(ip route get 1 | awk '{print $7}' | head -1)
    if [[ -n "$CURRENT_IP" ]]; then
        STATIC_IP="$CURRENT_IP/24"
        GATEWAY_IP=$(ip route | grep default | awk '{print $3}' | head -1)
    else
        # Configuration par défaut
        STATIC_IP="192.168.1.100/24"
        GATEWAY_IP="192.168.1.1"
    fi
    
    # Configuration hostname
    HOSTNAME_FQDN="proxmox.afrikteck.local"
    
    log "INFO" "Configuration réseau automatique: $STATIC_IP via $GATEWAY_IP sur $NETWORK_INTERFACE"
}

# Mise à jour du système
update_system() {
    log "INFO" "Mise à jour du système Debian..."
    
    export DEBIAN_FRONTEND=noninteractive
    
    apt update || {
        log "ERROR" "Échec de la mise à jour des sources"
        exit 1
    }
    
    apt full-upgrade -y || {
        log "ERROR" "Échec de la mise à jour du système"
        exit 1
    }
    
    log "INFO" "Système mis à jour avec succès"
}

# Installation des dépendances
install_dependencies() {
    log "INFO" "Installation des dépendances..."
    
    local packages=(
        "wget"
        "curl"
        "gnupg2"
        "apt-transport-https"
        "ca-certificates"
        "bridge-utils"
        "vlan"
        "ifupdown2"
    )
    
    for package in "${packages[@]}"; do
        log "DEBUG" "Installation de $package..."
        apt install -y "$package" || {
            log "ERROR" "Échec de l'installation de $package"
            exit 1
        }
    done
    
    log "INFO" "Dépendances installées avec succès"
}

# Configuration du repository Proxmox
setup_proxmox_repository() {
    log "INFO" "Configuration du repository Proxmox VE $PROXMOX_VERSION..."
    
    # Téléchargement de la clé GPG
    log "DEBUG" "Téléchargement de la clé GPG..."
    wget -q "$GPG_KEY_URL" -O "/etc/apt/trusted.gpg.d/proxmox-release-${DEBIAN_CODENAME}.gpg" || {
        log "ERROR" "Échec du téléchargement de la clé GPG"
        exit 1
    }
    
    # Ajout du repository
    log "DEBUG" "Ajout du repository Proxmox..."
    echo "deb [arch=amd64] $PROXMOX_REPO_URL $DEBIAN_CODENAME pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
    
    # Mise à jour des sources
    apt update || {
        log "ERROR" "Échec de la mise à jour après ajout du repository"
        exit 1
    }
    
    log "INFO" "Repository Proxmox configuré avec succès"
}

# Configuration du réseau système
apply_network_config() {
    log "INFO" "Application de la configuration réseau..."
    
    # Sauvegarde de la configuration actuelle
    cp /etc/network/interfaces /etc/network/interfaces.backup.$(date +%Y%m%d_%H%M%S)
    
    # Configuration du hostname
    hostnamectl set-hostname "${HOSTNAME_FQDN%%.*}"
    
    # Configuration /etc/hosts
    cat > /etc/hosts << EOF
127.0.0.1 localhost
${STATIC_IP%/*} $HOSTNAME_FQDN ${HOSTNAME_FQDN%%.*}

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
    
    # Configuration /etc/network/interfaces avec fallback
    cat > /etc/network/interfaces << EOF
# Configuration réseau générée par AFRIKTECK Proxmox Auto-Installer
# $(date)

auto lo
iface lo inet loopback

# Configuration interface physique (fallback pour kernel Debian)
auto $NETWORK_INTERFACE
iface $NETWORK_INTERFACE inet static
    address $STATIC_IP
    gateway $GATEWAY_IP

# Configuration bridge Proxmox (prioritaire si kernel PVE)
auto vmbr0
iface vmbr0 inet static
    address $STATIC_IP
    gateway $GATEWAY_IP
    bridge-ports $NETWORK_INTERFACE
    bridge-stp off
    bridge-fd 0
    # Configuration bridge pour Proxmox VE
EOF

    # Créer une config de secours pour kernel Debian
    cat > /etc/network/interfaces.debian-fallback << EOF
# Configuration réseau de secours pour kernel Debian
auto lo
iface lo inet loopback

auto $NETWORK_INTERFACE
iface $NETWORK_INTERFACE inet static
    address $STATIC_IP
    gateway $GATEWAY_IP
EOF
    
    log "INFO" "Configuration réseau appliquée"
}

# Installation du kernel Proxmox
install_pve_kernel() {
    log "INFO" "Installation du kernel Proxmox VE..."
    
    # Utilisation du kernel le plus récent disponible
    case $DEBIAN_VERSION in
        "13")
            KERNEL_VERSION="proxmox-kernel-6.17"
            ;;
        "12")
            KERNEL_VERSION="pve-kernel-6.5"
            ;;
        "11")
            KERNEL_VERSION="pve-kernel-5.15"
            ;;
    esac
    
    log "INFO" "Installation du kernel: $KERNEL_VERSION"
    
    apt install -y "$KERNEL_VERSION" || {
        log "ERROR" "Échec de l'installation du kernel PVE"
        exit 1
    }
    
    log "INFO" "Kernel Proxmox VE installé avec succès"
}

# Installation de Proxmox VE
install_proxmox_ve() {
    log "INFO" "Installation de Proxmox VE..."
    
    # Configuration de Postfix en mode non-interactif
    echo "postfix postfix/mailname string $HOSTNAME_FQDN" | debconf-set-selections
    echo "postfix postfix/main_mailer_type string 'Local only'" | debconf-set-selections
    
    # Installation des paquets Proxmox
    apt install -y proxmox-ve postfix open-iscsi || {
        log "ERROR" "Échec de l'installation de Proxmox VE"
        exit 1
    }
    
    log "INFO" "Proxmox VE installé avec succès"
}

# Nettoyage post-installation
cleanup_system() {
    log "INFO" "Nettoyage du système..."
    
    # Suppression des anciens kernels Debian
    apt remove -y linux-image-amd64 'linux-image-*' || log "WARN" "Certains kernels n'ont pas pu être supprimés"
    
    # Mise à jour de GRUB
    update-grub
    
    # Nettoyage des paquets orphelins
    apt autoremove -y
    apt autoclean
    
    log "INFO" "Nettoyage terminé"
}

# Configuration post-installation
post_install_config() {
    log "INFO" "Configuration post-installation..."
    
    # Désactivation du repository enterprise
    if [[ -f /etc/apt/sources.list.d/pve-enterprise.list ]]; then
        sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list
        log "INFO" "Repository enterprise désactivé"
    fi
    
    # Configuration du pare-feu automatique
    log "INFO" "Configuration du pare-feu Proxmox..."
    pvesh set /cluster/firewall/options --enable 1 2>/dev/null || true
    pvesh create /cluster/firewall/rules --type in --action ACCEPT --proto tcp --dport 22 --comment "SSH" 2>/dev/null || true
    pvesh create /cluster/firewall/rules --type in --action ACCEPT --proto tcp --dport 8006 --comment "Proxmox Web UI" 2>/dev/null || true
    log "INFO" "Pare-feu configuré automatiquement"
}

# Vérification de l'installation
verify_installation() {
    log "INFO" "Vérification de l'installation..."
    
    # Vérification des services
    local services=("pvedaemon" "pveproxy" "pve-cluster")
    
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            log "INFO" "Service $service: OK"
        else
            log "WARN" "Service $service: NOK"
        fi
    done
    
    # Affichage des informations de connexion
    echo ""
    echo -e "${GREEN}===============================================================================${NC}"
    echo -e "${WHITE}                    INSTALLATION TERMINÉE - AFRIKTECK${NC}"
    echo -e "${GREEN}===============================================================================${NC}"
    echo -e "${CYAN}Interface Web Proxmox:${NC} https://${STATIC_IP%/*}:8006"
    echo -e "${CYAN}Utilisateur:${NC} root"
    echo -e "${CYAN}Mot de passe:${NC} [mot de passe root du système]"
    echo ""
    echo -e "${YELLOW}Redémarrage requis pour finaliser l'installation${NC}"
    echo -e "${GREEN}===============================================================================${NC}"
}

# Fonction de redémarrage
reboot_system() {
    log "INFO" "Configuration capture des logs de boot..."
    
    # Vérifier et corriger le montage EFI
    if ! mountpoint -q /boot/efi; then
        mount /boot/efi 2>/dev/null || log "WARN" "Impossible de monter /boot/efi"
    fi
    
    # Script pour sauver les logs après reboot (même en cas de blocage)
    cat > /root/save_crash_logs.sh << 'EOF'
#!/bin/bash
# Capture tous les logs de boot, même en cas de blocage
journalctl -b -1 > /root/boot_crash_logs.txt 2>/dev/null
dmesg > /root/kernel_crash_logs.txt 2>/dev/null
# Capture les logs fsck spécifiquement
journalctl -b -1 | grep -i "fsck\|clean.*blocks\|sda3" > /root/fsck_logs.txt 2>/dev/null
# Logs en temps réel du kernel
journalctl -b -1 -k > /root/kernel_boot_logs.txt 2>/dev/null
echo "Logs sauvés à $(date)" > /root/logs_timestamp.txt
EOF
    chmod +x /root/save_crash_logs.sh
    
    # Ajouter le script au démarrage pour capture automatique
    cat > /etc/systemd/system/capture-boot-logs.service << 'EOF'
[Unit]
Description=Capture Boot Logs
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/root/save_crash_logs.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl enable capture-boot-logs.service
    
    log "INFO" "Redémarrage automatique dans 5 secondes..."
    sleep 5
    reboot
}

#===============================================================================
# FONCTION PRINCIPALE
#===============================================================================

main() {
    show_banner
    
    # Vérifications préliminaires
    check_root
    detect_debian_version
    configure_proxmox_repo
    
    # Si kernel PVE déjà installé, continuer l'installation
    if check_pve_kernel; then
        log "INFO" "Kernel PVE détecté, continuation de l'installation..."
        
        install_proxmox_ve
        cleanup_system
        post_install_config
        verify_installation
        
        log "INFO" "Installation Proxmox VE terminée avec succès !"
        echo ""
        echo -e "${GREEN}© 2026 AFRIKTECK - Datacenter Solutions, $LOCATION${NC}"
        echo -e "${BLUE}Propriété intellectuelle AFRIKTECK - $WEBSITE${NC}"
        
    else
        log "INFO" "Première exécution - Installation du kernel PVE..."
        
        # Configuration et installation initiale
        configure_network
        update_system
        install_dependencies
        setup_proxmox_repository
        apply_network_config
        prevent_fsck_hang
        fix_boot_issues
        install_pve_kernel
        
        log "INFO" "Kernel PVE installé. Redémarrage requis."
        log "INFO" "Relancez ce script après le redémarrage pour finaliser l'installation."
        
        reboot_system
    fi
}

#===============================================================================
# GESTION DES ERREURS ET SIGNAUX
#===============================================================================

# Gestion des interruptions
trap 'log "ERROR" "Installation interrompue par l'\''utilisateur"; exit 130' INT TERM

# Gestion des erreurs
set -eE
trap 'log "ERROR" "Erreur ligne $LINENO: $BASH_COMMAND"' ERR

#===============================================================================
# POINT D'ENTRÉE
#===============================================================================

# Ajout de /usr/sbin au PATH
export PATH="$PATH:/usr/sbin"

# Lancement du script principal
main "$@"

#===============================================================================
# FIN DU SCRIPT AFRIKTECK
#===============================================================================
