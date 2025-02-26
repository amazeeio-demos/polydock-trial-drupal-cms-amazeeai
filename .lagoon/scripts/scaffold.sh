#!/bin/sh

# Loading environment variables from .env and friends
source /lagoon/entrypoints/50-dotenv.sh

# Generate some additional enviornment variables
source /lagoon/entrypoints/55-generate-env.sh

if [ -z "$RUN_CONTEXT" ] && [ ! -z "$SERVICE_NAME" ]; then
  RUN_CONTEXT="$SERVICE_NAME"
  if [ ! -z "$LAGOON_KUBERNETES" ]; then
    RUN_CONTEXT=$SERVICE_NAME.$LAGOON_KUBERNETES 
  fi
fi

FLAG_FILE="/app/scaffolding_done.flag"

cd /app

echo "----------------------------------------------"
echo "-------- Variables in $RUN_CONTEXT "
echo "----------------------------------------------"
export
echo "----------------------------------------------"

# Check if the flag file exists
if [ ! -f "$FLAG_FILE" ]; then
    echo "*** NO SCAFFOLD FILE FOUND: $RUN_CONTEXT ***"
    git config --global --add safe.directory /app
    if [ -z "$LAGOON_KUBERNETES" ]; then
        echo "Not running in Lagoon - we will try install in $RUN_CONTEXT"
        composer install --no-dev
        cp -r /app/vendor/drupal/cms/web/profiles/drupal_cms_installer /app/web/profiles/
        cp /app/drush/Commands/contrib/drupal_integrations/assets/* /app/web/sites/default
    fi    
    # Create the flag file to indicate the script has run
    echo "About to create $FLAG_FILE in $RUN_CONTEXT"
    touch "$FLAG_FILE"
else
    echo "*** SCAFFOLD FILE FOUND: $RUN_CONTEXT ***"
    echo "The initialization script has already run on $RUN_CONTEXT."
fi

# here we attempt to copy the details
if [ ! -f "/app/web/sites/default/settings.php" ]; then
    echo "Copying the details in $RUN_CONTEXT"
    cp /app/.lagoon/assets/* /app/web/sites/default
    mv /app/web/sites/default/initial.settings.php /app/web/sites/default/settings.php
    echo "Details copied in $RUN_CONTEXT"
fi
