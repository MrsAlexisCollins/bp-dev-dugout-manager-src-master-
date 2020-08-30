
from dugout_manager.connectors.write import session_write
from dugout_manager.connectors.read import session_read
from dugout_manager.cage_models import Mlb_schedule, xref_teams, Mlb_plays
from dugout_manager.dugout_models import schedule, schedule_team
from sqlalchemy import func
from datetime import datetime
import pandas as pd
from numpy import nan

### read in home games
schedule_read_home = session_read.query(

	Mlb_schedule.game_pk, Mlb_schedule.game_type, Mlb_schedule.season
	, Mlb_schedule.home_team.label("team_id")
	, Mlb_schedule.away_team.label("opp_team_id")

	, Mlb_schedule.status_code

	, func.min(Mlb_schedule.scheduled_innings).label("scheduled_innings")

	, func.max(Mlb_schedule.home_score).label("score")
	, func.max(Mlb_schedule.away_score).label("opp_score")

	, func.max(Mlb_schedule.game_number).label("game_number")
	, func.min(Mlb_schedule.game_date).label("game_date1")
	, func.max(Mlb_schedule.reschedule_date).label("game_date2")

	).filter(

	Mlb_schedule.season == 2020
	, Mlb_schedule.game_type == "R"
	#, Mlb_schedule.home_team.in_((158,140))
	#, Mlb_schedule.game_pk == 631289

	).group_by(

	Mlb_schedule.game_pk
	, Mlb_schedule.game_type
	, Mlb_schedule.season
	, Mlb_schedule.home_team
	, Mlb_schedule.away_team
	, Mlb_schedule.status_code).all()

# away games
schedule_read_away = session_read.query(

	Mlb_schedule.game_pk, Mlb_schedule.game_type, Mlb_schedule.season
	, Mlb_schedule.away_team.label("team_id")
	, Mlb_schedule.home_team.label("opp_team_id")
	, Mlb_schedule.status_code

	, func.min(Mlb_schedule.scheduled_innings).label("scheduled_innings")

	, func.max(Mlb_schedule.away_score).label("score")
	, func.max(Mlb_schedule.home_score).label("opp_score")

	, func.max(Mlb_schedule.game_number).label("game_number")
	, func.min(Mlb_schedule.game_date).label("game_date1")
	, func.max(Mlb_schedule.reschedule_date).label("game_date2")

	).filter(

	Mlb_schedule.season == 2020
	, Mlb_schedule.game_type == "R"
	#, Mlb_schedule.away_team.in_((158,140))
	#, Mlb_schedule.game_pk == 631289

	).group_by(

	Mlb_schedule.game_pk
	, Mlb_schedule.game_type
	, Mlb_schedule.season
	, Mlb_schedule.away_team
	, Mlb_schedule.home_team
	, Mlb_schedule.status_code).all()

# print(schedule_read_home)

bp_team_id = session_read.query(xref_teams.teams_id, xref_teams.xref_id).filter(xref_teams.xref_type == 'mlbam').all()

actual_innings = session_read.query(Mlb_plays.game_pk, func.max(Mlb_plays.inning).label("innings_played")).group_by(Mlb_plays.game_pk).all()

new_entries = []

for row in schedule_read_home:
	new_entry = {}
	new_entry['game_pk'] = row.game_pk
	new_entry['game_type'] = row.game_type
	new_entry['season'] = row.season
	new_entry['team_id'] = row.team_id
	new_entry['opp_team_id'] = row.opp_team_id
	new_entry['home_away'] = "home"
	new_entry['game_date1'] = row.game_date1
	new_entry['game_date2'] = row.game_date2
	new_entry['status_code'] = row.status_code
	new_entry['game_number'] = row.game_number
	new_entry['scheduled_innings'] = row.scheduled_innings

	# get score if it's finished/finished early game
	if row.status_code[:1] == "F":
		new_entry['score'] = row.score
		new_entry['opp_score'] = row.opp_score

	if row.score is None or (row.score == 0 and row.opp_score == 0) or row.status_code[:1] != "F":
		new_entry["win"] = None
	elif row.score > row.opp_score:
		new_entry['win'] = 1
	else: # elif row.opp_score < row.score:
		new_entry["win"] = 0

	# new_entry['double_header'] = row.double_header
	# new_entry['level_id'] = row.level_id 
	# new_entry['calendar_event_id'] = row.calendar_event_id
	new_entries.append(new_entry)

for row in schedule_read_away:
	new_entry = {}
	new_entry['game_pk'] = row.game_pk
	new_entry['game_type'] = row.game_type
	new_entry['season'] = row.season
	new_entry['team_id'] = row.team_id
	new_entry['opp_team_id'] = row.opp_team_id
	new_entry['home_away'] = "away"
	new_entry['game_date1'] = row.game_date1
	new_entry['game_date2'] = row.game_date2
	new_entry['status_code'] = row.status_code
	new_entry['game_number'] = row.game_number
	new_entry['scheduled_innings'] = row.scheduled_innings

	if row.status_code[:1] == "F":
		new_entry['score'] = row.score
		new_entry['opp_score'] = row.opp_score

	if row.score is None or (row.score == 0 and row.opp_score == 0) or row.status_code[:1] != "F":
		new_entry["win"] = None
	elif row.score > row.opp_score:
		new_entry['win'] = 1
	else: # elif row.opp_score < row.score:
		new_entry["win"] = 0

	# new_entry['level_id'] = row.level_id 
	# new_entry['calendar_event_id'] = row.calendar_event_id
	new_entries.append(new_entry)


