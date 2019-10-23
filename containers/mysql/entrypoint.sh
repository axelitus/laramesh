#!/bin/bash
# Reference: https://github.com/ypereirareis/docker-permissions

# check to see if this file is being run or sourced from another script
is_sourced() {
    # https://unix.stackexchange.com/a/215279
    [ "${#FUNCNAME[@]}" -ge 2 ] \
        && [ "${FUNCNAME[0]}" = '_is_sourced' ] \
        && [ "${FUNCNAME[1]}" = 'source' ]
}

change_owner_id() {
    local owner_uid_default=$(id -u mysql)

    # Here we check if GID and UID are already defined properly or not
    # i.e Do we have a volume mounted and with a different uid/gid ?
    if [[ -z "$(ls -n $MYSQL_CONTAINER_DATA_PATH | grep $owner_uid_default)" ]]; then
        : ${APP_OWNER_UID:=$(id -u mysql)}
        : ${APP_OWNER_GID:=$(id -g mysql)}

        export APP_OWNER_UID
        export APP_OWNER_GID

        if [ "$APP_OWNER_UID" != "0" ] && [ "$APP_OWNER_UID" != "$(id -u mysql)" ]; then
            echo "Changing data owner UID and GID..."
            usermod  -u $APP_OWNER_UID mysql
            groupmod -g $APP_OWNER_GID mysql
            chown -R mysql: $MYSQL_CONTAINER_DATA_PATH /var/run/mysqld /var/log/mysql
            echo "Data owner UID and GID changed to $APP_OWNER_UID and $APP_OWNER_GID."
        fi
    else
        echo "Data owner UID and GUI are OK!"
    fi
}

initialize_mysql() {
    local create_schema=
    local mysql_files=$(ls -A $MYSQL_CONTAINER_DATA_PATH)

    if [[ ! -z "$MYSQL_CREATE_SCHEMA" ]]; then
        read -r -d '' create_schema <<-EOSQL
            CREATE SCHEMA IF NOT EXISTS \`${MYSQL_CREATE_SCHEMA}\`;
EOSQL
    fi;

    if [[ ${#mysql_files[@]} -eq 1 && "${mysql_files[0]}" = ".gitkeep" ]]; then
        echo "Initializing mysql data folder..."
        mysqld --initialize-insecure
        echo "Mysql data folder initialized."

        echo "Configuring mysql server..."
        mysqld --daemonize --skip-networking
        mysql -uroot -hlocalhost <<-EOSQL
            SET @@SESSION.SQL_LOG_BIN=0;

            ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
            GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
            FLUSH PRIVILEGES;

            CREATE USER '${MYSQL_ROOT_USER}'@'0.0.0.0' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
            CREATE USER '${MYSQL_ROOT_USER}'@'%' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
            GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ROOT_USER}'@'0.0.0.0' WITH GRANT OPTION;
            GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ROOT_USER}'@'%' WITH GRANT OPTION;
            FLUSH PRIVILEGES;

            ${create_schema}

            DROP DATABASE IF EXISTS test;
EOSQL
        mysqladmin -uroot -p${MYSQL_ROOT_PASSWORD} shutdown
        echo "Mysql server configured."
    else
        echo "Mysql server already initialized!"
    fi;
}

main() {
    echo "Data path: $MYSQL_CONTAINER_DATA_PATH"

    change_owner_id
    initialize_mysql

    exec "$@"
}

# entrypoint
if ! is_sourced; then
    main "$@"
fi
