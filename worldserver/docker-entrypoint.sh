#!/usr/bin/env bash
set -ex

echo "Creating databases..."
cat create_mysql.sql | mysql && true

echo "Downloading world database..."
curl -Ls -o world_database.7z "$WORLD_DB_RELEASE"
p7zip -f -d -c world_database.7z > world_database.sql
rm world_database.7z

echo "Creating and populating tables..."
cat auth_database.sql | mysql auth && true
cat characters_database.sql | mysql characters
cat world_database.sql | mysql world

echo "Running updates..."
for F in updates/auth/3.3.5/*.sql; do
    cat "$F" | mysql "$DB" && true
done
for DB in characters world; do
    for F in updates/$DB/3.3.5/*.sql; do
        cat "$F" | mysql "$DB"
    done
done

rm -r updates *.sql

exec "$@"
