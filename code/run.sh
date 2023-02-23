#!/usr/bin/env bash
BASEDIR=$(dirname "$0")
SUBDS=$1
SUPER=$2
CATALOGDIR=$3

# Get subdataset without data
datalad get $SUBDS --no-data

# Ensure access to scripts
chmod -R u+rwx $BASEDIR/*

# Extract+translate+add metadata for new subdataset
$BASEDIR/local/local_extract_datasetlevel.sh $SUBDS extracted_sub_metadata.json
$BASEDIR/local/local_translate_metadata.sh extracted_sub_metadata.json translated_sub_metadata.json
datalad catalog add -c CATALOGDIR -m translated_sub_metadata.json

# Extract+translate+add metadata for updated version of superdataset
$BASEDIR/local/local_extract_datasetlevel.sh . extracted_super_metadata.json
$BASEDIR/local/local_translate_metadata.sh extracted_super_metadata.json translated_super_metadata.json
datalad catalog add -c CATALOGDIR -m translated_super_metadata.json

# Set new super id and version of catalog
WD=$(pwd)
cd SUPER 
SUPER_ID=$(git config -f .datalad/config datalad.dataset.id)
SUPER_VERSION=$(git rev-parse HEAD)
cd WD
datalad catalog set-super -c CATALOGDIR -i "$SUPER_ID" -v "$SUPER_VERSION"