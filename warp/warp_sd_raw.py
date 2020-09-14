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

# utility function for easy initialization
def nested_dict(n, type):
    if n == 1:
        return defaultdict(type)
    else:
        return defaultdict(lambda: nested_dict(n-1, type))

cage_cur = cage.cursor()
teams = nested_dict(3, dict)

# w/l and rs/ra
query = """
  SELECT season, level_id, away_team, away_score, home_team, home_score
  FROM mlbapi.games_schedule_deduped
  WHERE game_type = 'R' AND left(status_code, 1) = 'F'
"""
cage_cur.execute(query)
for row in cage_cur:
    season, level_id, away_team, away_score, home_team, home_score = row

    if away_score is None or home_score is None:
        continue

    if away_team not in teams[season][level_id]:
        teams[season][level_id][away_team] = {
            'r': 0, 'ra': 0, 'w': 0, 'l': 0,
            'ha': 0, 'hra': 0, 'soa': 0, 'outs': 0, 'bip': 0
        }

    if home_team not in teams[season][level_id]:
        teams[season][level_id][home_team] = {
            'r': 0, 'ra': 0, 'w': 0, 'l': 0,
            'ha': 0, 'hra': 0, 'soa': 0, 'outs': 0, 'bip': 0
        }

    teams[season][level_id][away_team]['r'] += away_score
    teams[season][level_id][away_team]['ra'] += home_score
    teams[season][level_id][home_team]['r'] += home_score
    teams[season][level_id][home_team]['ra'] += away_score

    if away_score > home_score:
        teams[season][level_id][away_team]['w'] += 1
        teams[season][level_id][home_team]['l'] += 1
    elif home_score > away_score:     
        teams[season][level_id][away_team]['l'] += 1
        teams[season][level_id][home_team]['w'] += 1
    # ignore ties


play_values = nested_dict(3, float)
cage_cur.execute("SELECT season, level_id, league, lwts FROM legacy_models.play_value")
for row in cage_cur:
    season, level_id, league, lwts = row
    play_values[season][level_id][league] = lwts

leagues = {}
cage_cur.execute("SELECT id, league FROM mlbapi.teams")
for row in cage_cur:
    id, league = row
    leagues[id] = league

query = """
  SELECT season, level_id, team, 
    sum(hits), sum(homeruns), sum(strikeouts), sum(outs)
  FROM (
    SELECT DISTINCT gs.game_pk,
      gs.season,
      gs.level_id,
      CASE gp.away_home 
        WHEN 'away' THEN gs.away_team
        ELSE gs.home_team
      END AS team,
      gp.player_id,
      sp.hits,
      sp.homeruns,
      sp.strikeouts,
      sp.outs
    FROM mlbapi.games_players gp
    INNER JOIN mlbapi.games_schedule_deduped gs USING (game_pk)
    LEFT JOIN mlbapi.stats_pitching sp
    ON gp.game_pk = sp.game_pk AND gp.player_id = sp.pitcher_id
    WHERE gs.game_type = 'R'
      AND left(gs.status_code, 1) = 'F'
      AND gp.player_type = 'pitcher'
      AND (gs.game_date - interval '7 hours')::date < '2020-09-09'
  ) team_pitching
  GROUP BY season, level_id, team
"""
cage_cur.execute(query)
for row in cage_cur:
    season, level_id, team, hits, homeruns, strikeouts, outs = row
    teams[season][level_id][team]['ha'] = hits
    teams[season][level_id][team]['hra'] = homeruns
    teams[season][level_id][team]['soa'] = strikeouts
    teams[season][level_id][team]['outs'] = outs
    teams[season][level_id][team]['bip'] = hits + outs - homeruns - \
        strikeouts

warp_sd_raw = nested_dict(2, dict)
buffer = io.StringIO()

for season in teams:
    for level in teams[season]:
        for team in teams[season][level]:
            r = teams[season][level][team]
            r['g'] = r['w'] + r['l']
            if r['g'] == 0:
                continue
            r['w_pct'] = r['w'] / (r['w'] + r['l'])
        records = teams[season][level].values()
        output = {}
        games = sum([x['g'] for x in records])
        rpg = sum([x['r'] for x in records])/games
        babip = sum([x['ha'] - x['hra'] for x in records]) / \
            sum([x['outs'] + x['ha'] - x['hra'] - x['soa'] for x in records])
        w_sd = pow(sum([pow((x['w']/x['g'] - 0.5), 2)*x['g'] \
            for x in records])/games, 0.5)
        rspg_sd = pow(sum([pow((x['r']/x['g'] - rpg), 2)*x['g'] \
            for x in records])/games, 0.5)
        rapg_sd = pow(sum([pow((x['ra']/x['g'] - rpg), 2)*x['g'] \
            for x in records])/games, 0.5)
        fld_sd = pow(sum([pow(((x['ha'] - x['hra']) - \
            babip*(x['outs'] + x['ha'] - x['hra'] - x['soa'])) * \
            play_values[season][level_id][leagues[team]]/x['g'], 2) * \
            x['g'] for x in records])/games, 0.5) 
        rapg_fair_sd = pow(sum([pow((x['ra'] - ((x['ha'] - x['hra']) - 
            babip*x['bip']) * \
            play_values[season][level_id][leagues[team]])/x['g'] - rpg, 2) * \
            x['g'] for x in records])/games, 0.5)
        bip = sum([x['bip'] for x in records])
        babip_sd = pow(sum([pow((x['ha'] - x['hra']) / \
            x['bip'] - babip, 2) * x['bip'] for x in records]) / \
            bip, 0.5)
        rep_rspg = rpg - 2.4*rspg_sd
        rep_rapg = rpg + 2.4*rapg_fair_sd
        pythex = pow(rep_rspg + rep_rapg, 0.287)
        rep_pct = pow(rep_rspg, pythex) / \
            (pow(rep_rspg, pythex) + pow(rep_rapg, pythex))
        vs_reference = rep_pct*(1 - 0.325) / \
            (rep_pct*(1 - 0.325) + (1 - rep_pct) * 0.325)
        off_warp_pct = rspg_sd**2 / (rspg_sd**2 + rapg_fair_sd**2)
        buffer.write("|".join([str(x) for x in 
            (season, level, rep_pct, vs_reference, off_warp_pct)]))
        buffer.write("\n")
        
cage_cur.execute("TRUNCATE legacy_models.warp_sd_raw")
buffer.seek(0)
cage_cur.copy_from(buffer, "legacy_models.warp_sd_raw", sep="|")
buffer.close()
cage.commit()
