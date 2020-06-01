python ./download.py ./credentials.json $1 ../tmp/
python ./validator.py ../tmp/intervention_data.csv ./categorical_key_values.json ../app/.
Rscript ./deploy.R $2 $3 $4 $5 $6
