from dugout_manager.read import session_read  
from dugout_manager.write import session_write
from dugout_manager.mapping import *
from sqlalchemy import func
from datetime import datetime
######### TO DO dupe management

#load
pecota_book_list = session_read.query(Pecota_book_list).all()
#xref prep
bp_organizations = session_write.query(Bp_organizations).join(Xref_org, Bp_organizations.org_id == Xref_org.org_id)
#clear the way
bp_book_list = session_write.query(Bp_book_list) 
bp_book_list.delete()   #nothing happens until commit, which is followed by a bulk write

new_entries = []
for row in pecota_book_list:
    new_entry = {}
    new_entry['bpid'] =  row.playerid
    new_entry['position']  = row.position
    new_entry_org = bp_organizations.filter(Xref_org.xref_id == row.team).first()
    if new_entry_org :
        new_entry['org_id'] =  new_entry_org.org_id
    else:
        continue
    new_entries.append(new_entry)

for new_entry in new_entries:
    new_row = Bp_book_list(**new_entry)
    session_write.add(new_row)

session_write.commit()