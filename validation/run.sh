python=/opt/miniconda-latest/envs/io/bin/python

$python ./validation/download.py ./validation/credentials.json $1 ./tmp/
if $python ./validation/validator.py ./tmp/intervention_data.csv ./validation/categorical_key_values.json ./app/.;
then
    Rscript ./validation/deploy.R $2 $3 $4 $5 $6
else
    echo "ERROR"
fi