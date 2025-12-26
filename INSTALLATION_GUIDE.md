# 📦 Guide d'Installation - Logiciels et Configurations Hors Code

Ce guide liste tous les logiciels, outils et configurations nécessaires **en dehors du code** pour faire fonctionner le projet.

## 🔧 Prérequis Système

### 1. Système d'Exploitation
- **Linux** (Ubuntu 20.04+, CentOS 7+, ou équivalent)
- **macOS** 10.15+
- **Windows** 10/11 avec WSL2 (recommandé)

### 2. Outils de Base

#### Java Development Kit (JDK)
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install openjdk-17-jdk

# macOS
brew install openjdk@17

# Windows
# Télécharger depuis : https://adoptium.net/
```

**Vérification :**
```bash
java -version  # Doit afficher version 17+
```

#### Maven
```bash
# Ubuntu/Debian
sudo apt install maven

# macOS
brew install maven

# Windows
# Télécharger depuis : https://maven.apache.org/download.cgi
```

**Vérification :**
```bash
mvn -version
```

#### Git
```bash
# Ubuntu/Debian
sudo apt install git

# macOS
brew install git

# Windows
# Télécharger depuis : https://git-scm.com/
```

---

## 🐳 Docker et Docker Compose

### Installation Docker

#### Linux (Ubuntu/Debian)
```bash
# Supprimer les anciennes versions
sudo apt remove docker docker-engine docker.io containerd runc

# Installer les dépendances
sudo apt update
sudo apt install ca-certificates curl gnupg lsb-release

# Ajouter la clé GPG officielle
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Ajouter le repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installer Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Démarrer Docker
sudo systemctl start docker
sudo systemctl enable docker

# Ajouter l'utilisateur au groupe docker (pour éviter sudo)
sudo usermod -aG docker $USER
# Déconnexion/reconnexion nécessaire
```

#### macOS
```bash
# Installer Docker Desktop
# Télécharger depuis : https://www.docker.com/products/docker-desktop
# Ou via Homebrew :
brew install --cask docker
```

#### Windows
- Télécharger Docker Desktop : https://www.docker.com/products/docker-desktop
- Installer et redémarrer

**Vérification :**
```bash
docker --version
docker-compose --version
```

---

## ☸️ Kubernetes

### Option 1 : Minikube (Recommandé pour développement local)

#### Installation Minikube

**Linux :**
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

**macOS :**
```bash
brew install minikube
```

**Windows :**
```powershell
# Via Chocolatey
choco install minikube

# Ou télécharger depuis : https://minikube.sigs.k8s.io/docs/start/
```

#### Démarrer Minikube
```bash
# Démarrer avec Docker driver
minikube start --driver=docker

# Vérifier
kubectl get nodes
```

### Option 2 : kind (Kubernetes in Docker)

```bash
# Linux/macOS
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Créer un cluster
kind create cluster --name rd-microservices
```

### Option 3 : k3d (Léger)

```bash
# Linux/macOS
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Créer un cluster
k3d cluster create rd-microservices
```

### Installation kubectl

**Linux :**
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

**macOS :**
```bash
brew install kubectl
```

**Windows :**
```powershell
# Via Chocolatey
choco install kubernetes-cli

# Ou télécharger depuis : https://kubernetes.io/docs/tasks/tools/
```

**Vérification :**
```bash
kubectl version --client
```

---

## 🗄️ PostgreSQL

### Option 1 : Installation Locale

#### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib

# Démarrer PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Créer un utilisateur
sudo -u postgres psql
CREATE USER postgres WITH PASSWORD 'votre_mot_de_passe';
ALTER USER postgres CREATEDB;
\q
```

#### macOS
```bash
brew install postgresql@14
brew services start postgresql@14
```

#### Windows
- Télécharger depuis : https://www.postgresql.org/download/windows/
- Installer avec pgAdmin inclus

