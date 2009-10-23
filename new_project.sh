#!/bin/bash

BASE_DIR=$(echo $(dirname $(readlink -f $0)))

source $BASE_DIR/helpers.sh
source $BASE_DIR/params.sh

if [[ -z $CONFIG_FILE ]] || ! [[ -f $CONFIG_FILE ]]; then usage; fi

source $CONFIG_FILE

askDeleteAll
downloadSf
installSf

php $SYMFONY_DATA_DIR/bin/symfony -V

## init symfony
php $SYMFONY_DATA_DIR/bin/symfony generate:project $PROJECT_NAME;

## Fix permissions
chmod 777 cache/ log/

## set author name
php symfony configure:author $AUTHOR_NAME;

## generate front & backend app
php symfony generate:app --escaping-strategy=on --csrf-secret=$CSRF_SECRET $FRONTEND_APP_NAME;
php symfony generate:app --escaping-strategy=on --csrf-secret=$CSRF_SECRET $BACKEND_APP_NAME;

# Create Backend app folder for use with no_script_name
customizeBackend

setupApache
setupHostsFile
fixSymfonyLn
configureDb

# remove propel connection
removePropel

phpAccelerator

# remove build temp dirs
rm lib/vendor/symfony/lib lib/vendor/symfony/data
rm web/sfProtoculousPlugin

# Set super administrator flag: not defined.
# php symfony promote-super-admin admin

# fix permissions
#php symfony fix-perms

# Clear cache and remove unnecessary files
clearCache

# Optional Plugins
installPlugins
publishAssets

# Optional Languages
if ! [[ -z $LANGUAGES_TO_INSTALL ]]; then
    enableMySQLi18n
fi

# Clean cache
clearCache

# Script to check symfony's health
php $SYMFONY_DIR/current_data/bin/check_configuration.php

# Load own schema if available
if [ -f "$DOCTRINE_SCHEMA_FILE" ]; then
    cp $DOCTRINE_SCHEMA_FILE config/doctrine/
    php symfony doctrine-build-all-reload --no-confirmation
fi

# Load own data if available
if [ -f "$DOCTRINE_FIXTURES_FILE" ]; then
    mkdir -p data/fixtures/doctrine/
    cp $DOCTRINE_FIXTURES_FILE data/fixtures/doctrine/
    php symfony doctrine-load-data
#else
#    echo NO fixture
fi

# Set up terminal with tabs
askOpenMysqlTerminal
askOpenFirefox

