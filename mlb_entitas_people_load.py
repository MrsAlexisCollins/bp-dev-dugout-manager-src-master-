
from dugout_manager.read import session_read  
from dugout_manager.write import session_write
from dugout_manager.mlb_entitas.mapping import Bp_people, Bp_xref, Mlb_people, Mlb_people_names

from datetime import datetime

mlb_persons = session_read.query(Mlb_people).join(Bp_xref,Mlb_people_names)

new_entries = [] 

for row in mlb_persons:
    new_entry = {}
    new_entry['use_full_name'] = row.full_name
    new_entry['updated_timestamp'] = datetime.now()  
    for xref in row.bpxref:
        new_entry['bpid'] =  xref.bpid
    for nameref in row.people_names:
        new_entry['middle_name'] =  nameref.middle_name
        new_entry['first_name'] =  nameref.use_name
        new_entry['last_name'] =  nameref.last_name
        new_entry['use_sortable_name'] =  nameref.last_first_name
        new_entry['matrilineal_name'] =  nameref.name_matrilineal

    new_entries.append(new_entry)
    
for new_entry in new_entries:
    new_row = Bp_people(**new_entry)
    session_write.add(new_row) 

#session_write.commit()