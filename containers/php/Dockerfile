FROM ubuntu:18.04
LABEL maintainer="Axel Pardemann <axel.pardemann@norse.blue>"

ARG APP_PATH

RUN set -x \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        apt-transport-https \
        software-properties-common \
        vim \
    && apt-add-repository -y ppa:ondrej/php \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        php7.3 \
        php7.3-bcmath \
        php7.3-cli \
        php7.3-curl \
        php7.3-fpm \
        php7.3-gd \
        php7.3-json \
        php7.3-mbstring \
        php7.3-mysql \
        php7.3-opcache \
        php7.3-sqlite3 \
        php7.3-xml \
        php7.3-zip \
        php-xdebug \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /run/php
COPY ./config/cli/php.ini /etc/php/7.3/cli/php.ini
COPY ./config/fpm/php-fpm.conf /etc/php/7.3/fpm/php-fpm.conf
COPY ./config/fpm/php.ini /etc/php/7.3/fpm/php.ini
COPY ./config/fpm/pool.d/app.conf /etc/php/7.3/fpm/pool.d/www.conf
COPY ./config/modules/xdebug.ini /etc/php/7.3/mods-available/xdebug.ini

RUN ln -fs /etc/php/7.3/mods-available/xdebug.ini /etc/php/7.3/fpm/conf.d/20-xdebug.ini

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000
STOPSIGNAL SIGQUIT
WORKDIR ${APP_PATH}

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm7.3"]
