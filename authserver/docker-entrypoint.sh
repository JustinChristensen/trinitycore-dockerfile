#!/usr/bin/env bash
set -e

if ! [ "${MYSQL_PASS:-}" ] && [ "${MYSQL_PASS_FILE:-}" ]; then
    MYSQL_PASS=$(< "${MYSQL_PASS_FILE}")
fi

MYSQL_ADMIN_ARGS=(-h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_ADMIN_USER" -p"$MYSQL_ADMIN_PASS")
MYSQL_ARGS=(-h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASS")

cd ~

echo "Checking database connection..."
set +e
for _ in $(seq 1 $CONNECT_RETRIES); do
    mysql ${MYSQL_ADMIN_ARGS[@]} -e "SELECT version();"
    connected=$?
    [ $connected -eq 0 ] && break || sleep $RETRY_INTERVAL
done
[ $connected -ne 0 ] && exit $connected
set -e

if [ "$CREATE_DATABASES" = "1" ]; then
    echo "Creating databases..."
    sed "s|@'localhost'||g" create_mysql.sql | mysql ${MYSQL_ADMIN_ARGS[@]} && true

    echo "Creating and populating tables..."
    cat auth_database.sql | mysql ${MYSQL_ARGS[@]} auth

    echo "Running updates..."
    for F in updates/auth/3.3.5/*.sql; do
        cat "$F" | mysql ${MYSQL_ARGS[@]} auth
    done

    echo "Creating root account..."
    cat create_root.sql | mysql ${MYSQL_ARGS[@]} auth
fi

echo "Setting database configuration from env..."
MYSQL_CONN_STRING="$MYSQL_HOST;$MYSQL_PORT;$MYSQL_USER;$MYSQL_PASS"
cat <<SCRIPT | sed -i -f- "${TRINITYCORE_INSTALL_PREFIX}/etc/authserver.conf"
     s|^LoginDatabaseInfo *= *"[^"]*"|LoginDatabaseInfo = "$MYSQL_CONN_STRING;auth"|g
SCRIPT

exec "$@"
