#!/usr/bin/env bash
set -e

if ! [ "${MYSQL_PASS:-}" ] && [ "${MYSQL_PASS_FILE:-}" ]; then
    MYSQL_PASS=$(< "${MYSQL_PASS_FILE}")
fi

MYSQL_ADMIN_ARGS=(-h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_ADMIN_USER" -p"$MYSQL_ADMIN_PASS")
MYSQL_ARGS=(-h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASS")

has_tables () {
    if [ "$1" ]; then
        local query="SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$1';"
        local count=$(mysql ${MYSQL_ADMIN_ARGS[@]} -N -e "$query")
        test "${count:-0}" -ne "0"
    else
        return 1
    fi
}

# run inside a mounted volume, writing extracted
# files to the host if they're not already present
if [ "$EXTRACT_DATA" = "1" ]; then
    cd "$TRINITYCORE_DATA_DIR"

    echo "Extracting client data..."

    if ! [ -d dbc ]; then
        mapextractor
    else
        echo "dbc and maps already extracted, skipping"
    fi

    if ! [ -d vmaps ]; then
        vmap4extractor
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
    cp -n create_mysql.sql "$TRINITYCORE_DATA_DIR"
    cp -n characters_database.sql "$TRINITYCORE_DATA_DIR"
    cp -rn updates "$TRINITYCORE_DATA_DIR"

    cd "$TRINITYCORE_DATA_DIR"
    if [ ! -f world_database.sql ]; then
        echo "Downloading world database..."
        echo "Given url: $WORLD_DB_RELEASE"
        curl -Ls -o world_database.7z "$WORLD_DB_RELEASE"
        p7zip -f -d -c world_database.7z > world_database.sql
        rm world_database.7z
    fi

    echo "Creating databases..."
    sed "s|@'localhost'||g" create_mysql.sql | mysql ${MYSQL_ADMIN_ARGS[@]} && true

    for DB in characters world; do
        if ! has_tables $DB; then
            echo "Creating and populating tables for $DB..."
            cat "${DB}_database.sql" | mysql ${MYSQL_ARGS[@]} "$DB"

            echo "Running updates for $DB..."
            for F in updates/$DB/3.3.5/*.sql; do
                cat "$F" | mysql ${MYSQL_ARGS[@]} "$DB"
            done
        fi
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

cd ~

exec "$@"

