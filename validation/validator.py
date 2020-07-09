'''
Validator for checking format of Intervention Outcomes data before it can be
integrated with PANO.
'''

import pandas as pd
import json
import argparse
import os
import re


def build_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('data_file_path', help='path to intervention outcomes data')
    parser.add_argument('categorical_key_values', help='path of categorical key values file')
    parser.add_argument('output_file_dir', help='location of final intervention outcomes directory')
    parser.add_argument('codebook_file_path', help='path to codebook data')
    return parser


numeric_cols = [
    "TotalSampleSize", "InterventionDuration", "ExperimentalGroupN",
    "ExperimentalGroup2N", "ExperimentalGroup3N", "ControlGroupN", "MeanAge",
    "PercFemale", "BMIBaseline", "SessionAdherence",
    "ChangeinFMStandardized", "SessionsPerWeek", "DurationInMinutes", "WeeklyMinutes"
    ]


opts = build_parser().parse_args()
df = pd.read_csv(opts.data_file_path, na_filter=False)
codebook_df = pd.read_csv(opts.codebook_file_path)

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

        if col_name == 'StudyName':
            pattern = re.compile('^[A-Z][a-z]*[0-9]{4}')
            if not pattern.match(row['StudyName']):
                raise ValueError(
                        '''
                        StudyName column must be formatted with a last (capital first letter) 
                        name followed by year. Check Study: {} Value: {} Column: {}
                        '''.format(row['StudyName'], ele, col_name))

        if ele not in categorical_vals[col_name]:
            raise ValueError(
                    'Categorical columns should only contain NA (not NaN) and have'
                    ' their possible values included in the `categorical_key_values.json` file.'
                    ' Check Study: {} Value: {} Column: {}'.format(row['StudyName'], ele,
                                                                   col_name))


for num_col in numeric_cols:
    check_numeric(num_col)

excluded_cols = ['Notes', 'refID', 'StudyName']
categorical_cols = list(set(list(df.drop(excluded_cols, axis=1).columns)) - set(numeric_cols))

for cat_col in categorical_cols:
    check_categorical(cat_col)


# Data validation passed successfully

os.rename(opts.data_file_path, os.path.join(opts.output_file_dir,
                                            'InterventionOutcomesRFull.csv'))


# Process codebook for updating
def filter_codebook_cols(codebook_df):
    '''
    Find the rows in the codebook_df which contain the columns and descriptions of interest.

    :param: codebook_df:downloaded raw codebook as a pandas dataframe
    :returns: codebook_validated:list
    '''
    codebook_validated = []
    for col in codebook_df.iloc[:, 0]:
        if (col in categorical_vals.keys()) or (col in numeric_cols) or (col in excluded_cols):
            codebook_validated.append(col)

    return codebook_validated


# Only keep column names that were filtered
codebook_df = codebook_df[codebook_df.iloc[:, 0].isin(
    filter_codebook_cols(codebook_df))].iloc[:, 0:2]
# add top row
codebook_df.loc[-1] = ['Field Name', 'Description']
codebook_df.index = codebook_df.index + 1
codebook_df = codebook_df.sort_index()
codebook_df.to_csv(os.path.join(opts.output_file_dir, 'pano_codebook.csv'), index=False, header=False)
