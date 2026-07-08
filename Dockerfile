FROM nginx:stable-alpine

RUN apk add --no-cache certbot curl bash openssl

RUN mkdir -p /etc/letsencrypt/active /var/www/certbot

RUN openssl req -x509 -nodes -newkey rsa:4096 \
    -keyout /etc/letsencrypt/active/privkey.pem \
    -out /etc/letsencrypt/active/fullchain.pem \
    -days 365 \
    -subj "/CN=Signal TLS Proxy (temp)" 2>/dev/null

RUN curl -s https://raw.githubusercontent.com/certbot/certbot/main/certbot/src/certbot/_internal/plugins/nginx/tls_configs/options-ssl-nginx.conf \
    -o /etc/letsencrypt/options-ssl-nginx.conf && \
    curl -s https://raw.githubusercontent.com/certbot/certbot/main/certbot/src/certbot/ssl-dhparams.pem \
    -o /etc/letsencrypt/ssl-dhparams.pem

COPY nginx.conf /etc/nginx/nginx.conf

COPY start.sh /start.sh
RUN chmod +x /start.sh

COPY init-certificate.sh /init-certificate.sh
RUN chmod +x /init-certificate.sh

EXPOSE 443 80 8080

CMD ["/start.sh"]
