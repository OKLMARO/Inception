
FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
        nginx \
        openssl \
        gettext-base \
        bash \
    && rm -rf /var/lib/apt/lists/*

COPY conf/default.conf /etc/nginx/templates/default.conf.template

COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

EXPOSE 443

RUN rm -f /etc/nginx/sites-enabled/default

ENTRYPOINT ["/usr/local/bin/init.sh"]
