
from dugout_manager.read import session_read  
from dugout_manager.write import session_write
from dugout_manager.cage_models import Bp_xref, Mlb_team_rosters,    Mlb_teams,Mlb_people
from dugout_manager.dugout_models import   Bp_teams, Bp_team_rosters 
from sqlalchemy.sql.expression import func

from datetime import datetime

mlb_team_rosters = session_read.query(Mlb_team_rosters).join(Mlb_people, Bp_xref).all()

all_mlb_teams = session_read.query(Mlb_teams)
bp_teams = session_write.query(Bp_teams)

for row in mlb_team_rosters:
    new_roster_entry = {}
    new_roster_entry['timestamp'] = row.timestamp
    for xref in row.people.bpxref:
        new_roster_entry['player'] =  xref.bpid 
    new_roster_entry_team = all_mlb_teams.filter(Mlb_teams.id == row.team).first()
    new_roster_entry_team_bp = bp_teams.filter(Bp_teams.team_name ==  new_roster_entry_team.name  ).first()
    if new_roster_entry_team_bp:
        new_roster_entry['team'] =  new_roster_entry_team_bp.team_id
    else:
        new_roster_entry['team'] = None
    new_roster_entry['jersey_number'] = row.jersey_number
    new_roster_entry['position'] = row.position
    new_roster_entry['status'] =  row.status
    new_roster_entry['updated_timestamp'] = datetime.now()  
    
    new_roster_entry_row = Bp_team_rosters(**new_roster_entry)
    session_write.add(new_roster_entry_row) 
    #session_write.commit()