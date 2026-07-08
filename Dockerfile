FROM nginx:stable-alpine

RUN apk add --no-cache certbot curl bash openssl

COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /etc/letsencrypt/active /var/www/certbot

COPY start.sh /start.sh
RUN chmod +x /start.sh

COPY init-certificate.sh /init-certificate.sh
RUN chmod +x /init-certificate.sh

EXPOSE 443 80 8080

CMD ["/start.sh"]
