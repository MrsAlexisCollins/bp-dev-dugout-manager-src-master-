from dugout_manager.connectors.cage import session_cage  
from dugout_manager.connectors.dugout import session_dugout
from dugout_manager.cage_models import Mlb_stats_pitching,Mlb_people, Bp_xref,Mlb_teams
from dugout_manager.dugout_models import Bp_teams, Bp_stats_pitching
from sqlalchemy import func
from datetime import datetime

all_mlb_teams = session_cage.query(Mlb_teams)
bp_teams = session_dugout.query(Bp_teams)
######### TO DO dupe management

mlb_stats_pitching = session_cage.query(Mlb_stats_pitching).join(Mlb_people, Bp_xref).all()

for row in mlb_stats_pitching:
    new_entry = {}
    for xref in row.people.bpxref:
        new_entry['bpid'] =  xref.bpid 
    new_entry['season'] = row.season

    new_roster_entry_team = all_mlb_teams.filter(Mlb_teams.id == row.team).first()
    new_roster_entry_team_bp = bp_teams.filter(Bp_teams.team_name ==  new_roster_entry_team.name  ).first()
    if new_roster_entry_team_bp:
        new_entry['team_id'] =  new_roster_entry_team_bp.team_id
    else:
        continue

    new_entry['timestamp'] = row.timestamp
    new_entry['games_played'] = row.games_played
    new_entry['games_started'] = row.games_started
    new_entry['ground_outs'] = row.ground_outs
    new_entry['air_outs'] = row.air_outs
    new_entry['runs'] = row.runs
    new_entry['doubles'] = row.doubles
    new_entry['triples'] = row.triples
    new_entry['home_runs'] = row.home_runs
    new_entry['strike_outs'] = row.strike_outs
    new_entry['base_on_balls'] = row.base_on_balls
    new_entry['intentional_walks'] = row.intentional_walks
    new_entry['hits'] = row.hits
    new_entry['avg'] = row.avg
    new_entry['at_bats'] = row.at_bats
    new_entry['obp'] = row.obp
    new_entry['slg'] = row.slg
    new_entry['ops'] = row.ops
    new_entry['caught_stealing'] = row.caught_stealing
    new_entry['stolen_bases'] = row.stolen_bases
    new_entry['stolen_base_percentage'] = row.stolen_base_percentage
    new_entry['ground_into_double_play'] = row.ground_into_double_play
    new_entry['number_of_pitches'] = row.number_of_pitches
    new_entry['era'] = row.era
    new_entry['innings_pitched'] = row.innings_pitched
    new_entry['wins'] = row.wins
    new_entry['losses'] = row.losses
    new_entry['saves'] = row.saves
    new_entry['save_opportunities'] = row.save_opportunities
    new_entry['holds'] = row.holds
    new_entry['blown_saves'] = row.blown_saves
    new_entry['earned_runs'] = row.earned_runs
    new_entry['whip'] = row.whip
    new_entry['batters_faced'] = row.batters_faced
    new_entry['games_pitched'] = row.games_pitched
    new_entry['complete_games'] = row.complete_games
    new_entry['shutouts'] = row.shutouts
    new_entry['strikes'] = row.strikes
    new_entry['strike_percentage'] = row.strike_percentage
    new_entry['hit_batsmen'] = row.hit_batsmen
    new_entry['balks'] = row.balks
    new_entry['wild_pitches'] = row.wild_pitches
    new_entry['pickoffs'] = row.pickoffs
    new_entry['total_bases'] = row.total_bases
    new_entry['ground_outs_to_airouts'] = row.ground_outs_to_airouts
    new_entry['win_percentage'] = row.win_percentage
    new_entry['pitches_per_inning'] = row.pitches_per_inning
    new_entry['games_finished'] = row.games_finished
    new_entry['strikeout_walk_ratio'] = row.strikeout_walk_ratio
    new_entry['strikeouts_per_9_inn'] = row.strikeouts_per_9_inn
    new_entry['walks_per_9_inn'] = row.walks_per_9_inn
    new_entry['hits_per_9_inn'] = row.hits_per_9_inn
    new_entry['runs_scored_per_9'] = row.runs_scored_per_9
    new_entry['home_runs_per_9'] = row.home_runs_per_9
    new_entry['inherited_runners'] = row.inherited_runners
    new_entry['inherited_runners_scored'] = row.inherited_runners_scored	

    new_row = Bp_stats_pitching(**new_entry)
    session_dugout.add(new_row) 

    session_dugout.commit()