# Scripts d'Installation Proxmox - AFRIKTECK

**Propriété intellectuelle :** AFRIKTECK - Datacenter Solutions  
**Copyright :** © 2024 AFRIKTECK - Tous droits réservés  

---

## 🚀 Installation Rapide depuis GitHub

### Commande One-Line (Recommandée)
```bash
curl -fsSL https://raw.githubusercontent.com/afrikteck/proxmox-installation-guide/main/scripts/deploy-from-github.sh | bash
```

### Installation Manuelle
```bash
# Télécharger le script de déploiement
wget https://raw.githubusercontent.com/afrikteck/proxmox-installation-guide/main/scripts/deploy-from-github.sh

# Rendre exécutable
chmod +x deploy-from-github.sh

# Exécuter en tant que root
sudo ./deploy-from-github.sh
```

---

## 📋 Scripts Disponibles

### 1. **install-proxmox.sh** - Script Principal
- **Fonction :** Installation automatique de Proxmox VE
- **Détection :** Version Debian automatique (11, 12, 13)
- **Configuration :** Réseau, kernel, repositories
- **Intelligence :** Adaptation selon la version système

**Caractéristiques :**
- ✅ Détection automatique Debian 11/12/13
- ✅ Configuration Proxmox VE 7/8/9 selon la version
- ✅ Gestion intelligente des kernels
- ✅ Configuration réseau bridge automatique
- ✅ Logging complet avec couleurs
- ✅ Gestion d'erreurs robuste

### 2. **configure-proxmox.sh** - Configuration Post-Installation
- **Fonction :** Configuration avancée après installation
- **Optimisations :** Système et performance
- **Templates :** Téléchargement automatique
- **Monitoring :** Configuration de base

### 3. **deploy-from-github.sh** - Déploiement Distant
- **Fonction :** Installation complète depuis GitHub
- **Avantages :** Toujours la dernière version
- **Sécurité :** Vérification d'intégrité
- **Sauvegarde :** Backup automatique avant installation

---

## 🔧 Variables Intelligentes

Le script utilise des variables dynamiques pour s'adapter automatiquement :

```bash
# Détection automatique de la version
DEBIAN_VERSION=""          # Auto-détecté (11, 12, 13)
DEBIAN_CODENAME=""         # Auto-détecté (bullseye, bookworm, trixie)
PROXMOX_VERSION=""         # Auto-configuré (7, 8, 9)
PROXMOX_REPO_URL=""        # Auto-configuré selon la version
GPG_KEY_URL=""             # Auto-configuré selon le codename
KERNEL_VERSION=""          # Auto-sélectionné selon Debian

# Configuration réseau
NETWORK_INTERFACE=""       # Sélection interactive
STATIC_IP=""              # Configuration utilisateur
GATEWAY_IP=""             # Configuration utilisateur
HOSTNAME_FQDN=""          # Configuration utilisateur
```

---

## 🎯 Matrice de Compatibilité

| Debian Version | Codename  | Proxmox VE | Kernel PVE | Status |
|----------------|-----------|------------|------------|---------|
| 13             | Trixie    | 9.x        | 6.8        | ✅ Testé |
| 12             | Bookworm  | 8.x        | 6.5        | ✅ Testé |
| 11             | Bullseye  | 7.x        | 5.15       | ✅ Testé |

---

## 🔄 Processus d'Installation

### Première Exécution
1. **Détection** de la version Debian
2. **Configuration** du réseau
3. **Installation** des dépendances
4. **Ajout** du repository Proxmox
5. **Installation** du kernel PVE
6. **Redémarrage** automatique

### Seconde Exécution (après redémarrage)
1. **Détection** du kernel PVE
2. **Installation** de Proxmox VE
3. **Configuration** post-installation
4. **Nettoyage** du système
5. **Vérification** des services

---

## 🛡️ Fonctionnalités de Sécurité

### Vérifications Préliminaires
- ✅ Privilèges root obligatoires
- ✅ Détection de la version système
- ✅ Vérification de la connectivité Internet
- ✅ Sauvegarde automatique avant installation

### Gestion d'Erreurs
- ✅ Trap sur les signaux d'interruption
- ✅ Logging détaillé de toutes les opérations
- ✅ Rollback en cas d'échec critique
- ✅ Vérification d'intégrité des téléchargements

---

## 📊 Logs et Monitoring

### Format des Logs
```bash
[2024-03-25 05:30:15] [INFO] Détection de la version Debian...
[2024-03-25 05:30:16] [INFO] Debian détecté: 13 (trixie)
[2024-03-25 05:30:17] [INFO] Configuration: Proxmox VE 9 sur Debian 13
```

### Niveaux de Log
- **INFO** : Informations générales
- **WARN** : Avertissements non critiques
- **ERROR** : Erreurs critiques
- **DEBUG** : Informations de débogage

---

## 🔧 Personnalisation

### Variables d'Environnement
```bash
# Personnalisation du hostname
export AFRIKTECK_HOSTNAME="proxmox.afrikteck.local"

# Configuration réseau par défaut
export AFRIKTECK_NETWORK="192.168.1.0/24"
export AFRIKTECK_GATEWAY="192.168.1.1"

# Mode silencieux
export AFRIKTECK_SILENT="true"
```

### Configuration Avancée
```bash
# Éditer les variables dans le script
vim /path/to/install-proxmox.sh

# Modifier les repositories
PROXMOX_REPO_URL="http://your-mirror.com/debian/pve"

# Personnaliser les packages
ADDITIONAL_PACKAGES=("htop" "vim" "git")
```

---

## 🚨 Dépannage

### Problèmes Courants

#### 1. Erreur de Repository
```bash
# Solution : Vérifier la connectivité
ping download.proxmox.com

# Forcer la mise à jour
apt update --allow-releaseinfo-change
```

#### 2. Kernel PVE non détecté
```bash
# Vérifier l'installation
dpkg -l | grep pve-kernel

# Réinstaller si nécessaire
apt install --reinstall pve-kernel-*
```

#### 3. Interface réseau non trouvée
```bash
# Lister les interfaces
ip link show

# Vérifier la configuration
cat /etc/network/interfaces
```

---

## 📞 Support AFRIKTECK

### Contacts Techniques
- **Email principal :** contact@afrikteck.com
- **Support technique :** afrikteck@outlook.com
- **GitHub Issues :** [Créer une issue](https://github.com/afrikteck/proxmox-installation-guide/issues)

### Documentation
- **Site web :** https://afrikteck.com
- **Repository GitHub :** https://github.com/afrikteck/proxmox-installation-guide
- **Wiki :** [Documentation complète](https://github.com/afrikteck/proxmox-installation-guide/wiki)

---

## ⚖️ Propriété Intellectuelle

**AVERTISSEMENT LÉGAL :** Ces scripts sont la propriété intellectuelle d'AFRIKTECK.

**Utilisation autorisée :**
- ✅ Usage personnel et commercial
- ✅ Modification et adaptation
- ✅ Distribution et vente

**Conditions obligatoires :**
- 🔒 Maintenir les mentions de copyright AFRIKTECK
- 🔒 Conserver les informations de contact
- 🔒 Inclure l'attribution dans toute distribution

**Attribution requise :** "Basé sur les travaux d'AFRIKTECK (afrikteck.com)"

---

**© 2024 AFRIKTECK - Datacenter Solutions, Libreville, Gabon**  
*Propriété intellectuelle AFRIKTECK - Tous droits réservés*
