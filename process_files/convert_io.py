import pandas as pd

num_cols = ["TotalSampleSize", "InterventionDuration", "ExperimentalGroupN",
            "ExperimentalGroup2N", "ExperimentalGroup3N", "ControlGroupN", "MeanAge",
            "PercFemale", "BMIBaseline", "SessionAdherence", "ChangeinFM",
            "ChangeinFMStandardized", "SessionsPerWeek", "DurationInMinutes", "WeeklyMinutes"]

df = pd.read_csv('InterventionOutcomesFull-RAW.csv', header=(0))

# Error handling for potential R issues
df.replace('Hötting2012', 'Hotting2012', inplace=True)
df = df.replace(float('NaN'), 'NA')

# Get reference IDs
ref = pd.read_csv('pano_intervention_references.csv')
ref = ref.loc[:, ['author', 'year', 'refID']]

for _, row in ref.iterrows():
    if type(row['author']) != float and type(row['year']) != float and type(row['refID']) != float:
        first_author = row['author'].split(',')[0]
        year = str(row['year'])
        refID = str(row['refID'])
        studyname = first_author + year

        for index, row in df.iterrows():
            if row['StudyName'] == studyname:
                df.loc[index, 'refID'] = refID

    else:
        continue

df.loc[:, num_cols] = df.loc[:, num_cols].replace('NA', 'NaN')
df.to_csv('../InterventionOutcomesRFull.csv', sep=',', index=False)

# Some rows dont show up in pandas dataframe, but need to be removed
lines = []
with open('../InterventionOutcomesRFull.csv', 'r+') as file:
    for line in file.readlines():
        if (line[0:4] == 'TNF-' or line[0:15] == 'Fasting glucose' or
                line[0:17] == 'Total cholesterol'):
            continue
        elif '% - Balke' in line:
            lines.append(line[:-1] + '",' + line[-1])
        else:
            lines.append(line)


with open('../InterventionOutcomesRFull.csv', 'w') as file:
    file.write(''.join(lines))
