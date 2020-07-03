'''
Validator for checking format of Intervention Outcomes data before it can be
integrated with PANO.
'''

import pandas as pd
import json
import argparse
import os


def build_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('data_file_path', help='path to intervention outcomes data')
    parser.add_argument('categorical_key_values', help='path of categorical key values file')
    parser.add_argument('output_file_dir', help='location of final intervention outcomes directory')
    return parser


numeric_cols = [
    "TotalSampleSize", "InterventionDuration", "ExperimentalGroupN",
    "ExperimentalGroup2N", "ExperimentalGroup3N", "ControlGroupN", "MeanAge",
    "PercFemale", "BMIBaseline", "SessionAdherence",
    "ChangeinFMStandardized", "SessionsPerWeek", "DurationInMinutes", "WeeklyMinutes"
    ]


opts = build_parser().parse_args()
df = pd.read_csv(opts.data_file_path, na_filter=False)

with open(opts.categorical_key_values, 'r+') as json_file:
    categorical_vals = json.loads(json_file.read())


def check_numeric(col_name):
    '''
    Ensure only numbers and NaN are included in numerical columns.

    :param: col_name:name of the numerical column
    '''
    for index, row in df.iterrows():
        ele = row[col_name]
        if ele != 'NaN':
            try:
                float(ele)
            except ValueError:
                raise ValueError('Numeric columns should only contain NaN (not NA) and numbers. '
                                 'Check Study: {} Value: {} Column: {}'.format(row['StudyName'],
                                                                               ele, col_name))


def check_categorical(col_name):
    '''
    Ensure only identified column values in `categorical_key_values.json` exist in their
    respective columns.

    :param: col_name:name of the categorical column
    '''
    for index, row in df.iterrows():
        ele = row[col_name]
        if ele not in categorical_vals[col_name]:
            raise ValueError(
                    'Categorical columns should only contain NA (not NaN) and have'
                    ' their possible values included in the `categorical_key_values.json` file.'
                    ' Check Study: {} Value: {} Column: {}'.format(row['StudyName'], ele,
                                                                   col_name))


for num_col in numeric_cols:
    check_numeric(num_col)


categorical_cols = list(set(list(df.drop(['Notes', 'refID', 'StudyName'], axis=1).columns)) - set(numeric_cols))

for cat_col in categorical_cols:
    check_categorical(cat_col)


# Passed successfully

os.rename(opts.data_file_path, os.path.join(opts.output_file_dir,
                                            'InterventionOutcomesRFull.csv'))
