import csv
import gspread
from oauth2client.service_account import ServiceAccountCredentials
import argparse


def build_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('credentials_path',
                        help='credentials.json file path for connecting to google api')
    parser.add_argument('docid', help='document id for api call')
    parser.add_argument('output_dir', help='directory to output csv files to')
    return parser


opts = build_parser().parse_args()

scope = ['https://spreadsheets.google.com/feeds']
credentials = ServiceAccountCredentials.from_json_keyfile_name(opts.credentials_path, scope)

docid = opts.docid

file_names = {0: 'intervention_data.csv', 1: 'codebook.csv', 2: 'misc.csv'}

client = gspread.authorize(credentials)
spreadsheet = client.open_by_key(docid)
for i, worksheet in enumerate(spreadsheet.worksheets()):
    filename = opts.output_dir + file_names[i]
    with open(filename, 'w') as f:
        writer = csv.writer(f)
        writer.writerows(worksheet.get_all_values())
