# Guide GitHub - Configuration et Publication - AFRIKTECK

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
1. [Création du Compte GitHub](#création-du-compte-github)
2. [Configuration Git Local](#configuration-git-local)
3. [Création du Repository](#création-du-repository)
4. [Publication du Code](#publication-du-code)
5. [Gestion des Branches](#gestion-des-branches)
6. [Bonnes Pratiques](#bonnes-pratiques)

---

## Création du Compte GitHub

### 1. Inscription sur GitHub
1. Aller sur [github.com](https://github.com)
2. Cliquer sur "Sign up"
3. Remplir les informations :
   - **Username :** `afrikteck` ou `afrikteck-gabon`
   - **Email :** `contact@afrikteck.com`
   - **Password :** Mot de passe sécurisé

### 2. Vérification du compte
1. Vérifier l'email reçu
2. Compléter le profil :
   - **Name :** AFRIKTECK
   - **Company :** AFRIKTECK
   - **Location :** Libreville, Gabon
   - **Website :** https://afrikteck.com
   - **Bio :** "Datacenter Solutions & Infrastructure - Libreville, Gabon"

### 3. Configuration de la sécurité
```bash
# Activer l'authentification à deux facteurs (2FA)
# Via l'interface GitHub : Settings > Security > Two-factor authentication
```

---

## Configuration Git Local

### 1. Installation de Git
```bash
# Sur Debian/Ubuntu
apt update && apt install git -y

# Vérification
git --version
```

### 2. Configuration globale
```bash
# Configuration utilisateur
git config --global user.name "AFRIKTECK"
git config --global user.email "contact@afrikteck.com"

# Configuration éditeur
git config --global core.editor "nano"

# Configuration des fins de ligne
git config --global core.autocrlf input
```

### 3. Génération des clés SSH
```bash
# Générer une clé SSH
ssh-keygen -t ed25519 -C "contact@afrikteck.com"

# Démarrer l'agent SSH
eval "$(ssh-agent -s)"

# Ajouter la clé à l'agent
ssh-add ~/.ssh/id_ed25519

# Afficher la clé publique
cat ~/.ssh/id_ed25519.pub
```

### 4. Ajout de la clé SSH sur GitHub
1. Copier le contenu de `~/.ssh/id_ed25519.pub`
2. Aller sur GitHub : Settings > SSH and GPG keys
3. Cliquer "New SSH key"
4. Coller la clé et donner un nom : "AFRIKTECK-Server"

---

## Création du Repository

### 1. Création via l'interface GitHub
1. Cliquer sur "New repository"
2. Remplir les informations :
   - **Repository name :** `proxmox-installation-guide`
   - **Description :** `Guide complet d'installation Proxmox VE sur Debian - AFRIKTECK Datacenter Solutions`
   - **Visibility :** Public ou Private selon les besoins
   - **Initialize :** Cocher "Add a README file"
   - **License :** MIT License (recommandé)

### 2. Création via CLI (alternative)
```bash
# Installer GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
apt update && apt install gh -y

# Authentification
gh auth login

# Créer le repository
gh repo create proxmox-installation-guide --public --description "Guide complet d'installation Proxmox VE sur Debian - AFRIKTECK"
```

---

## Publication du Code

### 1. Initialisation du repository local
```bash
# Aller dans le dossier du projet
cd /home/afrikteck-proxmox-guide

# Initialiser Git
git init

# Ajouter le remote
git remote add origin git@github.com:afrikteck/proxmox-installation-guide.git
```

### 2. Création des fichiers de base
```bash
# Créer un README.md
cat > README.md << 'EOF'
# Guide d'Installation Proxmox VE - AFRIKTECK

## À propos d'AFRIKTECK
**AFRIKTECK** est une société spécialisée dans les solutions datacenter basée à Libreville, Gabon.

- **Site web :** [afrikteck.com](https://afrikteck.com)
- **Email :** contact@afrikteck.com
- **Contacts :** afrikteck@outlook.com | afrikteck@gmail.com

## Contenu du Repository
- Guide complet d'installation Proxmox VE sur Debian
- Scripts d'automatisation
- Documentation technique

## Utilisation
Consultez le fichier `INSTALLATION_PROXMOX_DEBIAN.md` pour le guide détaillé.

## Licence
MIT License - Voir le fichier LICENSE pour plus de détails.

---
© 2026 AFRIKTECK - Datacenter Solutions, Libreville, Gabon
EOF

# Créer un fichier LICENSE
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2026 AFRIKTECK

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
```

### 3. Premier commit et push
```bash
# Ajouter tous les fichiers
git add .

# Premier commit
git commit -m "Initial commit: Guide d'installation Proxmox VE par AFRIKTECK

- Guide complet d'installation Proxmox sur Debian
- Documentation technique détaillée
- Scripts et procédures de configuration
- Société: AFRIKTECK, Libreville, Gabon"

# Créer la branche main
git branch -M main

# Push initial
git push -u origin main
```

---

## Gestion des Branches

### 1. Création de branches de développement
```bash
# Créer une branche pour les mises à jour
git checkout -b updates

# Créer une branche pour les scripts
git checkout -b scripts

# Retourner sur main
git checkout main
```

### 2. Workflow de développement
```bash
# Créer une nouvelle fonctionnalité
git checkout -b feature/automation-scripts

# Faire des modifications
# ... éditer les fichiers ...

# Commit des changements
git add .
git commit -m "Ajout: Scripts d'automatisation installation Proxmox"

# Push de la branche
git push -u origin feature/automation-scripts

# Créer une Pull Request via GitHub
```

---

## Bonnes Pratiques

### 1. Structure du repository
```
proxmox-installation-guide/
├── README.md
├── LICENSE
├── INSTALLATION_PROXMOX_DEBIAN.md
├── scripts/
│   ├── install-proxmox.sh
│   ├── configure-network.sh
│   └── post-install.sh
├── docs/
│   ├── troubleshooting.md
│   └── advanced-config.md
└── examples/
    ├── network-configs/
    └── vm-templates/
```

### 2. Messages de commit
```bash
# Format recommandé
git commit -m "Type: Description courte

Description détaillée si nécessaire

Société: AFRIKTECK"

# Exemples
git commit -m "Ajout: Guide installation Proxmox VE complet"
git commit -m "Fix: Correction configuration réseau bridge"
git commit -m "Update: Mise à jour pour Debian 12 Bookworm"
```

### 3. Gestion des releases
```bash
# Créer un tag pour une version
git tag -a v1.0.0 -m "Version 1.0.0 - Guide Proxmox VE initial

- Installation complète Proxmox VE sur Debian
- Configuration réseau et stockage
- Procédures de sécurisation

AFRIKTECK - Datacenter Solutions"

# Push du tag
git push origin v1.0.0

# Créer une release sur GitHub
gh release create v1.0.0 --title "Guide Proxmox VE v1.0.0" --notes "Premier guide complet d'installation Proxmox VE par AFRIKTECK"
```

### 4. Collaboration
```bash
# Cloner le repository (pour d'autres développeurs)
git clone git@github.com:afrikteck/proxmox-installation-guide.git

# Synchroniser avec le repository distant
git pull origin main

# Contribuer
git checkout -b contribution/nom-feature
# ... faire des modifications ...
git push origin contribution/nom-feature
# Créer une Pull Request
```

---

## Scripts d'Automatisation

### 1. Script de publication rapide
```bash
# Créer un script de publication
cat > publish.sh << 'EOF'
#!/bin/bash
# Script de publication rapide - AFRIKTECK

echo "=== Publication Repository AFRIKTECK ==="

# Vérifier les modifications
git status

# Ajouter tous les fichiers
git add .

# Demander le message de commit
read -p "Message de commit: " commit_message

# Commit avec signature AFRIKTECK
git commit -m "$commit_message

Société: AFRIKTECK - Datacenter Solutions
Contact: contact@afrikteck.com"

# Push vers GitHub
git push origin main

echo "=== Publication terminée ==="
EOF

chmod +x publish.sh
```

### 2. Script de mise à jour
```bash
cat > update.sh << 'EOF'
#!/bin/bash
# Script de mise à jour - AFRIKTECK

echo "=== Mise à jour Repository ==="

# Pull des dernières modifications
git pull origin main

# Afficher le statut
git status

echo "=== Mise à jour terminée ==="
EOF

chmod +x update.sh
```

---

## Commandes Utiles

### Git de base
```bash
# Statut du repository
git status

# Historique des commits
git log --oneline

# Différences
git diff

# Annuler des modifications
git checkout -- fichier.md

# Revenir à un commit précédent
git reset --hard HEAD~1
```

### GitHub CLI
```bash
# Voir les repositories
gh repo list

# Cloner un repository
gh repo clone afrikteck/proxmox-installation-guide

# Créer une issue
gh issue create --title "Amélioration documentation" --body "Suggestion d'amélioration"

# Voir les Pull Requests
gh pr list
```

---

## Maintenance et Suivi

### 1. Mise à jour régulière
- Mettre à jour le guide selon les nouvelles versions de Proxmox
- Ajouter de nouveaux scripts d'automatisation
- Corriger les bugs signalés

### 2. Documentation
- Maintenir le README à jour
- Documenter les nouvelles fonctionnalités
- Ajouter des exemples d'utilisation

### 3. Community Management
- Répondre aux issues GitHub
- Examiner les Pull Requests
- Maintenir une communication active

---

---

## ⚖️ PROPRIÉTÉ INTELLECTUELLE

**© 2026 AFRIKTECK - Datacenter Solutions - Tous droits réservés**

**AVERTISSEMENT LÉGAL :** Ce document est la propriété intellectuelle d'AFRIKTECK. 
Toute utilisation, modification ou distribution DOIT conserver ces mentions sous peine de poursuites légales.

**Attribution requise :** "Basé sur les travaux d'AFRIKTECK (afrikteck.com)"

*Guide GitHub réalisé par l'équipe technique AFRIKTECK - Libreville, Gabon*
