#!/bin/bash

DB_NAME="DataWarehouse"

# Drop database if it exists
dropdb --if-exists "$DB_NAME"

# Create database
createdb "$DB_NAME"

# Create schemas
psql -d "$DB_NAME" <<EOF
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
EOF