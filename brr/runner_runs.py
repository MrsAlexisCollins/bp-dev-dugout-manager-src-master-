#!/usr/bin/python3

from collections import defaultdict
import io
from itertools import accumulate
from statistics import mean
import json
import pandas as pd
import psycopg2
import sys

from nested_dict import nested_dict
from runner_tracker import RunnerTracker

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

cage_cur = cage.cursor()
runner_counts = RunnerTracker()

def fetch_game_data(game_pk):
    plays = {}
    events = nested_dict(1, dict)
    runners = nested_dict(2, list)

    query = """
SELECT p.at_bat_index, p.inning, p.half_inning, p.outs, p.event_type, et.plate_appearance from mlbapi.plays p
LEFT JOIN mlbapi.event_types et ON p.event_type = et.code
WHERE game_pk = %s
ORDER BY p.at_bat_index
"""
    cage_cur.execute(query, (game_pk,))
    for row in cage_cur:
        plays[row[0]] = {
            'inning': row[1],
            'half_inning': row[2],
            'outs': row[3],
            'event_type': row[4],
            'pa': row[5]
        } 

    query = """
SELECT at_bat_index, event_index, event_type, player_id, base
FROM mlbapi.play_events
WHERE game_pk = %s AND 
  event_type in ('offensive_substitution', 'runner_placed') AND
  base IS NOT NULL
ORDER BY at_bat_index, event_index
"""
    cage_cur.execute(query, (game_pk,))
    for row in cage_cur:
        events[row[0]][row[1]] = {
            'event_type': row[2],
            'player_id': row[3],
            'base': row[4]
        }

    query = """
SELECT at_bat_index, event_index, runner_index, runner_id, 
  CASE WHEN start_base IS NULL THEN 0 ELSE left(start_base, 1)::int
  END AS start_base, end_base, is_out
FROM mlbapi.runners
WHERE game_pk = %s
ORDER BY at_bat_index, event_index, start_base asc
"""
    cage_cur.execute(query, (game_pk,))
    for row in cage_cur:
        runners[row[0]][row[1]].append({
            'runner_index': row[2],
            'runner_id': row[3],
            'start_base': row[4],
            'end_base': row[5],
            'is_out': row[6]
        })

    return (plays, events, runners)

def process_runner(rt, season, level_id, runner_history, score=False):
    for (base, outs) in runner_history:
        if outs == 3:
            continue
        rt.increment_total(season, level_id, outs, base)
        if score:
            rt.increment_runs(season, level_id, outs, base)

