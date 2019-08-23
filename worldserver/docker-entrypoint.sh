#!/usr/bin/env bash
set -e

if ! [ "${MYSQL_PASS:-}" ] && [ "${MYSQL_PASS_FILE:-}" ]; then
    MYSQL_PASS=$(< "${MYSQL_PASS_FILE}")
fi

MYSQL_ADMIN_ARGS=(-h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_ADMIN_USER" -p"$MYSQL_ADMIN_PASS")
MYSQL_ARGS=(-h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASS")

# run inside a mounted volume, writing extracted
# files to the host if they're not already present
if [ "$EXTRACT_DATA" = "1" ]; then
    echo "Extracting client data..."
    cd "$TRINITYCORE_DATA_DIR"

    if ! [ -d dbc ]; then
        mapextractor -i "${CLIENT_DIR}"
    else
        echo "dbc and maps already extracted, skipping"
    fi

    if ! [ -d vmaps ]; then
        vmap4extractor -d "${CLIENT_DIR}/Data"
        vmap4assembler
    else
        echo "vmaps already extracted, skipping"
    fi

    if ! [ -d mmaps ]; then
        mmaps_generator
    else
        echo "mmaps already extracted, skipping"
    fi
fi

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

    echo "Downloading world database..."
    echo "Given url: $WORLD_DB_RELEASE"
    curl -Ls -o world_database.7z "$WORLD_DB_RELEASE"
    p7zip -f -d -c world_database.7z > world_database.sql
    rm world_database.7z

    echo "Creating and populating tables..."
    cat auth_database.sql | mysql ${MYSQL_ARGS[@]} auth
    cat characters_database.sql | mysql ${MYSQL_ARGS[@]} characters
    cat world_database.sql | mysql ${MYSQL_ARGS[@]} world

    echo "Running updates..."
    for F in updates/auth/3.3.5/*.sql; do
        cat "$F" | mysql ${MYSQL_ARGS[@]} auth && true
    done
    for DB in characters world; do
        for F in updates/$DB/3.3.5/*.sql; do
            cat "$F" | mysql ${MYSQL_ARGS[@]} "$DB"
        done
    done
fi

echo "Setting database configuration from env..."
MYSQL_CONN_STRING="$MYSQL_HOST;$MYSQL_PORT;$MYSQL_USER;$MYSQL_PASS"
cat <<SCRIPT | sed -i -f- "${TRINITYCORE_INSTALL_PREFIX}/etc/worldserver.conf"
     s|^DataDir *= *"\."|DataDir = "${TRINITYCORE_DATA_DIR}"|g
     s|^LoginDatabaseInfo *= *"[^"]*"|LoginDatabaseInfo = "$MYSQL_CONN_STRING;auth"|g
     s|^WorldDatabaseInfo *= *"[^"]*"|WorldDatabaseInfo = "$MYSQL_CONN_STRING;world"|g
     s|^CharacterDatabaseInfo *= *"[^"]*"|CharacterDatabaseInfo = "$MYSQL_CONN_STRING;characters"|g
SCRIPT

exec "$@"

