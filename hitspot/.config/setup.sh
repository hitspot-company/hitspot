#!/bin/sh

# BASIC FIREBASE OPTION SETUP SCRIPT
DEV=firebase.dev.json
DEV_OUT=hs_firebase_config.dev.dart
STAGING=firebase.staging.json
STAGING_OUT=hs_firebase_config.staging.dart
PROD=firebase.prod.json
PROD_OUT=hs_firebase_config.prod.dart
SETUP_FILE=firebase.json
GENERATED_FILE=lib/firebase_options.dart
OUTPUT_DIR=packages/hs_firebase_config/lib/src/

# Function to set up Firebase environment
setup_environment() {
    ENVIRONMENT=$1
    CONFIG_FILE=$2
    OUT_FILE=$3

    echo "$ENVIRONMENT SETUP"
    if [ ! -f $OUTPUT_DIR/$OUT_FILE ]; then
        echo "$ENVIRONMENT environment is not set up"
        echo "Moving config file to root."
        cp $CONFIG_FILE ../$SETUP_FILE
        echo "When prompted press ENTER"
        cd .. && flutterfire configure
        rm $SETUP_FILE
        mv $GENERATED_FILE $OUTPUT_DIR/$OUT_FILE
        cd .config
        echo "$ENVIRONMENT environment has been set up successfully"
    else
        echo "$ENVIRONMENT environment is already set up"
    fi
}

yes | setup_environment "DEVELOPMENT" $DEV $DEV_OUT
yes | setup_environment "STAGING" $STAGING $STAGING_OUT
yes | setup_environment "PRODUCTION" $PROD $PROD_OUT
