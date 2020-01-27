
from dugout_manager.connectors.cage import session_cage  
from dugout_manager.connectors.dugout import session_dugout
from dugout_manager.cage_models import Bp_xref,  Mlb_people_roster_status,   Mlb_teams,Mlb_people
from dugout_manager.dugout_models import   Bp_teams, Bp_people_roster_status 

from datetime import datetime

## copy is fairly direct, need to replace MLB team and player IDs with BP values
all_mlb_teams = session_cage.query(Mlb_teams)
bp_teams = session_dugout.query(Bp_teams)

mlb_people_roster_status = session_cage.query(Mlb_people_roster_status).join(Mlb_people,Bp_xref).all()

new_status_entries = []
# this is a light load relatively speaking, so just flush and load
session_dugout.query(Bp_people_roster_status).delete()

for row in mlb_people_roster_status:
    new_status_entry = {}
    for xref in row.people.bpxref:
        new_status_entry['bpid'] =  xref.bpid 
    new_status_entry['active'] = row.active


    new_status_entry_team = all_mlb_teams.filter(Mlb_teams.id == row.current_team).first()
    if new_status_entry_team:   
        new_status_entry_team_bp = bp_teams.filter(Bp_teams.team_name ==  new_status_entry_team.name  ).first()
        if new_status_entry_team_bp:
            new_status_entry['current_team'] =  new_status_entry_team_bp.team_id
        else:
            new_status_entry['current_team'] = None
    else:
        new_status_entry['current_team'] = None
    
    new_status_entry['last_played_date'] = row.last_played_date
    new_status_entry['mlb_debut_date'] = row.mlb_debut_date
    new_status_entry['updated_timestamp']  = datetime.now()  

    new_status_entry_row = Bp_people_roster_status(**new_status_entry)
    session_dugout.add(new_status_entry_row) 

session_dugout.commit()