def process_game(season, level_id, game_pk):
    game_results = RunnerTracker()

    # keys should be start base (1, 2, 3)
    # values are dicts:
    #   id: runner currently on base, so changes for pinch runners
    #   baseout_history: list of (outs, base) pairs the runner has been
    #     on for batting events 
    cur_runners = {} 
    cur_inning = 1
    cur_half_inning = 'top'
    cur_outs = 0

    plays, events, runners = fetch_game_data(game_pk)

    for ab in plays:
        if cur_inning != plays[ab]['inning'] or \
            cur_half_inning != plays[ab]['half_inning']:
            # initialize at start of half inning
            cur_inning = plays[ab]['inning'] 
            cur_half_inning = plays[ab]['half_inning']
            cur_runners = {}
            cur_outs = 0
               
        new_runners = {i: cur_runners[i] for i in range(1, 4) \
            if i in cur_runners}
        for event in sorted(set(events[ab].keys()).union(
            set(runners[ab].keys()))):
            if event in events[ab]:
                if events[ab][event]['event_type'] == 'runner_placed':
                    base = events[ab][event]['base']
                    new_runners[base] = {
                        'id': events[ab][event]['player_id'],
                        'baseout_history': [(base, cur_outs)]
                    }
                elif events[ab][event]['event_type'] == \
                    'offensive_substitution':
                    base = events[ab][event]['base']
                    assert base in new_runners, \
                        f"Pinch runner at unoccupied base {base}, " + \
                        f"{game_pk} {ab} {event}"
                    new_runners[base]['id'] = events[ab][event]['player_id']
            if event in runners[ab]:
                # take lead runner first, 
                # within runners, sort by ascending start base
                event_runners = nested_dict(1, list)
                for r in runners[ab][event]:
                    for base in range(3, 0, -1):
                        if base in new_runners and \
                            r['runner_id'] == new_runners[base]['id']:
                            event_runners[base].append(r)
                            break
                        elif base == 1:
                            event_runners[0].append(r)
                er = []
                for base in range(3, -1, -1):
                    er.extend(event_runners[base])
                for r in er:
                    if r['start_base'] == 0:
                        new_runners[0] = {
                            'id': r['runner_id'],
                            'baseout_history': [(0, cur_outs)]
                        }
                    if r['is_out']:
                        base = r['start_base']
                        process_runner(game_results, season, level_id,
                            new_runners[base]['baseout_history'],
                            score = False)
                        if r['runner_id'] == new_runners[base]['id']:
                            del new_runners[base]
                    elif r['end_base'] == 'score':
                        base = r['start_base']
                        if base not in new_runners:
                            print(f"Couldn't find scoring runner: " + \
                                f"{game_pk} {ab} {event}...ignoring.")
                            continue
                        process_runner(game_results, season, level_id,
                            new_runners[base]['baseout_history'],
                            score = True)
                        if r['runner_id'] == new_runners[base]['id']:
                            del new_runners[base]
                    else:
                        if r['end_base'] is None:
                            print(f"Null end base {game_pk} {ab} {event}")
                            continue
                        start_base = r['start_base']
                        end_base = int(r['end_base'][0:1])
                        if start_base == end_base:
                            # ignore this case
                            continue
                        if start_base in new_runners and \
                            r['runner_id'] == new_runners[start_base]['id']:
                            new_runners[end_base] = new_runners[start_base]
                            del new_runners[start_base]
                        elif start_base in cur_runners and \
                            r['runner_id'] == cur_runners[start_base]['id']:
                            new_runners[end_base] = cur_runners[start_base]
                        else:
                            print(new_runners)
                            assert False, "Trying to move a mismatched " \
                                + f"runner from {start_base}, {game_pk} " \
                                + f"{ab} {event}"
                        assert end_base in new_runners, \
                            f"Failed to move runner to {end_base}? " + \
                            f"{game_pk} {ab} {event}"
                        new_runners[end_base]['baseout_history'].append(\
                            (end_base, plays[ab]['outs']))
                    
        cur_runners = new_runners

        if plays[ab]['outs'] == 3:
            for base in cur_runners:
                process_runner(game_results, season, level_id,
                    cur_runners[base]['baseout_history'], score = False)
        cur_outs = plays[ab]['outs']

    return game_results

query = """
  SELECT season, level_id, game_pk 
  FROM mlbapi.games_schedule_deduped
  WHERE game_type = 'R' AND left(status_code, 1) = 'F' AND season = 2020
  ORDER BY official_date DESC
"""
cage_cur.execute(query)
games = cage_cur.fetchall()
for row in games:
    season, level_id, game_pk = row
    game_counts = process_game(season, level_id, game_pk)
    print(game_pk)
    runner_counts.add(game_counts)

buffer = io.StringIO()
r = runner_counts.results()
for season in r:
    for level_id in r[season]:
        for outs in sorted(r[season][level_id]):
            for base in r[season][level_id][outs]:
                buffer.write("|".join([str(x) for x in \
                    (season, level_id, outs, base, \
                    r[season][level_id][outs][base]['runs'], \
                    r[season][level_id][outs][base]['total'])]))
                buffer.write("\n")
cage_cur.execute("TRUNCATE legacy_models.runner_runs")
buffer.seek(0)
cage_cur.copy_from(buffer, "legacy_models.runner_runs", sep="|")
buffer.close()
cage.commit()
