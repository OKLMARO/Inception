# Inception — Documentation utilisateur

Ce document explique comment utiliser l'infrastructure Inception : quels services elle fournit, comment la démarrer, y accéder, gérer les identifiants et vérifier son bon fonctionnement.

## 1. Services fournis par la stack

Inception déploie un site web WordPress complet et sécurisé, réparti en trois services indépendants, chacun dans son propre conteneur Docker :

| Service | Rôle | Accès |
|---|---|---|
| **nginx** | Point d'entrée unique. Sert le site en HTTPS (TLS 1.2/1.3) sur le port 443. | Public (443) |
| **wordpress** | Application web WordPress + PHP-FPM. Génère les pages dynamiques. | Interne uniquement (9000) |
| **mariadb** | Base de données stockant tout le contenu du site (articles, utilisateurs, options). | Interne uniquement (3306) |

Les trois conteneurs communiquent via un réseau Docker dédié (`inception`).
Seul **nginx** est exposé à l'extérieur — WordPress et MariaDB ne sont jamais accessibles directement depuis l'hôte.

Les données (base de données et fichiers du site) sont persistantes : elles survivent aux redémarrages et sont stockées sur l'hôte dans `/home/login/data/{mariadb,wordpress}`.

## 2. Démarrer et arrêter le projet

### Prérequis

- Une machine avec Docker et Docker Compose installés.
- L'utilisateur courant doit appartenir au groupe `docker` ou `sudo`.

### Démarrer le projet

Pour lancer le projet depuis la racine du projet : `make`.

Si il est necessaire de le lancer a la main depuis la racine du projet : `docker compose -f srcs/docker-compose.yml` (le -f sert a indiquer le chemin jusqu'au fichier `.yml`).

### Arrêter le projet

`make down` 

`make stop`

### Supprimer le projet et ses persistences

`make fclean`
