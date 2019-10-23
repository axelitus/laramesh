FROM ubuntu:18.04
LABEL maintainer="Axel Pardemann <axel.pardemann@norse.blue>"

ARG APP_CONTAINER_PATH

RUN set -x \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        apt-transport-https \
        gettext \
        software-properties-common \
        vim \
    && apt-add-repository -y ppa:nginx/stable \
    && apt-get install -y nginx \
    && rm -rf /var/lib/apt/lists/*

COPY ./config/nginx.conf /etc/nginx/nginx.conf
COPY ./config/templates/app.conf.template /etc/nginx/templates/default.template

RUN set -x \
    && mkdir -p ${APP_CONTAINER_PATH} \
    && chown -R www-data:www-data ${APP_CONTAINER_PATH}

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80
STOPSIGNAL SIGTERM
WORKDIR ${APP_CONTAINER_PATH}

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