### Option 2 : Via Docker (Recommandé)
```bash
# Déjà inclus dans docker-compose.yml
docker-compose up -d postgres-auth postgres-project postgres-validation postgres-finance
```

**Vérification :**
```bash
psql -U postgres -h localhost -c "SELECT version();"
```

---

## 🔐 Keycloak

### Installation via Docker (Recommandé)

```bash
# Déjà configuré dans keycloak/docker-compose.yml
cd keycloak
docker-compose up -d

# Accéder à l'interface
# http://localhost:8090
# Admin / admin123 (changer en production)
```

### Installation Locale (Optionnel)

**Linux :**
```bash
# Télécharger Keycloak
wget https://github.com/keycloak/keycloak/releases/download/23.0/keycloak-23.0.tar.gz
tar -xzf keycloak-23.0.tar.gz
cd keycloak-23.0/bin

# Démarrer en mode développement
./kc.sh start-dev
```

**macOS/Windows :**
- Télécharger depuis : https://www.keycloak.org/downloads
- Extraire et exécuter `bin/kc.bat` (Windows) ou `bin/kc.sh` (macOS)

**Configuration initiale :**
1. Accéder à http://localhost:8090
2. Créer un admin (première connexion)
3. Importer le realm depuis `keycloak/realm-config/rd-realm.json`

---

## 🌐 NGINX

### Installation Locale (Optionnel, généralement via Docker)

#### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install nginx

# Démarrer NGINX
sudo systemctl start nginx
sudo systemctl enable nginx

# Vérifier
sudo systemctl status nginx
```

#### macOS
```bash
brew install nginx
brew services start nginx
```

#### Windows
- Télécharger depuis : http://nginx.org/en/download.html

**Note :** Pour ce projet, NGINX est conteneurisé, donc pas besoin d'installation locale.

---

## 📊 Prometheus

### Installation via Docker/Kubernetes (Recommandé)

Déjà configuré dans `monitoring/prometheus/k8s/prometheus.yaml`

### Installation Locale (Optionnel)

**Linux :**
```bash
# Télécharger
wget https://github.com/prometheus/prometheus/releases/download/v2.48.0/prometheus-2.48.0.linux-amd64.tar.gz
tar -xzf prometheus-2.48.0.linux-amd64.tar.gz
cd prometheus-2.48.0

# Démarrer
./prometheus --config.file=prometheus.yml
```

**macOS :**
```bash
brew install prometheus
brew services start prometheus
```

**Accès :** http://localhost:9090

---

## 📈 Grafana

### Installation via Docker/Kubernetes (Recommandé)

Déjà configuré dans `monitoring/grafana/k8s/grafana.yaml`

### Installation Locale (Optionnel)

**Linux :**
```bash
# Ajouter le repository
sudo apt-get install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install grafana

# Démarrer
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```

**macOS :**
```bash
brew install grafana
brew services start grafana
```

**Windows :**
- Télécharger depuis : https://grafana.com/grafana/download

**Configuration initiale :**
1. Accéder à http://localhost:3000
2. Login : admin / admin (changer au premier login)
3. Ajouter Prometheus comme datasource : http://prometheus:9090
4. Importer les dashboards depuis `monitoring/grafana/dashboards/`

---

## 📝 ELK Stack

### Installation via Docker/Kubernetes (Recommandé)

Déjà configuré dans `monitoring/elk/k8s/`

### Installation Locale (Optionnel - Complexe)

**Elasticsearch :**
```bash
# Linux
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.11.0-linux-x86_64.tar.gz
tar -xzf elasticsearch-8.11.0-linux-x86_64.tar.gz
cd elasticsearch-8.11.0
./bin/elasticsearch
```

**Logstash :**
```bash
wget https://artifacts.elastic.co/downloads/logstash/logstash-8.11.0-linux-x86_64.tar.gz
tar -xzf logstash-8.11.0-linux-x86_64.tar.gz
cd logstash-8.11.0
./bin/logstash -f logstash.conf
```

**Kibana :**
```bash
wget https://artifacts.elastic.co/downloads/kibana/kibana-8.11.0-linux-x86_64.tar.gz
tar -xzf kibana-8.11.0-linux-x86_64.tar.gz
cd kibana-8.11.0
./bin/kibana
```

**Note :** L'installation via Kubernetes est beaucoup plus simple et recommandée.

---

## 🔄 GitLab CI/CD

### Option 1 : GitLab.com (Cloud)

1. Créer un compte sur https://gitlab.com
2. Créer un nouveau projet
3. Push le code avec `.gitlab-ci.yml`
4. Configurer les variables CI/CD :
   - `CI_REGISTRY_USER`
   - `CI_REGISTRY_PASSWORD`
   - `KUBE_CONTEXT_STAGING`
   - `KUBE_CONTEXT_PRODUCTION`

### Option 2 : GitLab Self-Hosted

#### Installation GitLab CE

**Linux (Ubuntu/Debian) :**
```bash
# Installer les dépendances
sudo apt-get install -y curl openssh-server ca-certificates tzdata perl

