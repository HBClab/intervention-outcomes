import csv
import gspread
from oauth2client.service_account import ServiceAccountCredentials

scope = ['https://spreadsheets.google.com/feeds']
credentials = ServiceAccountCredentials.from_json_keyfile_name('credentials.json', scope)

docid = "1nWcS0UrfvnPupAwb4uvaMeY7CqmFqIu09F3I9k4ND3s"

client = gspread.authorize(credentials)
spreadsheet = client.open_by_key(docid)
for i, worksheet in enumerate(spreadsheet.worksheets()):
    filename = docid + '-worksheet' + str(i) + '.csv'
    with open(filename, 'w') as f:
        writer = csv.writer(f)
        writer.writerows(worksheet.get_all_values())
