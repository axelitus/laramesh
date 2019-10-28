#!/bin/bash
# Reference: https://github.com/ypereirareis/docker-permissions

# check to see if this file is being run or sourced from another script
is_sourced() {
    # https://unix.stackexchange.com/a/215279
    [[ "${#FUNCNAME[@]}" -ge 2 ]] \
        && [[ "${FUNCNAME[0]}" = '_is_sourced' ]] \
        && [[ "${FUNCNAME[1]}" = 'source' ]]
}

register_env_vars() {
    : ${APP_OWNER_UID:=$(id -u www-data)} ; export APP_OWNER_UID
    : ${APP_OWNER_GID:=$(id -g www-data)} ; export APP_OWNER_GID
    : ${APP_CONTAINER_PATH:=/app} ; export APP_CONTAINER_PATH
}

change_owner_id() {
    local owner_uid_default=$(id -u www-data)
    local owner_gid_default=$(id -u www-data)

    # Here we check if GID and UID are already defined properly or not
    # i.e Do we have a volume mounted and with a different uid/gid ?
    if [[ "$APP_OWNER_UID" != "$owner_uid_default" || "$APP_OWNER_GID" != "$owner_gid_default" ]]; then
        if [[ "$APP_OWNER_UID" != "0" && "$APP_OWNER_GID" != "0" ]]; then
            echo "Changing app owner UID and GID..."
            usermod  -u ${APP_OWNER_UID} www-data
            groupmod -g ${APP_OWNER_GID} www-data
            chown -R www-data: ${APP_CONTAINER_PATH}
            echo "App owner UID and GID changed to $APP_OWNER_UID and $APP_OWNER_GID."
        fi
    else
        echo "App owner UID and GUI are OK!"
    fi
}

main() {
    echo "Application path: $APP_CONTAINER_PATH"

    register_env_vars
    change_owner_id

    exec "$@"
}

# entrypoint
if ! is_sourced; then
    main "$@"
fi
