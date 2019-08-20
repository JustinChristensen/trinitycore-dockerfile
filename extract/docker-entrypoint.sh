#!/usr/bin/env bash

set -ex

service mysql start

echo "Creating databases..."
cat create_mysql.sql | mysql

echo "Downloading world database..."
curl -Ls -o world_database.7z "$WORLD_DB_RELEASE"
p7zip -f -d -c world_database.7z > world_database.sql
rm world_database.7z

echo "Creating and populating tables..."
cat auth_database.sql | mysql auth
cat characters_database.sql | mysql characters
cat world_database.sql | mysql world

echo "Running updates..."
for DB in auth characters world; do
    for F in updates/$DB/3.3.5/*.sql; do
        cat "$F" | mysql "$DB"
    done
done

rm -r updates *.sql

./authserver
./worldserver
