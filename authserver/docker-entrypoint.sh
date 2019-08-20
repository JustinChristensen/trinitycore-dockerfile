#!/usr/bin/env bash
set -ex

echo "Creating databases..."
cat create_mysql.sql | mysql && true

echo "Creating and populating tables..."
cat auth_database.sql | mysql auth

echo "Running updates..."
for DB in auth; do
    for F in updates/$DB/3.3.5/*.sql; do
        cat "$F" | mysql "$DB"
    done
done

rm -r updates *.sql

exec "$@"
