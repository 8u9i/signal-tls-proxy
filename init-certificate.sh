#!/bin/bash
set -e

CERTS_DIR="/etc/letsencrypt"
WEBROOT="/var/www/certbot"

read -p "Enter domain name (eg. proxy.example.com): " domains

if [ ! -e "$CERTS_DIR/options-ssl-nginx.conf" ] || [ ! -e "$CERTS_DIR/ssl-dhparams.pem" ]; then
    echo "### Downloading recommended TLS parameters ..."
    mkdir -p "$CERTS_DIR"
    curl -s https://raw.githubusercontent.com/certbot/certbot/main/certbot/src/certbot/_internal/plugins/nginx/tls_configs/options-ssl-nginx.conf > "$CERTS_DIR/options-ssl-nginx.conf"
    curl -s https://raw.githubusercontent.com/certbot/certbot/main/certbot/src/certbot/ssl-dhparams.pem > "$CERTS_DIR/ssl-dhparams.pem"
fi

echo "### Requesting Let's Encrypt certificate for $domains ..."

certbot certonly --webroot -w "$WEBROOT" \
    --register-unsafely-without-email \
    -d "$domains" \
    --agree-tos \
    --force-renewal

echo "### Symlinking active certificate ..."
rm -f "$CERTS_DIR/active"
ln -sf "/etc/letsencrypt/live/$domains" "$CERTS_DIR/active"

echo ""
echo "Certificate obtained! Reload nginx to pick it up: nginx -s reload"
echo "Share your proxy as: https://signal.tube/#$domains"
