#!/bin/sh
set -e

echo "Docker-run.sh: Starting up..."

# Check for required commands
if ! command -v opentaxii-create-services &> /dev/null; then
    echo "opentaxii-create-services not found!"
    exit 1
fi

# Wait for the database to be available...
DB_HOST="mysql-db"
DB_PORT="3306"
# Wait for the database connection...
echo "Waiting for database ($DB_HOST:$DB_PORT) to be ready..."
attempts=0
while ! nc -z $DB_HOST $DB_PORT; do
    attempts=$((attempts + 1))
    if [ $attempts -gt 24 ]; then
        echo "Error: Database ($DB_HOST:$DB_PORT) did not become available after 2 minutes."
        exit 1
    fi
    echo "Database not ready yet (attempt $attempts)... sleeping for 5 seconds."
    sleep 5
done
echo "Database is ready!"

# Create services and accounts
echo "Creating services and accounts..."
opentaxii-create-services /app/config/data-configuration.yaml 
opentaxii-create-accounts /app/config/data-configuration.yaml

echo "Starting OpenTAXII server (development mode)..."
exec opentaxii-run-dev # Change this line if you want to run it differently