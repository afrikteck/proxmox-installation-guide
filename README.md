# Guide d'Installation Automatique Proxmox VE

Ce repository contient un script automatisé pour l'installation de Proxmox VE sur Debian 13 (Trixie).

## 🚀 Installation Rapide

```bash
# Télécharger et exécuter le script d'installation
wget -O - https://raw.githubusercontent.com/afrikteck/proxmox-installation-guide/main/scripts/install-proxmox.sh | bash
```

## 📋 Prérequis

- Debian 13 (Trixie) fraîchement installé
- Accès root
- Connexion Internet stable
- Au moins 2 GB de RAM
- 20 GB d'espace disque libre

## 🔧 Configuration

Après l'installation, Proxmox VE sera accessible via :

- **Interface Web** : https://VOTRE_IP:8006
- **Utilisateur** : root
- **Mot de passe** : Votre mot de passe root système

## 🚨 Dépannage - Blocage au Démarrage

Si le système se bloque au démarrage après l'installation du kernel Proxmox VE :

### Solution de Récupération

1. **Redémarrer la machine**
2. **Au menu GRUB**, appuyer sur `Esc` ou maintenir `Shift` pour afficher les options
3. **Sélectionner "Options avancées"**
4. **Choisir l'ancien kernel Debian** (généralement `vmlinuz-X.X.X-amd64`)
5. **Démarrer sur ce kernel**

### Récupération du Réseau

Une fois démarré sur l'ancien kernel Debian :

```bash
# Exécuter le script de récupération réseau
/root/fix-network.sh
```

**Le script configure automatiquement :**
- Interface physique (eno1) avec IP statique pour kernel Debian
- Bridge Proxmox (vmbr0) pour kernel PVE
- Configuration de fallback dans `/etc/network/interfaces.debian-fallback`

**Configuration réseau automatique :**
- Détection de l'interface réseau principale
- Configuration IP basée sur l'adresse actuelle
- Création d'une sauvegarde de récupération

### Analyse des Logs

Les logs de boot sont automatiquement capturés dans :

- `/root/boot_crash_logs.txt` - Logs complets du boot
- `/root/kernel_crash_logs.txt` - Messages kernel
- `/root/fsck_logs.txt` - Logs de vérification disque

### Correction Permanente

Le script détecte automatiquement votre carte graphique et configure les paramètres appropriés :
- **NVIDIA** : Désactivation du pilote Nouveau
- **AMD/ATI** : Désactivation des pilotes Radeon/AMDGPU
- **Intel** : Désactivation du pilote i915
- **Autres** : Configuration générique nomodeset

## 🏢 À Propos

**AFRIKTECK - Datacenter Solutions**  
Libreville, Gabon  
Website: [afrikteck.com](https://afrikteck.com)

---

© 2026 AFRIKTECK. Tous droits réservés.
