#!/bin/bash

# Update the package list and install Python pip

sudo apt-get update
sudo apt-get install -y python3
sudo apt-get install -y python3-pip

# Install Flask using pip without prompts

sudo pip3 install -q Flask
pip3 install Flask-SQLAlchemy

# Install dependencies for PostgreSQL

sudo apt-get install -y postgresql
sudo apt-get install -y python3-psycopg2

#install git
sudo apt install git -y 

# Clone my repository
git clone https://gitlab.com/keidarliya/terraformLibrary.git

# Create your Flask app (app.py)
python3 /var/lib/waagent/custom-script/download/0/terraformLibrary/app.py &





