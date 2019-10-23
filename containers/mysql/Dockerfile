FROM ubuntu:18.04
LABEL maintainer="Axel Pardemann <axel.pardemann@norse.blue>"

ARG MYSQL_CONTAINER_DATA_PATH

RUN set -x \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        apt-transport-https \
        gnupg \
        software-properties-common \
        vim \
        wget \
    && rm -rf /var/lib/apt/lists/*

RUN set -x \
    && export DEBIAN_FRONTEND=noninteractive \
    && wget https://dev.mysql.com/get/mysql-apt-config_0.8.14-1_all.deb -O /tmp/mysql-apt-config.deb \
    && dpkg -i /tmp/mysql-apt-config.deb \
    && rm /tmp/mysql-apt-config.deb \
    && apt-get update \
    && { \
        echo mysql-server mysql-server/root-pass password '${MYSQL_ROOT_PASSWORD}'; \
        echo mysql-server mysql-server/re-root-pass password '${MYSQL_ROOT_PASSWORD}'; \
        echo mysql-server mysql-server/remove-test-db select true; \
    } | debconf-set-selections \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        mysql-client \
        mysql-server \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf ${MYSQL_CONTAINER_DATA_PATH} \
    && mkdir -p ${MYSQL_CONTAINER_DATA_PATH} /var/run/mysqld \
    && chown -R mysql:mysql ${MYSQL_CONTAINER_DATA_PATH} /var/run/mysqld \
    && chmod 777 /var/run/mysqld \
    && ln -fs /usr/share/mysql-8.0 /usr/share/mysql \
    && ln -fs errmsg-utf8.txt /usr/share/mysql-8.0/errmsg.sys

COPY ./config/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3306
STOPSIGNAL SIGTERM
WORKDIR ${MYSQL_CONTAINER_DATA_PATH}

ENTRYPOINT ["/entrypoint.sh"]
CMD ["mysqld"]
