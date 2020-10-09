#!/usr/bin/python3

from collections import defaultdict
import io
from itertools import accumulate
from statistics import mean
import json
import psycopg2
import sys

with open("creds.json", "r") as fd:
    creds = json.load(fd)

try:
    cage = psycopg2.connect(dbname = "cage",
        user =     creds['pg']['username'],
        password = creds['pg']['password'],
        host =     creds['pg']['host'])
except psycopg2.Error as err:
    print(e.pgerror)
    sys.exit(1)

try:
    dugout = psycopg2.connect(dbname = "dugout",
        user =     creds['pg']['username'],
        password = creds['pg']['password'],
        host =     creds['pg']['host'])
except psycopg2.Error as err:
    print(e.pgerror)
    sys.exit(1)

# utility function for easy initialization
def nested_dict(n, type):
    if n == 1:
        return defaultdict(type)
    else:
        return defaultdict(lambda: nested_dict(n-1, type))

cage_cur = cage.cursor()
dugout_cur = dugout.cursor()

drc_pos = nested_dict(2, dict)
r_pa = nested_dict(1, dict)
rpw = nested_dict(1, dict)
pos_adj_lookup = nested_dict(2, dict)
rep_level_lookup = nested_dict(2, dict)
draa = nested_dict(3, float)
fraa = nested_dict(3, float)
cda = nested_dict(3, float)
ofa = nested_dict(3, float)
pos_adj = nested_dict(3, float)
rep_level = nested_dict(3, float)
drc_warp = nested_dict(3, float)

query = """
SELECT DISTINCT ON (year, lvl, pos) year, lvl, pos, drc_plus
FROM models.drc_daily_pos
ORDER BY year, lvl, pos, comp_date DESC;
"""
cage_cur.execute(query)
for row in cage_cur:
    season, lvl, pos, value = row

    # hack
    season = int(season)
    if lvl == 'mlb':
        level_id = 1

    drc_pos[season][level_id][pos] = value

query = """
SELECT season, level_id, avg(rpw) AS rpw
FROM legacy_models.lwts_runs_per_win_bylg
GROUP BY season, level_id
"""
cage_cur.execute(query)
for row in cage_cur:
    season, level_id, value = row
    rpw[season][level_id] = float(value)

cage_cur.execute("""
SELECT max(official_date)::date FROM mlbapi.games_schedule_deduped
WHERE game_type='R' AND level_id = 1 AND left(status_code, 1) = 'F'
AND season=2020
""")
for row in cage_cur:
    max_date = row[0]

query = """
SELECT DISTINCT ON (year, lvl, bpid) year, lvl, bpid, "dRAA"
FROM models.drc_daily
ORDER BY year, lvl, bpid, comp_date DESC;
"""
cage_cur.execute(query)
for row in cage_cur:
    season, lvl, bpid, value = row;
    # hack
    season = int(season)

    if lvl == 'mlb':
        level_id = 1
    draa[season][level_id][bpid] = value
    drc_warp[season][level_id][bpid] = value

query = """
SELECT gs.season, gs.level_id,
    SUM(CASE WHEN r.end_base = 'score' THEN 1 ELSE 0 END) /
    SUM(CASE WHEN r.start_base IS NULL THEN 1 ELSE 0 END)::double precision
    AS r_pa
FROM mlbapi.plays p
LEFT JOIN mlbapi.runners r USING (game_pk, at_bat_index)
LEFT JOIN mlbapi.event_types et ON p.event_type = et.code
LEFT JOIN mlbapi.games_schedule_deduped gs USING (game_pk)
WHERE et.plate_appearance = 't'
GROUP BY gs.season, gs.level_id
"""
cage_cur.execute(query)
for row in cage_cur:
    season, level_id, value = row
    r_pa[season][level_id] = value

for season in drc_pos:
    for level_id in drc_pos[season]:
        for pos in drc_pos[season][level_id]:
            pos_factor = drc_pos[season][level_id][pos] / 100.0
            r = r_pa[season][level_id]
            pos_adj_lookup[season][level_id][pos] = r - (r*pos_factor)
            rep_level_lookup[season][level_id][pos] = r - (r*0.76)

