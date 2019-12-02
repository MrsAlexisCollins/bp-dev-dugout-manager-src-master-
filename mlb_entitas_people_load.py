
from dugout_manager.read import session_read  
from dugout_manager.write import session_write
from dugout_manager.mapping import Bp_people_search, Mlb_people_search

from datetime import datetime

mlb_persons = session_read.query(Mlb_people_search)

for row in mlb_persons:
    new_entry = {}
    new_entry['updated_timestamp'] = datetime.now()  
    new_entry['bpid'] = row.bpid
    new_entry['full_name'] = row.full_name
    new_entry['active'] = row.active
    new_entry['current_team_id'] = row.current_team_id
    new_entry['roster_team_id'] = row.roster_team_id
    new_entry['birth_date'] = row.birth_date
    new_entry['death_date'] = row.death_date
    new_entry['throws'] = row.throws
    new_entry['bats'] = row.bats
    new_entry['height'] = row. height
    new_entry['weight'] = row.weight
    new_entry['boxscore_name'] = row.boxscore_name
    new_entry['first_name_proper'] = row.first_name_proper
    new_entry['first_name'] = row.first_name
    new_entry['middle_name'] = row.middle_name
    new_entry['last_name'] = row.last_name
    new_entry['matrilineal_name'] = row.matrilineal_name
    new_entry['full_name'] = row.full_name
    new_entry['sortable_name'] = row.sortable_name
    new_entry['birth_city'] = row.birth_city
    new_entry['birth_state_province'] = row.birth_state_province
    new_entry['birth_country'] = row.birth_country

    new_row = Bp_people_search(**new_entry)
    session_write.add(new_row) 
    session_write.commit()