# Ajouter le repository GitLab
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash

# Installer GitLab
sudo EXTERNAL_URL="http://gitlab.example.com" apt-get install gitlab-ce

# Configurer
sudo gitlab-ctl reconfigure

# Obtenir le mot de passe root initial
sudo cat /etc/gitlab/initial_root_password
```

**Docker (Plus simple) :**
```bash
docker run -d \
  --hostname gitlab.example.com \
  -p 443:443 -p 80:80 -p 22:22 \
  --name gitlab \
  --restart always \
  -v gitlab_config:/etc/gitlab \
  -v gitlab_logs:/var/log/gitlab \
  -v gitlab_data:/var/opt/gitlab \
  gitlab/gitlab-ce:latest
```

**Configuration :**
1. Accéder à http://localhost (ou votre URL)
2. Se connecter avec root et le mot de passe initial
3. Créer un projet
4. Configurer les runners GitLab CI/CD

#### Installation GitLab Runner

```bash
# Linux
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
sudo apt-get install gitlab-runner

# macOS
brew install gitlab-runner

# Windows
# Télécharger depuis : https://docs.gitlab.com/runner/install/windows.html
```

**Enregistrer le runner :**
```bash
sudo gitlab-runner register
# Suivre les instructions avec le token du projet GitLab
```

---

## 🔧 Configurations Post-Installation

### 1. Configurer GitLab CI/CD Variables

Dans GitLab → Settings → CI/CD → Variables, ajouter :

- `CI_REGISTRY_USER` : Votre utilisateur Docker registry
- `CI_REGISTRY_PASSWORD` : Votre mot de passe Docker registry
- `CI_REGISTRY` : URL du registry (ex: `registry.gitlab.com`)
- `KUBE_CONTEXT_STAGING` : Contexte Kubernetes staging
- `KUBE_CONTEXT_PRODUCTION` : Contexte Kubernetes production

### 2. Configurer Kubernetes Secrets

```bash
# Créer les secrets pour Keycloak
kubectl create secret generic keycloak-secret \
  --from-literal=admin-password='VotreMotDePasseAdmin' \
  --from-literal=db-password='VotreMotDePasseDB' \
  -n rd-microservices

# Créer les secrets pour Grafana
kubectl create secret generic grafana-secret \
  --from-literal=admin-password='VotreMotDePasseGrafana' \
  -n rd-microservices
