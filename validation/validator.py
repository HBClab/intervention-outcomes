'''
Validator for checking format of Intervention Outcomes data before it can be
integrated with PANO.
'''

import pandas as pd
import json

numeric_cols = [
    "TotalSampleSize", "InterventionDuration", "ExperimentalGroupN",
    "ExperimentalGroup2N", "ExperimentalGroup3N", "ControlGroupN", "MeanAge",
    "PercFemale", "BMIBaseline", "SessionAdherence",
    "ChangeinFMStandardized", "SessionsPerWeek", "DurationInMinutes", "WeeklyMinutes"
    ]

df = pd.read_csv('InterventionOutcomesRFull.csv', na_filter=False)

with open('categorical_key_values.json', 'r+') as json_file:
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


categorical_cols = list(set(list(df.drop(['Notes', 'refID'], axis=1).columns)) - set(numeric_cols))

for cat_col in categorical_cols:
    check_categorical(cat_col)


print('Passed successfully')
