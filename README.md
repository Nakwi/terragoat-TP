# TerraGoat-TP — Sécurisation d'une infrastructure Azure as Code

> **TP DevSecOps — Ynov Marseille · M1 Cloud, Sécurité & Infrastructure**
> Analyse statique IaC avec Checkov · Remédiation des vulnérabilités · Pipeline CI/CD · Déploiement réel sur Azure

[![Checkov](https://img.shields.io/badge/Scanner-Checkov-0E7C86)](https://www.checkov.io/)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Cloud-Azure-0078D4)](https://azure.microsoft.com/)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF)](https://github.com/features/actions)

---

## Sommaire

- [1. Sujet du TP](#1-sujet-du-tp)
- [2. Mise en place du dépôt (fork Git)](#2-mise-en-place-du-dépôt-fork-git)
- [3. Analyse des vulnérabilités](#3-analyse-des-vulnérabilités)
- [4. Corrections appliquées dans Terraform](#4-corrections-appliquées-dans-terraform)
- [5. Ressources déployées sur Azure](#5-ressources-déployées-sur-azure)
- [6. Le pipeline CI/CD](#6-le-pipeline-cicd)
- [7. Fonctionnement et exécution](#7-fonctionnement-et-exécution)
- [8. Bilan](#8-bilan)

---

## 1. Sujet du TP

Ce projet part de **[TerraGoat](https://github.com/bridgecrewio/terragoat)**, un dépôt Terraform **volontairement vulnérable** publié par Bridgecrew. Il reproduit les mauvaises configurations que l'on retrouve réellement dans des environnements cloud de production (secrets en clair, ports ouverts, bases publiques, IAM trop permissif).

**Objectif :** mettre en œuvre une démarche **DevSecOps complète** sur le périmètre Azure du projet.

| Étape | Description |
|-------|-------------|
| **Détecter** | Scanner l'infrastructure as code avec Checkov pour lister les vulnérabilités |
| **Corriger** | Remédier les failles, en priorité les plus critiques |
| **Automatiser** | Mettre en place un pipeline CI/CD qui bloque sur les failles critiques |
| **Déployer** | Valider la correction par un déploiement réel sur Azure |

> **Périmètre de travail :** dossier [`terraform/azure/`](terraform/azure) uniquement.

---

## 2. Mise en place du dépôt (fork Git)

Le projet a été initialisé par un **fork** du dépôt officiel de Bridgecrew, afin de travailler sur une copie personnelle tout en conservant l'historique d'origine.

```bash
# 1. Fork de bridgecrewio/terragoat -> Nakwi/terragoat-TP (via l'interface GitHub)

# 2. Clone du fork en local
git clone https://github.com/Nakwi/terragoat-TP.git
cd terragoat-TP
```

### Organisation des branches

Le projet suit un workflow Git structuré avec des branches dédiées, pour séparer le développement des correctifs de la branche stable.

| Branche | Rôle |
|---------|------|
| `master` | Branche principale et stable, intègre le code corrigé validé et le pipeline CI/CD |
| `dev` | Branche d'intégration du développement |
| `dev-ryan` | Branche de travail personnelle pour développer et tester les correctifs |
| `pre-merge` | Branche de pré-fusion, pour valider l'ensemble avant intégration dans `master` |

Le flux de travail suivi : développement des correctifs sur `dev-ryan` → intégration sur `dev` → validation sur `pre-merge` → fusion dans `master` via Pull Request une fois le pipeline au vert. L'historique compte plus de 300 commits retraçant l'ensemble de la démarche de remédiation.

### Structure du dépôt

```
terragoat-TP/
├── .github/
│   └── workflows/
│       └── checkov.yml        # Pipeline CI/CD (scan + déploiement)
├── terraform/
│   ├── azure/                 # <- périmètre du TP (corrigé)
│   ├── aws/                   # non traité
│   └── gcp/                   # non traité
└── README.md
```

---

## 3. Analyse des vulnérabilités

Le scan initial de Checkov sur `terraform/azure/` (infrastructure d'origine) remonte un grand nombre de mauvaises configurations.

```bash
cd terraform/azure
checkov -d . --compact
```

**Résultat initial :**

```
Passed checks: 68, Failed checks: 174, Skipped checks: 0
```

> Les 174 findings correspondent à 68 contrôles distincts (un même contrôle peut concerner plusieurs ressources). Parmi eux, les contrôles **critiques** sont ceux qui exposent réellement l'infrastructure : ports d'administration ouverts, bases publiques, secrets en clair, IAM trop permissif, absence de RBAC.

---

## 4. Corrections appliquées dans Terraform

Toutes les corrections ci-dessous ont été apportées dans le code Terraform du dossier `terraform/azure/`. Le tableau liste l'ensemble des contrôles **passés de FAILED à PASSED** après remédiation.

### Vulnérabilités critiques corrigées

| Contrôle Checkov | Fichier | Vulnérabilité corrigée | Correctif appliqué |
|------------------|---------|------------------------|--------------------|
| `CKV_AZURE_10` | networking.tf | Accès SSH (port 22) ouvert à Internet | Restriction des sources autorisées dans le NSG |
| `CKV_AZURE_9` | networking.tf | Accès RDP (port 3389) ouvert à Internet | Restriction des sources autorisées dans le NSG |
| `CKV_AZURE_113` | mssql.tf | Serveurs MSSQL avec accès réseau public | `public_network_access_enabled = false` |
| `CKV_AZURE_53` | sql.tf | Serveur MySQL avec accès réseau public | `public_network_access_enabled = false` |
| `CKV_AZURE_68` | sql.tf | Serveur PostgreSQL avec accès réseau public | Accès réseau public désactivé |
| `CKV_AZURE_28` | sql.tf | MySQL sans connexion SSL forcée | `ssl_enforcement_enabled = true` |
| `CKV_AZURE_29` | sql.tf | PostgreSQL sans connexion SSL forcée | `ssl_enforcement_enabled = true` |
| `CKV_AZURE_39` | roles.tf | Rôle personnalisé avec droits d'owner de souscription | Moindre privilège : rôle restreint en lecture seule |
| `CKV_AZURE_1` | instance.tf | VM Linux autorisant l'authentification basique | Authentification par clé SSH RSA 4096 |
| `CKV_AZURE_149` | instance.tf | VM Linux autorisant le mot de passe | Authentification par mot de passe désactivée |
| `CKV_AZURE_5` | aks.tf | Cluster AKS sans contrôle d'accès (RBAC) | `role_based_access_control_enabled = true` |
| *(secrets)* | key_vault.tf | Mots de passe / secrets écrits en clair dans le code | Externalisation vers **Azure Key Vault** |

### Remédiation étendue (bonnes pratiques)

| Contrôle Checkov | Fichier | Vulnérabilité corrigée | Correctif appliqué |
|------------------|---------|------------------------|--------------------|
| `CKV_AZURE_52` | mssql.tf | MSSQL (7 serveurs) n'utilise pas la dernière version de TLS | `minimum_tls_version = "1.2"` |
| `CKV_AZURE_54` | sql.tf | MySQL n'utilise pas la dernière version de TLS | TLS 1.2 imposé |
| `CKV_AZURE_147` | sql.tf | PostgreSQL n'utilise pas la dernière version de TLS | TLS 1.2 imposé |
| `CKV_AZURE_25` | mssql.tf / sql.tf | Threat Detection non réglée sur « All » | Détection de menaces complétée |
| `CKV_AZURE_26` | mssql.tf / sql.tf | Destinataires d'alertes non configurés | `send_alerts_to` configuré |
| `CKV_AZURE_27` | mssql.tf / sql.tf | Pas de notification e-mail aux administrateurs | `email_account_admins = true` |
| `CKV_AZURE_3` | storage.tf | Transfert de données non sécurisé | `enable_https_traffic_only = true` |

> **Note :** la liste exacte des contrôles PASSED s'obtient avec
> `checkov -d . --compact | grep -B1 "PASSED" | grep -oP "CKV_AZURE_\d+" | sort -u`.
> Ce tableau peut être ajusté selon le résultat final du scan.

### Résultat de la remédiation

| | Contrôles conformes | Findings (failed) |
|---|:---:|:---:|
| **Avant** | 68 | 174 |
| **Après** | **107** | **109** |

> **65 vulnérabilités corrigées** · **+39 contrôles conformes** · **0 vulnérabilité critique restante**

Les findings résiduels (chiffrement par clé client / CMK, vulnerability assessment, durcissements App Service, etc.) sont des **risques acceptés et documentés** — TerraGoat restant volontairement partiellement vulnérable pour conserver sa vocation pédagogique.

---

## 5. Ressources déployées sur Azure

Le pipeline ne fait pas que scanner : il **déploie réellement** l'infrastructure corrigée sur une souscription Azure (environ 37 ressources).

| Catégorie | Ressources déployées |
|-----------|----------------------|
| **Kubernetes** | Cluster **AKS** (`terragoat-aks-dev`) avec RBAC activé |
| **Bases de données** | **MySQL Flexible Server** · **PostgreSQL Flexible Server** · **8 × Azure SQL Server** + alert policies |
| **Secrets** | **Azure Key Vault** + secrets + clé générée |
| **Machines virtuelles** | VM **Linux** (clé SSH) + VM **Windows** |
| **Réseau** | Virtual Network, subnet, **NSG** avec règles restreintes |
| **Stockage** | 2 × Storage Account (dont un dédié à l'audit de sécurité) |
| **Gouvernance** | Azure Policy (définition + assignation), Log Profile, rôles IAM |

> **Région retenue : `Sweden Central`** — seule région disponible sur la souscription *Azure for Students* à supporter l'ensemble des services (AKS, bases Flexible Server, tailles de VM `Standard_B2as_v2`). La migration du provider `azurerm` (v2 vers v3) a été nécessaire pour basculer les bases *Single Server* (supprimées par Azure) vers *Flexible Server*.

---

## 6. Le pipeline CI/CD

Le pipeline est défini dans [`.github/workflows/checkov.yml`](.github/workflows/checkov.yml) et s'exécute à chaque `push` sur `master` (chemin `terraform/azure/**`).

### Architecture à deux étages

```
   Push                Job 1 : Scan              Job 2 : Deploy           Azure
 +--------+  ------>  +--------------+  --si OK--> +--------------+  -->  (cloud)
 |  git   |           | Validate +   |             | Plan + Apply |
 |  push  |           | Checkov      |             | (reel)       |
 +--------+           | (bloquant)   |             +--------------+
                      +--------------+
                       X bloque si une faille
                         CRITIQUE est detectee
```

| Étage | Rôle |
|-------|------|
| **Job 1 — `security-scan`** | `terraform validate` + scan Checkov. **Bloque** le pipeline (`hard_fail_on`) si l'un des contrôles critiques échoue. Publie un rapport **SARIF** dans l'onglet *Security* de GitHub. |
| **Job 2 — `terraform-apply`** | `needs: security-scan` → ne s'exécute **que si le scan passe**. Réalise le `plan` puis l'`apply` réel sur Azure. |

### Le cœur DevSecOps

> La sécurité est un **prérequis au déploiement**. Tant qu'une vulnérabilité critique est présente, le pipeline **bloque** et rien n'est déployé. Les 8 contrôles critiques câblés dans le `hard_fail_on` garantissent qu'aucune de ces failles ne peut être réintroduite.

### Authentification hybride vers Azure

Deux canaux d'authentification distincts, choisis selon la contrainte de version du provider.

| Composant | Méthode | Pourquoi |
|-----------|---------|----------|
| **Backend (state)** | **OIDC** (sans secret) | Le state Terraform est stocké dans un Storage Account Azure avec le rôle *Storage Blob Data Contributor* (moindre privilège) |
| **Provider `azurerm`** | **Service Principal** + secret | L'OIDC côté provider n'existe qu'à partir d'`azurerm` v3.7 ; un Service Principal est requis pour la compatibilité de version |

---

## 7. Fonctionnement et exécution

### Prérequis

- Terraform >= 1.x
- Azure CLI (`az`) connecté à la souscription
- Un Service Principal (App Registration) avec les droits adéquats
- Les variables / secrets GitHub configurés :
  - Variables : `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`
  - Secret : `AZURE_CLIENT_SECRET`

### Lancer un scan en local

```bash
cd terraform/azure
checkov -d . --compact
```

### Déclencher le pipeline

```bash
# Toute modification poussée sur master déclenche le pipeline
git add terraform/azure/
git commit -m "Correction d'une vulnérabilité"
git push origin master
```

### Détruire l'infrastructure (nettoyage)

```bash
cd terraform/azure
terraform destroy
# Penser à purger le Key Vault en soft-delete après destruction :
# az keyvault purge --name <nom-du-vault>
```

### Captures du fonctionnement

| Capture | Description |
|---------|-------------|
| [![Pipeline vert](https://i.goopics.net/845spy.png)](https://goopics.net/i/845spy) | Pipeline GitHub Actions 100 % vert (scan + déploiement) |
| [![Checkov avant](https://i.goopics.net/4xi7hu.png)](https://goopics.net/i/4xi7hu) | Scan Checkov de l'infrastructure d'origine (68 / 174) |
| [![Checkov après](https://i.goopics.net/xdbyn2.png)](https://goopics.net/i/xdbyn2) | Scan Checkov après remédiation (107 / 109) |
| [![Ressources Azure](https://i.goopics.net/7qxhym.png)](https://goopics.net/i/7qxhym) | Ressources déployées dans le Resource Group Azure |

---

## 8. Bilan

| Indicateur | Résultat |
|------------|----------|
| **Détection** | Scan Checkov automatisé, intégré à GitHub Security (SARIF) |
| **Correction** | 68 → 107 contrôles conformes · **0 vulnérabilité critique** restante |
| **Automatisation** | Pipeline qui **refuse le déploiement** tant qu'une faille critique existe |
| **Déploiement** | Infrastructure réellement créée sur Azure, puis détruite proprement |

> **Leçon clé :** le code d'infrastructure vieillit — la sécurité doit être **maintenue dans le temps, automatisée**, et pensée avec les contraintes réelles du cloud (versions de provider, services dépréciés, régions disponibles, cycle de vie des ressources).

---

**Ryan Corsyn** · M1 Cloud, Sécurité & Infrastructure · Ynov Marseille
*Projet basé sur [bridgecrewio/terragoat](https://github.com/bridgecrewio/terragoat)*