query = """
SELECT gs.season, gs.level_id, x.bpid, pos, count(*)
FROM mlbapi.batters_pos bp
LEFT JOIN mlbapi.games_schedule_deduped gs USING (game_pk)
LEFT JOIN xrefs.people_refs x ON bp.batter_id = x.xref_id::INT
WHERE gs.game_type='R' AND left(gs.status_code, 1) = 'F'
GROUP BY gs.season, gs.level_id, x.bpid, pos
"""
cage_cur.execute(query)
for row in cage_cur:
    season, level_id, bpid, pos, value = row
    if season not in drc_warp:
        continue

    try:
        raw_pos = value * pos_adj_lookup[season][level_id][pos]
        raw_rep = value * rep_level_lookup[season][level_id][pos]
        if bpid in pos_adj[season][level_id]:
            pos_adj[season][level_id][bpid] += raw_pos
            rep_level[season][level_id][bpid] += raw_rep
        else:
            pos_adj[season][level_id][bpid] = raw_pos
            rep_level[season][level_id][bpid] = raw_rep
    except KeyError:
        print(f"No pos_adj/rep_level lookup for {bpid} ({pos}) in " + \
            f"{season}-{level_id}...")
        if bpid not in pos_adj[season][level_id]:
            pos_adj[season][level_id][bpid] = None
            rep_level[season][level_id][bpid] = None

for season in pos_adj:
    if season not in drc_warp:
        continue
    for level_id in pos_adj[season]:
        for bpid in pos_adj[season][level_id]:
            if pos_adj[season][level_id][bpid] is not None:
                if bpid not in drc_warp[season][level_id]:
                    drc_warp[season][level_id][bpid] = \
                        pos_adj[season][level_id][bpid] + \
                        rep_level[season][level_id][bpid]
                else:
                    drc_warp[season][level_id][bpid] += \
                        pos_adj[season][level_id][bpid] + \
                        rep_level[season][level_id][bpid]

query = """
SELECT season, level_id, bpid, SUM(raa_reg) AS fraa FROM
  (SELECT DISTINCT ON (season, level_id, bpid, pos) 
     season, level_id, bpid, pos, raa_reg
   FROM models.fraa_daily
   ORDER BY season, level_id, bpid, pos, version DESC) fraa_pos
GROUP BY (season, level_id, bpid)
"""
cage_cur.execute(query)
for row in cage_cur:
    season, level_id, bpid, value = row
    if season not in drc_warp or value is None:
        continue
    fraa[season][level_id][bpid] = value
    if bpid not in drc_warp[season][level_id]:
        continue
    if drc_warp[season][level_id][bpid] is not None:
        drc_warp[season][level_id][bpid] += value

query = """
SELECT season, level_id, bpid, SUM(of_ast_fraa) AS of_ast_fraa FROM
  (SELECT DISTINCT ON (season, level_id, team_id, bpid) 
     season, level_id, team_id, bpid, of_ast_fraa
   FROM models.ofa_daily
   ORDER BY season, level_id, team_id, bpid, version DESC) ofa_team
GROUP BY (season, level_id, bpid)
"""
cage_cur.execute(query)
for row in cage_cur:
    season, level_id, bpid, value = row
    if season not in drc_warp or value is None:
        continue
    ofa[season][level_id][bpid] = value
    if bpid not in drc_warp[season][level_id]:
        print(f"Found OF_AST_FRAA but not DRAA/POS/REP for {bpid} in " + \
            f"{season}-{level_id}")
        continue
    if drc_warp[season][level_id][bpid] is not None:
        drc_warp[season][level_id][bpid] += value

query = """
SELECT year, lvl, catcher, sum(fraa_adj) AS cda 
FROM (
  SELECT DISTINCT ON (year, lvl, catcher, team) 
  year, lvl, catcher, team, fraa_adj
  FROM stats.catch_master
  ORDER BY year, lvl, catcher, team, version_date DESC
) cda_team
GROUP BY year, lvl, catcher
"""
dugout_cur.execute(query)
for row in dugout_cur:
    season, lvl, bpid, value = row
    if season not in drc_warp or value is None:
        continue
    if lvl == 'mlb':
        level_id = 1
    cda[season][level_id][bpid] = value
    if bpid not in drc_warp[season][level_id]:
        print(f"Found CDA but not DRAA/POS/REP for {bpid} in " + \
            f"{season}-{level_id}")
        continue
    if drc_warp[season][level_id][bpid] is not None:
        drc_warp[season][level_id][bpid] += value

def replace_none(value):
    if value is None:
        return '\\N'
    else:
        return str(value)

buffer = io.StringIO()
for season in drc_warp:
    for level_id in drc_warp[season]:
        for bpid in drc_warp[season][level_id]:
            drc_warp[season][level_id][bpid] /= rpw[season][level_id]
            buffer.write("|".join(
                [str(season), str(level_id), str(bpid)] + 
                [replace_none(x[season][level_id][bpid]) for x in 
                    (drc_warp, draa, fraa, ofa, cda, pos_adj, rep_level)] + \
                ["0", # brr
                 "0", # brr_arm
                 str(rpw[season][level_id]), str(max_date)]))
            buffer.write("\n")
        
cage_cur.execute("DELETE FROM models.drc_warp WHERE version = '" + \
    str(max_date) + "'")
buffer.seek(0)
cage_cur.copy_from(buffer, "models.drc_warp", sep="|")
buffer.close()
cage.commit()
