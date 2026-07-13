/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse'.
    If it already exists, it is dropped and recreated.
    Then it creates three schemas:
        - bronze
        - silver
        - gold

WARNING:
    Running this script will permanently delete the
    DataWarehouse database and all its data.
=============================================================
*/

-- Connect to the default database first
-- psql command:
-- \c postgres

-- Drop the database if it exists
DROP DATABASE IF EXISTS "DataWarehouse";

-- Create the database
CREATE DATABASE "DataWarehouse";

-- Connect to the new database
-- psql command:
-- \c DataWarehouse

-- Create schemas
CREATE SCHEMA IF NOT EXISTS bronze;

CREATE SCHEMA IF NOT EXISTS silver;

CREATE SCHEMA IF NOT EXISTS gold;