```

### 3. Configurer Keycloak Realm

1. Accéder à Keycloak : http://localhost:8090
2. Se connecter (admin / admin123)
3. Importer le realm :
   - Administration → Import realm
   - Sélectionner `keycloak/realm-config/rd-realm.json`
4. Configurer les clients et utilisateurs

### 4. Configurer NGINX avec Keycloak

1. Vérifier que Keycloak est accessible
2. Modifier `nginx/nginx.conf` si nécessaire
3. Rebuild l'image NGINX :
   ```bash
   cd nginx
   docker build -t nginx-gateway .
   ```

### 5. Configurer Prometheus

1. Déployer Prometheus :
   ```bash
   kubectl apply -f monitoring/prometheus/k8s/prometheus.yaml -n rd-microservices
   ```

2. Vérifier les targets : http://localhost:9090/targets

### 6. Configurer Grafana

1. Déployer Grafana :
   ```bash
   kubectl apply -f monitoring/grafana/k8s/grafana.yaml -n rd-microservices
   ```

2. Accéder : http://localhost:3000
3. Login : admin / admin (changer au premier login)
4. Ajouter Prometheus comme datasource
5. Importer les dashboards

### 7. Configurer ELK Stack

1. Déployer ELK :
   ```bash
   kubectl apply -f monitoring/elk/k8s/ -n rd-microservices
   ```

2. Attendre que Elasticsearch soit prêt :
   ```bash
   kubectl wait --for=condition=ready pod -l app=elasticsearch -n rd-microservices --timeout=300s
   ```

3. Accéder à Kibana : http://localhost:5601
4. Configurer les index patterns

---

## ✅ Checklist d'Installation

### Outils de Base
- [ ] Java 17+ installé
- [ ] Maven installé
- [ ] Git installé

### Conteneurisation
- [ ] Docker installé et fonctionnel
- [ ] Docker Compose installé
- [ ] Utilisateur dans le groupe docker (Linux)

### Orchestration
- [ ] Kubernetes (Minikube/kind/k3d) installé
- [ ] kubectl installé et configuré
- [ ] Cluster Kubernetes démarré

### Bases de Données
- [ ] PostgreSQL installé (ou via Docker)
- [ ] Bases de données créées
- [ ] Migrations exécutées

### Sécurité
- [ ] Keycloak installé et démarré
- [ ] Realm importé dans Keycloak
- [ ] NGINX configuré avec Keycloak

### Monitoring
- [ ] Prometheus déployé
- [ ] Grafana déployé
- [ ] Dashboards Grafana importés
- [ ] ELK Stack déployé (optionnel)

### CI/CD
- [ ] GitLab installé ou compte GitLab.com
- [ ] GitLab Runner installé et enregistré
- [ ] Variables CI/CD configurées
- [ ] Registry Docker configuré

---

## 🚨 Problèmes Courants

### Docker : Permission denied
```bash
# Linux : Ajouter l'utilisateur au groupe docker
sudo usermod -aG docker $USER
# Déconnexion/reconnexion nécessaire
```

### Kubernetes : Minikube ne démarre pas
```bash
# Vérifier les prérequis
minikube start --driver=docker --verbose
```

### Keycloak : Erreur de connexion à la base
```bash
# Vérifier que la base Keycloak est démarrée
docker-compose ps
```

### Prometheus : Pas de métriques
```bash
# Vérifier que les services exposent /actuator/prometheus
curl http://localhost:8080/actuator/prometheus
```

---

## 📚 Ressources

- **Docker** : https://docs.docker.com/get-docker/
- **Kubernetes** : https://kubernetes.io/docs/setup/
- **Keycloak** : https://www.keycloak.org/documentation
- **NGINX** : https://nginx.org/en/docs/
- **Prometheus** : https://prometheus.io/docs/prometheus/latest/installation/
- **Grafana** : https://grafana.com/docs/grafana/latest/setup-grafana/installation/
- **ELK Stack** : https://www.elastic.co/guide/en/elastic-stack/index.html
- **GitLab CI/CD** : https://docs.gitlab.com/ee/ci/

---

## 🎯 Prochaines Étapes

Une fois tous les outils installés :

1. Voir `DEPLOYMENT.md` pour déployer l'application
2. Voir `NEXT_STEPS.md` pour tester
3. Voir `PROJECT_IMPLEMENTATION.md` pour comprendre l'architecture

