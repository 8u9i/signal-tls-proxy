#!/bin/bash
set -e

CERTS_DIR="/etc/letsencrypt"

read -p "Enter domain name (eg. proxy.example.com): " domain

if [ ! -e "$CERTS_DIR/options-ssl-nginx.conf" ] || [ ! -e "$CERTS_DIR/ssl-dhparams.pem" ]; then
    echo "### Downloading recommended TLS parameters ..."
    mkdir -p "$CERTS_DIR"
    curl -s https://raw.githubusercontent.com/certbot/certbot/main/certbot/src/certbot/_internal/plugins/nginx/tls_configs/options-ssl-nginx.conf > "$CERTS_DIR/options-ssl-nginx.conf"
    curl -s https://raw.githubusercontent.com/certbot/certbot/main/certbot/src/certbot/ssl-dhparams.pem > "$CERTS_DIR/ssl-dhparams.pem"
fi

echo "### Stopping nginx to free port 443 ..."
nginx -s stop 2>/dev/null || true
sleep 1

echo "### Requesting Let's Encrypt certificate for $domain (TLS-ALPN-01 on port 443) ..."
certbot certonly --standalone \
    --preferred-challenges tls-alpn-01 \
    --register-unsafely-without-email \
    -d "$domain" \
    --agree-tos \
    --force-renewal

echo "### Symlinking active certificate ..."
rm -f "$CERTS_DIR/active"
ln -sf "/etc/letsencrypt/live/$domain" "$CERTS_DIR/active"

echo "### Restarting nginx ..."
nginx

echo ""
echo "Certificate obtained! Share your proxy as: https://signal.tube/#$domain"
