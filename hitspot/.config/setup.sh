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

if [ -f ../$SETUP_FILE ]; then
	echo "Removing preexisting Setup File"
	rm ../$SETUP_FILE
fi

echo "DEVELOPMENT SETUP"
if [ ! -f $OUTPUT_DIR/$DEV_OUT ]; then
	echo "Development environment is not set up"
	echo "Moving config file to root."
	cp $DEV ../$SETUP_FILE
	echo "When prompted press ENTER"
	cd .. && flutterfire configure
	rm $SETUP_FILE
	mv $GENERATED_FILE $OUTPUT_DIR/$DEV_OUT
	cd .config
	echo "Development environment has been set up successfully"
else
	echo "Development environment is already set up"
fi

echo "STAGING SETUP"
if [ ! -f $OUTPUT_DIR/$STAGING_OUT ]; then
	echo "Staging environment is not set up"
	echo "Moving config file to root."
	cp $STAGING ../$SETUP_FILE
	echo "When prompted press ENTER"
	cd .. && flutterfire configure
	rm $SETUP_FILE
	mv $GENERATED_FILE $OUTPUT_DIR/$STAGING_OUT
	cd .config
	echo "Staging environment has been set up successfully"
else
	echo "Staging environment is already set up"
fi

echo "PRODUCTION SETUP"
if [ ! -f $OUTPUT_DIR/$PROD_OUT ]; then
	echo "Production environment is not set up"
	echo "Moving config file to root."
	cp $PROD ../$SETUP_FILE
	echo "When prompted press ENTER"
	cd .. && flutterfire configure
	rm $SETUP_FILE
	mv $GENERATED_FILE $OUTPUT_DIR/$PROD_OUT
	cd .config
	echo "Production environment has been set up successfully"
else
	echo "Production environment is already set up"
fi

echo "The environments have been successfully set up."