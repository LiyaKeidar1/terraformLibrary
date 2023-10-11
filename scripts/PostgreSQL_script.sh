#!/bin/bash

# Install PostgreSQL
sudo apt-get update
sudo apt-get install -y postgresql postgresql-contrib

# Start the PostgreSQL service
sudo systemctl start postgresql.service

# Log in to the PostgreSQL server as the default superuser and create the database
sudo -u postgres psql -c "CREATE DATABASE library;"

# Connect to the 'library' database and create the 'books' table
sudo -u postgres psql -d library -c "CREATE TABLE books (
    id serial PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255)
);"

# Create a user for your Flask application
sudo -u postgres psql -c "CREATE USER liya WITH PASSWORD $1;"

# Grant privileges to the user on the 'library' database
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE library TO liya;"

# Grant privileges on the 'books' table to the user
sudo -u postgres psql -d library -c "GRANT ALL PRIVILEGES ON TABLE books TO liya;"

echo "listen_addresses = '*'" | sudo tee -a /etc/postgresql/*/main/postgresql.conf

echo "host all all 10.0.1.0/24 md5" | sudo tee -a /etc/postgresql/*/main/pg_hba.conf

sudo systemctl restart postgresql.service 


