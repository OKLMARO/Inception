# Inception — User Doc

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

`make stop` 

### Arrêter le projet et vider les contenaires

`make clean`

### Arrêter le projet et vider les contenaires et ses persistences

`make fclean`

## 3. Accéder au site et au panneau d'administration

### Site public

Ouvrir dans le navigateur : `https://oamairi.42.fr` (url definis dans le `srcs/.env`).

Le certificat est auto-signé le message d'avertissement est donc legitime et normal.

### Panneau d'administration

Ouvrir dans le navigateur : `https://oamairi.42.fr/wp-admin`

Le nom d'utilisateur definis dans le .env est `wproot` mais peut etre modifie lui aussi dans `src/.env` comme l'url.

Le mot de passe est disponnible dans le dossier secrets.

## 4. Les secrets

Les mots de passes sont stockes dans le dossier `secrets`.

|Fichier | Contenu|
|-|-|
|`secrets/db_root_password.txt` | Mot de passe root de MariaDB|
|`secrets/db_password.txt`|Mot de passe de l'utilisateur WordPress dans MariaDB|
|`secrets/credentials.txt`|Mots de passe des comptes WordPress (admin + author)|

## 5. Vérifier que les services fonctionnent correctement

### État des conteneurs

Dans la racine du projet faire : `docker compose -f srcs/docker-compose.yml ps`. Et verifier que les trois services sont `UP` et seul nginx expose un port : `0.0.0.0:443->443/tcp`
