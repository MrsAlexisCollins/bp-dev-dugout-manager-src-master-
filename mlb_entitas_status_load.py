
from dugout_manager.mlb_entitas.read import session_read  
from dugout_manager.mlb_entitas.write import session_write
from dugout_manager.mlb_entitas.mapping import Bp_xref,  Mlb_people_roster_status, Bp_teams, Bp_people_roster_status, Mlb_teams,Mlb_people

from datetime import datetime

## copy is fairly direct, need to replace MLB team and player IDs with BP values
all_mlb_teams = session_read.query(Mlb_teams)
bp_teams = session_write.query(Bp_teams)

mlb_people_roster_status = session_read.query(Mlb_people_roster_status).join(Mlb_people,Bp_xref).all()

new_status_entries = []

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
    session_write.add(new_status_entry_row) 
    #session_write.commit()