#!/usr/bin/python3

import json
import psycopg2
from psycopg2.extras import DictCursor
from sqlalchemy import create_engine
import pandas as pd
import player_pitch_team_season_queries as q

with open("creds.json", "r") as fd:
    creds = json.load(fd)

try:
    cage = psycopg2.connect(dbname = creds['cage']['database'],
        user =     creds['cage']['username'],
        password = creds['cage']['password'],
        host =     creds['cage']['host'])
except psycopg2.Error as err:
    print(e.pgerror)
    sys.exit(1)

engine = create_engine(creds['dugout']['string'])  #postgresql://user:pass@host:port/dbname

cage_cur = cage.cursor(cursor_factory=DictCursor)

def get_data(query, season, level_id, cur = cage_cur):
    cur.execute(query.format(season = season, level_id = level_id))

    data = []
    for row in cur:
        data.append(dict(row))  # https://stackoverflow.com/a/21158697  

    return data  

# parameterize
season = 2020
level_id = 1

# get data from each query
bio = get_data(q.query_bio, season, level_id)
stats = [get_data(qu, season, level_id) for qu in q.queries]

# join it together
final = pd.DataFrame(bio)

for d, data in enumerate(stats):
    df = pd.DataFrame(data)

    if d == 0:  # inner join to drop non-season participants in full people_search
        how = "inner"
        join_key = q.join_key[:-1]  # first join doesn't need team_id, should remove this in a more explicit way
    else:
        how = "left"
        join_key = q.join_key

    final = pd.merge(final, df, how = how, left_on = join_key, right_on = join_key)  # https://stackoverflow.com/a/52478901

# try:
#     final.to_csv("pitch_team.csv", index = False)
# except PermissionError:
#     pass

final.to_sql(name = q.table_name, con = engine, if_exists= 'replace', index = False, schema = 'stats')
