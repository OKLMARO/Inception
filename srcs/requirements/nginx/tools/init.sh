#!/bin/bash
set -e

if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    echo ">>> Génération du certificat auto-signé pour ${DOMAIN_NAME}..."
    mkdir -p /etc/nginx/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out    /etc/nginx/ssl/nginx.crt \
        -subj "/C=FR/ST=IdF/L=Paris/O=42/OU=Inception/CN=${DOMAIN_NAME}" \
        -addext "subjectAltName=DNS:${DOMAIN_NAME}"
fi

envsubst '${DOMAIN_NAME}' < /etc/nginx/templates/default.conf.template \
    > /etc/nginx/conf.d/default.conf

nginx -t
exec nginx -g 'daemon off;'