# sort
new_entries = sorted(new_entries, key = lambda i: (i['team_id'], i['game_date1']))
df = pd.DataFrame(new_entries)
# were problematic game_pks
#df = df[~df['game_pk'].isin([630918,631129,631340,631471])]
## count duplicates 
df['dupl'] = df.groupby(['game_pk','team_id'])['game_pk'].transform('size')
# FOR COMPLETED GAMES: if we have a duplicate with one status_code being F, dump the other one
# check if a final status exists. a bit dangerous? maybe also group by team_id
df.loc[df['game_pk'].isin(df.loc[df['status_code'].astype(str).str[0] == "F", 'game_pk'].values), 'has_f'] = 1
df['has_f'] = df['has_f'].fillna(0)
# delete dupl rows that have final in a game_pk and are not status code final
# 631339,630495,630575,630496,630591,631469,631567,631127,631219,631220
df.drop(df[(df['dupl'] == 2) & (df['has_f'] == 1) & (df['status_code'].astype(str).str[0] != 'F')].index, inplace=True)
# FOR SCHEDULED GAMES: if we have a duplicate with one postponement and another scheduled game, dump the postponed game 
df.loc[df['game_pk'].isin(df.loc[df['status_code'] == "S", 'game_pk'].values), 'has_s'] = 1
df['has_s'] = df['has_s'].fillna(0)
# TODO: transfer the original schedule date into date1 and move the reschedule date into date2
df.drop(df[(df['dupl'] > 1) & (df['has_s'] == 1) & (df['status_code'] != 'S')].index, inplace=True)
# calc running totals with pandas
df['game_date'] = df['game_date2'].fillna(df['game_date1'])
df['season_number'] = df[df.status_code.astype(str).str[0] == "F"].groupby(['team_id'])['game_date1'].rank(ascending=True)
# calc running totals
df['total_games'] = df.groupby('team_id')['team_id'].transform('count')
df['games_remaining'] = df['total_games'] - df['season_number']
df['rs'] = df.groupby('team_id')['score'].transform(pd.Series.cumsum)
df['ra'] = df.groupby('team_id')['opp_score'].transform(pd.Series.cumsum)
df['wins'] = df.groupby('team_id')['win'].transform(pd.Series.cumsum)
df['losses'] = df['season_number'] - df['wins']
## map BP team ID
bp_teams = pd.DataFrame(bp_team_id)
# pd.set_option('display.max_rows', None)
# pd.set_option('display.max_columns', None)
# pd.set_option('display.width', None)
# pd.set_option('display.max_colwidth', None)

bp_teams['xref_id'] = bp_teams['xref_id'].astype(str).astype(int)

# there must be a better way to do this
df = pd.merge(df, bp_teams, left_on = "team_id", right_on = "xref_id", how='left')
df['team_id'] = df['teams_id']
df = df.drop(['teams_id', 'xref_id'], 1)

df = pd.merge(df, bp_teams, left_on = "opp_team_id", right_on = "xref_id", how='left')
df['opp_team_id'] = df['teams_id']
df = df.drop(['teams_id', 'xref_id'], 1)

# add innings played
df = pd.merge(df, pd.DataFrame(actual_innings), on = "game_pk", how = "left")

## dump support columns
df = df.drop(['total_games', 'win', 'dupl', 'has_f', 'has_s'], 1)

## convert to single-game table

# aggregate function to apply
def agg_home_away(x):	# https://stackoverflow.com/a/47103408
    d = {}
    d['home_team'] = x.loc[x['home_away'] == "home"]['team_id'].max()
    d['away_team'] = x.loc[x['home_away'] == "away"]['team_id'].max()
    d['home_score'] = x.loc[x['home_away'] == "home"]['score'].max()
    d['away_score'] = x.loc[x['home_away'] == "away"]['score'].max()
    return pd.Series(d, index=['home_team', 'away_team', 'home_score', 'away_score'])

df_single = df.groupby(['game_pk', 'game_type', 'season', 'game_date', 'game_date1', 'game_date2', 'game_number', 'scheduled_innings', 'innings_played', 'status_code'], as_index=False, dropna=False).apply(agg_home_away)

## look at csv outputs
df.to_csv('out.csv', index=False)
df_single.to_csv('out_single.csv', index=False)

## using pd creates NaTs and NaNs, psycopg prefers None
# had this earlier in code, but putting together with below block
df.game_date2 = df.game_date2.astype(object).where(df.game_date2.notnull(), None)
df = df.replace({nan: None})

# something with the agg above fucks the game date up
df_single.game_date2 = df_single.game_date2.astype(object).where(df_single.game_date2.notnull(), None)
df_single = df_single.replace({nan: None})

## done manipulating data

## go back from pd to list of dicts to write to pg
df_list = df.to_dict('records')
df_list_single = df_single.to_dict('records')

# re-sort the schedule (not necessary)
df_list = sorted(df_list, key = lambda i: (i['game_date'], i['game_pk'], i['home_away']))
df_list_single = sorted(df_list_single, key = lambda i: (i['game_date']))


#clear teams first
schedule_team_write = session_write.query(schedule_team) 
schedule_team_write.delete() 

# write plain schedule first
schedule_write = session_write.query(schedule) 
schedule_write.delete() 

for new_entry in df_list_single:
	new_row = schedule(**new_entry)
	session_write.add(new_row)

session_write.commit()

# write schedule per team (has FK to schedule)

for new_entry in df_list:
	new_row = schedule_team(**new_entry)
	session_write.add(new_row)


session_write.commit()
