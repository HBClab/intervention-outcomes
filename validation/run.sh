#!/usr/bin/env bash
set -eo pipefail
python=/opt/miniconda-latest/envs/io/bin/python

DOCID=$1
NAME_ACC=$2
TOKEN_ACC=$3
SECRET_ACC=$4
APPID_DEPLOY=$5
APPNAME_DEPLOY=$6

$python ./validation/download.py ./validation/credentials.json $DOCID ./tmp/
if $python ./validation/validator.py ./tmp/intervention_data.csv ./validation/categorical_key_values.json ./app/. ./tmp/codebook.csv;
then
    echo "VALIDATION SUCCESSFUL"
    Rscript ./validation/deploy.R $NAME_ACC $TOKEN_ACC $SECRET_ACC $APPID_DEPLOY $APPNAME_DEPLOY
else
    echo "ERROR"
fi