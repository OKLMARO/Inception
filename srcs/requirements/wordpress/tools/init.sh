#!/bin/bash
set -e

WP_PATH="/var/www/html"

# --- Récupération des secrets ---
DB_PASSWORD=$(cat /run/secrets/db_password)
set -a
. /run/secrets/credentials
set +a

# --- Attente de MariaDB (TCP) ---
echo ">>> Attente de MariaDB..."
until bash -c "</dev/tcp/mariadb/3306" 2>/dev/null; do
    sleep 1
done
echo ">>> MariaDB joignable."

# --- Étape 1 : Téléchargement de WordPress (une seule fois) ---
if [ ! -f "${WP_PATH}/wp-load.php" ]; then
    echo ">>> Téléchargement de WordPress..."
    mkdir -p "${WP_PATH}"
    chown -R www-data:www-data "${WP_PATH}"
    wp core download --path="${WP_PATH}" --allow-root
fi

# --- Étape 2 : Génération de wp-config.php (une seule fois) ---
if [ ! -f "${WP_PATH}/wp-config.php" ]; then
    echo ">>> Génération de wp-config.php..."
    wp config create \
        --path="${WP_PATH}" \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="mariadb" \
        --allow-root --skip-check
fi

# --- Étape 3 : Attente que MariaDB accepte VRAIMENT wp_user ---
echo ">>> Vérification de la connexion DB..."
until wp db check --path="${WP_PATH}" --allow-root > /dev/null 2>&1; do
    echo "    ... DB pas encore prête pour wp_user, retry..."
    sleep 2
done
echo ">>> Connexion DB OK."

# --- Étape 4 : Installation WordPress (une seule fois, test réel) ---
if ! wp core is-installed --path="${WP_PATH}" --allow-root > /dev/null 2>&1; then
    echo ">>> Installation de WordPress..."
    wp core install \
        --path="${WP_PATH}" \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --path="${WP_PATH}" \
        --allow-root

    echo ">>> WordPress installé."
fi

# --- Permissions finales ---
chown -R www-data:www-data "${WP_PATH}"

# --- Lancement de PHP-FPM en PID 1 ---
exec php-fpm8.2 -F
