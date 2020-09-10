#!/usr/bin/python3

from collections import defaultdict
import csv
import re

# utility function for easy initialization
def nested_dict(n, type):
    if n == 1:
        return defaultdict(type)
    else:
        return defaultdict(lambda: nested_dict(n-1, type))

# for mlbapi.plays
pg_header_line = "game_pk | game_type | season |       game_date        |     official_date | reschedule_date | rescheduled_from | status_code | away_team | away_split_squad | away_score | home_team | home_split_squad | home_score | venue | game_number | public_facing | double_header | gameday_type | tiebreaker | day_night | scheduled_innings | inning_break_length | games_in_series | series_game_number | record_source | if_necessary | level_id |  calendar_event_id   | at_bat_index | type  |    event     | event_type  |          description          | rbi | away_score | home_score | half_inning | inning |         start_time         |          end_time | is_complete | is_scoring_play | has_review | has_out | captivating_index | balls | strikes | outs | batter_id | bat_side | pitcher_id | pitch_hand | splits_batter | splits_pitcher | splits_men_on_base | post_on_first_id | post_on_second_id | post_on_third_id"

we_header_line = "season | level_id | game_type | game_pk | event_id | away_team | home_team | fld_team | event_cd | inn_ct | bat_home_id | outs_ct | event_outs_ct | h_cd | bunt_fl | battedball_cd | batter_id | bat_hand_cd | pitcher_id | pit_hand_cd | pos2_fld_id | pos3_fld_id | pos4_fld_id | pos5_fld_id | pos6_fld_id | pos7_fld_id | pos8_fld_id | pos9_fld_id | startbases_cd | endbases_cd | event_runs_ct | is_pitcher_hitting | fld_cd | po1_fld_cd | ass1_fld_cd | ass2_fld_cd | ass3_fld_cd | bat_play_tx | run1_origin_event_id | run2_origin_event_id | run3_origin_event_id | official_date"
pg_headers = re.sub(" +", " ", pg_header_line).split(' | ')
pg_col_nos = {pg_headers[col_no]: col_no \
    for col_no in range(0, len(pg_headers))}
we_headers = re.sub(" +", " ", we_header_line).split(' | ')
we_col_nos = {we_headers[col_no]: col_no \
    for col_no in range(0, len(we_headers))}
pg_plays = nested_dict(2, dict)
we_plays = nested_dict(4, list)
legacy_teams = {}
mlbids = {}
xrefs = {}
teams_xrefs = {}
etr = {}

# dugout:
# \copy (select team_id, mlbam_id from entitas.masterteams_legacy where lvl='mlb' and year_id=2019) to legacy_teams.csv csv
with open("legacy_teams.csv", "r") as tfh:
    teams = csv.reader(tfh)
    for row in teams:
        legacy_teams[row[1]] = row[0]

# cage:
# \copy (select bpid, xref_id from xrefs.people_refs where xref_id::int in (select distinct p.batter_id as id from mlbapi.games_schedule_deduped gs left join mlbapi.plays p using (game_pk) where gs.season=2019 and gs.level_id=1 and gs.game_type='R' and left(gs.status_code, 1)='F' union select distinct p.pitcher_id as id from mlbapi.games_schedule_deduped gs left join mlbapi.plays p using (game_pk) where gs.season=2019 and gs.level_id=1 and gs.game_type='R' and left(gs.status_code, 1)='F' order by id) ) to "people_xrefs.csv" csv;
with open("people_xrefs.csv", "r") as xfh:
    xrefs = csv.reader(xfh)
    for row in xrefs:
        mlbids[row[0]] = row[1]

# cage:
# \copy mlbapi.event_types_retrosheet to etr.csv csv; 
with open("etr.csv", "r") as efh:
    event_table = csv.reader(efh)
    for row in event_table:
        etr[row[0]] = row[1]

with open("plays2019pg.csv", "r") as pgfh:
    plays2019 = csv.reader(pgfh)
    for row in plays2019:
        record = {pg_headers[col_no]: row[col_no]
            for col_no in range(0, len(pg_headers))}
        month = int(record['official_date'][5:7])
        day   = int(record['official_date'][8:10])
        pg_plays[record['game_pk']][record['at_bat_index']] = record

# cage:
# \copy (select e.*, gs.official_date from mlbapi.warehouse_events e left join mlbapi.games_schedule_deduped gs using (game_pk) where gs.season=2019 and gs.level_id=1 and gs.game_type = 'R') to warehouse_events2019.csv csv;


with open("warehouse_events2019.csv", "r") as wefh:
    we2019 = csv.reader(wefh)
    for row in we2019:
        record = {we_headers[col_no]: row[col_no]
            for col_no in range(0, len(we_headers))}
        month = int(record['official_date'][5:7])
        day   = int(record['official_date'][8:10])
        we_plays[month][day][legacy_teams[record['away_team']]]\
            [legacy_teams[record['home_team']]].append(record)

# MySQL (replace mysqlstats with mysql CLI and appropriate creds
# echo "select e.* from warehouse.events e inner join lwts.complete_innings c using (year_id, lvl, game_id, inn_ct, bat_home_id) where e.year_id=2019 and e.lvl='mlb'" | mysqlstats > events2019.tsv

my_headers = []
with open("events2019.tsv", "r") as myfh:
    events2019 = csv.reader(myfh, delimiter="\t")
    for row in events2019:
        if len(my_headers) == 0:
            my_headers = row
            my_col_nos = {my_headers[col_no]: col_no \
                for col_no in range(0, len(my_headers))}
            continue
        record = {my_headers[col_no]: row[col_no]
            for col_no in range(0, len(my_headers))}
        month = int(record['GAME_ID'][7:9])
        day   = int(record['GAME_ID'][9:11])
        plays = we_plays[month][day][record['AWAY_TEAM_ID']]\
            [record['HOME_TEAM_ID']]
        for play in plays:
            if record['BAT_ID'] not in mlbids or \
                record['PIT_ID'] not in mlbids:
                continue
            if mlbids[record['BAT_ID']] == play['batter_id'] and \
                mlbids[record['PIT_ID']] == play['pitcher_id'] and \
                record['INN_CT'] == play['inn_ct'] and \
                record['OUTS_CT'] == play['outs_ct'] and \
                (int(record['EVENT_CD']) in (2, 18, 19, 20, 21) or \
                 play['event_cd'] in (2, 18, 19, 20, 21)) and \
                record['EVENT_CD'] != play['event_cd']:
                print(",".join([
                    record['seq_events'],
                    record['GAME_ID'],
                    record['INN_CT'],
                    record['OUTS_CT'],
                    record['BAT_ID'],
                    record['PIT_ID'],
                    play['game_pk'],
                    play['event_id'],
                    record['EVENT_CD'],
                    play['event_cd'],
                    record['EVENT_TX'],
                    pg_plays[play['game_pk']][play['event_id']]['description']
                ]))
