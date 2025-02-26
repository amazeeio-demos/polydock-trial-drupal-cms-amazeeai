#!/bin/sh

# Loading environment variables from .env and friends
source /lagoon/entrypoints/50-dotenv.sh

# Generate some additional enviornment variables
source /lagoon/entrypoints/55-generate-env.sh

FLAG_FILE="/app/scaffolding_done.flag"

cd /app

echo "----------------------------------------------"
echo "-------- Variables in $SERVICE "
echo "----------------------------------------------"
export
echo "----------------------------------------------"

# Check if the flag file exists
if [ ! -f "$FLAG_FILE" ]; then
    echo "*** NO SCAFFOLD FILE FOUND: $SERVICE***"
    git config --global --add safe.directory /app
    if [ -z "$LAGOON_KUBERNETES" ]; then
        echo "Not running in Lagoon - we will try install in $SERVICE"
        composer install --no-dev
        cp -r /app/vendor/drupal/cms/web/profiles/drupal_cms_installer /app/web/profiles/
        cp /app/drush/Commands/contrib/drupal_integrations/assets/* /app/web/sites/default
    fi    
    # Create the flag file to indicate the script has run
    echo "About to create $FLAG_FILE in $SERVICE"
    touch "$FLAG_FILE"
else
    echo "*** SCAFFOLD FILE FOUND: $SERVICE ***"
    echo "The initialization script has already run on $SERVICE."
fi

# here we attempt to copy the details
if [ ! -f "/app/web/sites/default/settings.php" ]; then
    echo "Copying the details in $SERVICE"
    cp /app/.lagoon/assets/* /app/web/sites/default
    mv /app/web/sites/default/initial.settings.php /app/web/sites/default/settings.php
    echo "Details copied in $SERVICE"
fi
