# Guide d'Installation Proxmox VE sur Debian - AFRIKTECK

**Propriété intellectuelle :** AFRIKTECK - Datacenter Solutions  
**Copyright :** © 2026 AFRIKTECK - Tous droits réservés  
**Société :** AFRIKTECK  
**Localisation :** Libreville, Gabon  
**Spécialité :** Datacenter et Infrastructure  
**Site web :** afrikteck.com  
**Contact :** contact@afrikteck.com | afrikteck@outlook.com | afrikteck@gmail.com

---

## ⚖️ AVIS LÉGAL IMPORTANT

**UTILISATION AUTORISÉE :** Ce guide peut être utilisé, modifié, partagé et même vendu.

**CONDITIONS OBLIGATOIRES :**
- Les mentions de propriété intellectuelle AFRIKTECK DOIVENT être conservées
- Toute distribution DOIT inclure les crédits AFRIKTECK
- La suppression des mentions AFRIKTECK est INTERDITE et passible de poursuites

**ATTRIBUTION REQUISE :** "Basé sur les travaux d'AFRIKTECK (afrikteck.com)"

---

## Table des Matières
1. [Prérequis](#prérequis)
2. [Préparation du Système](#préparation-du-système)
3. [Installation des Dépendances](#installation-des-dépendances)
4. [Configuration du Repository Proxmox](#configuration-du-repository-proxmox)
5. [Installation de Proxmox VE](#installation-de-proxmox-ve)
6. [Configuration Post-Installation](#configuration-post-installation)
7. [Sécurisation](#sécurisation)
8. [Vérification](#vérification)

---

## Prérequis

### Configuration Matérielle Minimale
- **CPU :** 64-bit (Intel VT/AMD-V support recommandé)
- **RAM :** 2 GB minimum (8 GB recommandé)
- **Stockage :** 32 GB minimum (SSD recommandé)
- **Réseau :** Interface Ethernet

### Configuration Logicielle
- **OS :** Debian 13 (Trixie) - Installation propre
- **Accès :** Root ou utilisateur avec privilèges sudo
- **Réseau :** IP statique configurée
- **DNS :** Résolution de noms fonctionnelle

---

## Préparation du Système

### 1. Mise à jour du système
```bash
apt update && apt upgrade -y
```

### 2. Configuration du hostname
```bash
# Définir le hostname
hostnamectl set-hostname proxmox.afrikteck.local

# Éditer /etc/hosts
echo "127.0.0.1 localhost" > /etc/hosts
echo "$(ip route get 1 | awk '{print $7}') proxmox.afrikteck.local proxmox" >> /etc/hosts
```

### 3. Désactivation d'AppArmor (si présent)
```bash
systemctl disable apparmor
systemctl stop apparmor
```

---

## Installation des Dépendances

### 1. Installation des paquets essentiels
```bash
apt install -y wget curl gnupg2 software-properties-common apt-transport-https ca-certificates
```

### 2. Installation des outils réseau
```bash
apt install -y bridge-utils vlan ifupdown2
```

---

## Configuration du Repository Proxmox

### 1. Ajout de la clé GPG Proxmox
```bash
wget https://enterprise.proxmox.com/debian/proxmox-release-trixie.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-trixie.gpg
```

### 2. Ajout du repository
```bash
echo "deb [arch=amd64] http://download.proxmox.com/debian/pve trixie pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
```

### 3. Mise à jour des sources
```bash
apt update
```

---

## Installation de Proxmox VE

### 1. Installation du kernel Proxmox
```bash
apt install -y proxmox-ve postfix open-iscsi
```

### 2. Configuration de Postfix
- Choisir "Internet Site"
- Entrer le FQDN : `proxmox.afrikteck.local`

### 3. Redémarrage sur le kernel Proxmox
```bash
reboot
```

### 4. Vérification du kernel
```bash
uname -r
# Doit afficher un kernel pve
```

---

## Configuration Post-Installation

### 1. Suppression du kernel Debian (optionnel)
```bash
apt remove linux-image-amd64 'linux-image-6.11*'
update-grub
```

### 2. Configuration du réseau
Éditer `/etc/network/interfaces` :
```bash
auto lo
iface lo inet loopback

auto vmbr0
iface vmbr0 inet static
    address 192.168.1.100/24
    gateway 192.168.1.1
    bridge-ports eth0
    bridge-stp off
    bridge-fd 0
```

### 3. Redémarrage des services réseau
```bash
systemctl restart networking
```

### 4. Configuration du stockage
```bash
# Créer un groupe de volumes LVM (si nécessaire)
pvcreate /dev/sdb
vgcreate pve /dev/sdb
lvcreate -l 100%FREE -n data pve
```

---

## Sécurisation

### 1. Configuration du pare-feu Proxmox
```bash
# Activer le pare-feu
pvesh set /cluster/firewall/options --enable 1

# Règles de base
pvesh create /cluster/firewall/rules --type in --action ACCEPT --proto tcp --dport 22 --comment "SSH"
pvesh create /cluster/firewall/rules --type in --action ACCEPT --proto tcp --dport 8006 --comment "Proxmox Web UI"
```

### 2. Configuration SSL (optionnel)
```bash
# Générer un certificat auto-signé
pvecm updatecerts --force
```

### 3. Désactivation du repository enterprise
```bash
# Commenter la ligne enterprise dans /etc/apt/sources.list.d/pve-enterprise.list
sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list
```

---

## Vérification

### 1. Vérification des services
```bash
systemctl status pvedaemon
systemctl status pveproxy
systemctl status pve-cluster
```

### 2. Accès à l'interface web
- URL : `https://IP_SERVER:8006`
- Utilisateur : `root`
- Mot de passe : mot de passe root du système

### 3. Vérification des ressources
```bash
pvesh get /version
pvesh get /nodes
```

---

## Commandes Utiles

### Gestion des VMs
```bash
# Lister les VMs
qm list

# Créer une VM
qm create 100 --name test-vm --memory 1024 --cores 2

# Démarrer une VM
qm start 100
```

### Gestion du stockage
```bash
# Lister les stockages
pvesh get /storage

# Vérifier l'espace disque
df -h
```

### Logs et diagnostic
```bash
# Logs Proxmox
journalctl -u pvedaemon
journalctl -u pveproxy

# Statut du cluster
pvecm status
```

---

## Support et Maintenance

### Mise à jour de Proxmox
```bash
apt update && apt dist-upgrade
```

### Sauvegarde de la configuration
```bash
# Sauvegarde automatique via l'interface web
# Ou manuel :
tar -czf /root/pve-backup-$(date +%Y%m%d).tar.gz /etc/pve
```

---

---

## ⚖️ PROPRIÉTÉ INTELLECTUELLE

**© 2026 AFRIKTECK - Datacenter Solutions - Tous droits réservés**

**AVERTISSEMENT LÉGAL :** Ce document est la propriété intellectuelle d'AFRIKTECK. 
Toute utilisation, modification ou distribution DOIT conserver ces mentions sous peine de poursuites légales.

**Attribution requise :** "Basé sur les travaux d'AFRIKTECK (afrikteck.com)"

*Guide réalisé par l'équipe technique AFRIKTECK - Libreville, Gabon*
