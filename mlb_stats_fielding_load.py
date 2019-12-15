from dugout_manager.read import session_read  
from dugout_manager.write import session_write
from dugout_manager.cage_models import Mlb_stats_fielding,Mlb_people, Bp_xref,Mlb_teams
from dugout_manager.dugout_models import Bp_teams, Bp_stats_fielding
from sqlalchemy import func
from datetime import datetime

all_mlb_teams = session_read.query(Mlb_teams)
bp_teams = session_write.query(Bp_teams)
######### TO DO dupe management

mlb_stats_fielding = session_read.query(Mlb_stats_fielding).join(Mlb_people, Bp_xref).all()

for row in mlb_stats_fielding:
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

    new_entry['position'] = row.position
    new_entry['timestamp'] = row.timestamp
    new_entry['assists'] = row.assists
    new_entry['put_outs'] = row.put_outs
    new_entry['errors'] = row.errors
    new_entry['chances'] = row.chances
    new_entry['fielding'] = row.fielding
    new_entry['range_factor_per_game'] = row.range_factor_per_game
    new_entry['range_factor_per_9_inn'] = row.range_factor_per_9_inn
    new_entry['innings'] = row.innings
    new_entry['games'] = row.games
    new_entry['games_started'] = row.games_started
    new_entry['double_plays'] = row.double_plays
    new_entry['triple_plays'] = row.triple_plays
    new_entry['throwing_errors'] = row.throwing_errors


    new_row = Bp_stats_fielding(**new_entry)
    session_write.add(new_row) 

    session_write.commit()