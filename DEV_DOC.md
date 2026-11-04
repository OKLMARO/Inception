# Inception — DEV DOC

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

