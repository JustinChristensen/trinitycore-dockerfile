#!/usr/bin/env bash
set -e

MYSQL_DB=auth

if ! [ "${MYSQL_PASS:-}" ] && [ "${MYSQL_PASS_FILE:-}" ]; then
    MYSQL_PASS=$(< "${MYSQL_PASS_FILE}")
fi

MYSQL_ARGS=(-h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASS")

echo "Checking database connection..."
mysql ${MYSQL_ARGS[@]} -e "SELECT version();"

echo "Creating databases..."
cat create_mysql.sql | mysql ${MYSQL_ARGS[@]} && true

echo "Creating and populating tables..."
cat auth_database.sql | mysql ${MYSQL_ARGS[@]} "$MYSQL_DB"

echo "Running updates..."
for F in updates/$DB/3.3.5/*.sql; do
    cat "$F" | mysql ${MYSQL_ARGS[@]} "$MYSQL_DB"
done

rm -r updates *.sql

echo "Setting database configuration from env..."
MYSQL_CONN_STRING="$MYSQL_HOST;$MYSQL_PORT;$MYSQL_USER;$MYSQL_PASS;$MYSQL_DB"
sed -i \
    's|^LoginDatabaseInfo *= *"[^"]*"|LoginDatabaseInfo = "'$MYSQL_CONN_STRING'"|g' \
    "${TRINITY_INSTALL_PREFIX}/etc/authserver.conf"

exec "$@"
