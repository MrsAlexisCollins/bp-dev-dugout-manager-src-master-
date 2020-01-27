from dugout_manager.connectors.cage import session_cage  
from dugout_manager.connectors.dugout import session_dugout
from dugout_manager.cage_models import Mlb_stats_catching,Mlb_people, Bp_xref,Mlb_teams
from dugout_manager.dugout_models import Bp_teams, Bp_stats_catching
from sqlalchemy import func
from datetime import datetime

all_mlb_teams = session_cage.query(Mlb_teams)
bp_teams = session_dugout.query(Bp_teams)
######### TO DO dupe management

mlb_stats_catching = session_cage.query(Mlb_stats_catching).join(Mlb_people, Bp_xref).all()

for row in mlb_stats_catching:
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
    new_entry['runs'] = row.runs
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
    new_entry['era'] = row.era
    new_entry['earned_runs'] = row.earned_runs
    new_entry['whip'] = row.whip
    new_entry['batters_faced'] = row.batters_faced
    new_entry['games_pitched'] = row.games_pitched
    new_entry['hit_batsmen'] = row.hit_batsmen
    new_entry['wild_pitches'] = row.wild_pitches
    new_entry['pickoffs'] = row.pickoffs
    new_entry['total_bases'] = row.total_bases
    new_entry['strikeout_walk_ratio'] = row.strikeout_walk_ratio
    new_entry['strikeouts_per_9_inn'] = row.strikeouts_per_9_inn
    new_entry['walks_per_9_inn'] = row.walks_per_9_inn
    new_entry['hits_per_9_inn'] = row.hits_per_9_inn
    new_entry['catchers_interference'] = row.catchers_interference
    new_entry['sac_bunts'] = row.sac_bunts
    new_entry['sac_flies'] = row.sac_flies
    new_row = Bp_stats_catching(**new_entry)
    session_dugout.add(new_row) 

    session_dugout.commit()