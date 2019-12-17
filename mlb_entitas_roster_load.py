
from dugout_manager.connectors.read import session_read  
from dugout_manager.connectors.write import session_write
from dugout_manager.cage_models import   Bp_xref,  Mlb_people_roster_entries , Mlb_teams,Mlb_people
from dugout_manager.dugout_models import  Bp_teams, Bp_people_roster_entries 
from sqlalchemy.sql.expression import func

from datetime import datetime

## copy is fairly direct, need to replace MLB team and player IDs with BP values
all_mlb_teams = session_read.query(Mlb_teams)
bp_teams = session_write.query(Bp_teams)

last_bp_roster_entry_status_date = session_write.query(func.max(Bp_people_roster_entries.status_date)).scalar()
#
mlb_people_roster_entries = session_read.query(Mlb_people_roster_entries).filter(
    Mlb_people_roster_entries.status_date > last_bp_roster_entry_status_date
    ).all()

print(session_read.query(Mlb_people_roster_entries).filter(
    Mlb_people_roster_entries.status_date > last_bp_roster_entry_status_date
    )  )

new_roster_entries = [] 

for row in mlb_people_roster_entries:
    new_roster_entry = {}
    for xref in row.people.bpxref:
        new_roster_entry['bpid'] =  xref.bpid 
    new_roster_entry['jersey_number'] = row.jersey_number
    new_roster_entry['position'] = row.position
    new_roster_entry['status'] =  row.status

    new_roster_entry_team = all_mlb_teams.filter(Mlb_teams.id == row.team).first()
    new_roster_entry_team_bp = bp_teams.filter(Bp_teams.team_name ==  new_roster_entry_team.name  ).first()
    if new_roster_entry_team_bp:
        new_roster_entry['team'] =  new_roster_entry_team_bp.team_id
    else:
        new_roster_entry['team'] = None
    
    new_roster_entry['is_active'] =  row.is_active
    new_roster_entry['start_date'] =  row.start_date
    new_roster_entry['end_date'] =  row.end_date
    new_roster_entry['status_date'] =  row.status_date
    new_roster_entry['is_active_forty_man'] =  row.is_active_forty_man
    new_roster_entry['updated_timestamp'] = datetime.now()  

    new_roster_entries.append(new_roster_entry)


for roster_entry in new_roster_entries:
    new_roster_entry_row = Bp_people_roster_entries(**roster_entry)
    session_write.add(new_roster_entry_row) 


# session_write.commit()