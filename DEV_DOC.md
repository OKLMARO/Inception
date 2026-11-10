# Inception — Dev Doc

Ce document s'adresse aux développeurs et administrateurs système qui souhaitent
comprendre l'architecture interne du projet, intervenir sur le code ou maintenir
l'infrastructure.

---

## 1. Architecture et flux réseau

L'infrastructure est composée de trois services conteneurisés, connectés via un réseau Docker bridge dédié (`inception`).

- **NGINX** est le seul service exposé à l'extérieur (port 443). Il termine le
  TLS et transmet les requêtes PHP à WordPress via FastCGI.
- **WordPress** n'est accessible que depuis le réseau interne. Il communique
  avec MariaDB pour lire/écrire le contenu.
- **MariaDB** n'est accessible que depuis WordPress. Aucun accès externe.

---

## 2. Choix techniques et justifications

| Choix | Justification |
|---|---|
| **Debian bookworm** comme image de base | Stabilité, paquets à jour, compatibilité avec les outils 42. |
| **Un Dockerfile par service** | Isolation, builds reproductibles, respect du sujet. |
| **Docker Secrets** (`/run/secrets/`) | Aucun mot de passe dans le code ou les images. |
| **Volumes nommés avec `driver_opts`** | Les données sont persistantes et stockées sur l'hôte (`/home/login/data`). |
| **Entrypoints idempotents** | Chaque script teste l'état réel avant d'agir (pas de double installation). |
| **TLSv1.2 + TLSv1.3 uniquement** | Pas de fallback vers des protocoles obsolètes (TLS 1.0/1.1). |
| **PID 1 pour chaque service** | `exec` dans les entrypoints : nginx `daemon off`, php-fpm `-F`, mariadbd au premier plan. |
| **Makefile comme point d'entrée** | Build, lancement et nettoyage en une commande. |

---

## 3. Gestion des données et persistance

Base de données : stockée dans le volume Docker srcs_mariadb_data, monté sur /home/login/data/mariadb sur l'hôte.

Fichiers WordPress : stockés dans le volume Docker srcs_wordpress_data, monté sur /home/login/data/wordpress.

Persistance : un docker compose restart ne réinitialise pas les données. Un make fclean supprime les volumes Docker et les dossiers sur l'hôte.

---

## 4. Arborescence du projet

```
.
├── Makefile
├── DEV_DOC.md
├── USER_DOC.md
├── README.md
├── tools/
├── bonus/
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
├── srcs/
│   ├── docker-compose.yml
│   ├── .env
│   └── requirements/
│       ├── nginx/
│       │   ├── Dockerfile
│       │   ├── conf/
|       │   │   └── default.conf
│       │   └── tools/
|       │   │   └── init.sh
│       ├── wordpress/
│       │   ├── Dockerfile
│       │   ├── conf/
|       │   │   └── www.conf
│       │   └── tools/
|       │   │   └── init.sh
│       └── mariadb/
│       │   ├── .dockerignore
│       │   ├── Dockerfile
│       │   ├── conf/
|       │   │   └── my.cnf
│       │   └── tools/
└──     └── └── └── init.sh
```

Les scripts d'initialisation sont présents dans le dossier `tools` de chaque service. Les fichiers de configuration ainsi que les `Dockerfile` sont également situés dans les répertoires respectifs de chaque service.

Par ailleurs, un fichier `.dockerignore` est présent dans chaque service afin de contrôler les fichiers transmis au contexte de construction de l'image Docker. Cela permet de ne transférer que les éléments strictement nécessaires, d'éviter d'alourdir inutilement les images et de prévenir l'inclusion accidentelle de fichiers sensibles.

---

## 6. Fonctionnement des entrypoints

|Service|Fonctionnement à documenter|
|--|--|
|Nginx|Crée un certificat auto-signé au premier démarrage (SAN avec `${DOMAIN_NAME}`, pas de port). Si nginx.crt existe, ne régénère pas (le cert persiste dans l'image ou un volume). Remplace `${DOMAIN_NAME}` et `${PORT}` dans la conf → nginx ne les lit pas nativement. Valide la conf avant de lancer → crash propre si erreur. nginx en PID 1, mode foreground.|
|Wordpress|Évite de démarrer avant que MariaDB soit joignable. Récupère les fichiers WP une seule fois (test wp-load.php). Génère wp-config.php avec les secrets → aucun mdp en clair. Attend que MariaDB accepte les identifiants. Installe ce qui n'est déjà fait. Creer les utilisateurs. Resynchronise les URLs à chaque démarrage (gère le changement de port). PHP-FPM en PID 1, mode foreground.|
|MaraiDB|Récupère les mots de passe depuis `/run/secrets/`. Si la base existe déjà, on saute l'initialisation. Crée les tables système. Démarre MariaDB sans réseau pour créer la base et les users sans risque. MariaDB devient PID 1 → reçoit les signaux Docker directement.|

## 7. Prérequis

Avant de construire l’infrastructure, assurez-vous que les outils suivants sont installés :

- Docker
- Docker Compose
- Make

L’utilisateur doit également disposer des autorisations nécessaires pour exécuter les commandes Docker.

Le nom de domaine doit être configuré dans le fichier des hôtes locaux :

127.0.0.1 login.42.fr
