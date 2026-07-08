#!/bin/bash
set -e

CERTS_DIR="/etc/letsencrypt"
ACTIVE_LINK="$CERTS_DIR/active"

if [ ! -f "$ACTIVE_LINK/fullchain.pem" ]; then
    echo "No Let's Encrypt certificates found. Generating self-signed temporary certificate..."

    mkdir -p "$CERTS_DIR/active"

    openssl req -x509 -nodes -newkey rsa:4096 \
        -keyout "$ACTIVE_LINK/privkey.pem" \
        -out "$ACTIVE_LINK/fullchain.pem" \
        -days 365 \
        -subj "/CN=Signal TLS Proxy (temp)" 2>/dev/null

    if [ ! -f "$CERTS_DIR/options-ssl-nginx.conf" ]; then
        curl -s https://raw.githubusercontent.com/certbot/certbot/main/certbot/src/certbot/_internal/plugins/nginx/tls_configs/options-ssl-nginx.conf > "$CERTS_DIR/options-ssl-nginx.conf" 2>/dev/null
        curl -s https://raw.githubusercontent.com/certbot/certbot/main/certbot/src/certbot/ssl-dhparams.pem > "$CERTS_DIR/ssl-dhparams.pem" 2>/dev/null
    fi

    echo "Temporary certificate generated. To get a real Let's Encrypt certificate, run:"
    echo "  /init-certificate.sh"
    echo ""
fi

mkdir -p /var/www/certbot

echo "Starting nginx..."
exec nginx -g "daemon off;"
