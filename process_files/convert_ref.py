import re
import pandas as pd

file = open("pano_intervention-references.txt")
f = file.read()
articles = f.split("@")


def search(regex, article):
    return re.search(regex, article)


def getTag(tag):
    search_base = '.*{.*}'
    regex = re.compile(tag + search_base)
    return [search(regex, article).group(0)[len(tag)+4:-1] if search(regex, article) is not None
            else '' for article in articles[1:]]


title = getTag('title')
author = getTag('author')
journal = getTag('journal')
year = getTag('year')
doi = getTag('DOI')


df = pd.DataFrame()
df['title'] = title
df['author'] = author
df['journal'] = journal
df['year'] = year
df['refID'] = doi


df.to_csv('../pano_intervention_references.csv', sep=',', index=False)
