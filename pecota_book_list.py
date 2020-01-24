from Pecotadugout_manager.connectors.cage import session_cage  
from Pecotadugout_manager.connectors.dugout import session_dugout
from dugout_manager.cage_models import Pecota_book_list
from dugout_manager.dugout_models import Bp_organizations, Xref_org, Bp_book_list
from sqlalchemy import func
from datetime import datetime
######### TO DO dupe management

#load
pecota_book_list = session_cage.query(Pecota_book_list).all()
#xref prep
bp_organizations = session_dugout.query(Bp_organizations).join(Xref_org, Bp_organizations.org_id == Xref_org.org_id)
#clear the way
bp_book_list = session_dugout.query(Bp_book_list) 
bp_book_list.delete()   #nothing happens until commit, which is followed by a bulk write

new_entries = []
for row in pecota_book_list:
    new_entry = {}
    new_entry['bpid'] =  row.playerid
    new_entry['position']  = row.position
    new_entry['oneline']  = row.oneline
    new_entry_org = bp_organizations.filter(Xref_org.xref_id == row.team).first()
    if new_entry_org :
        new_entry['org_id'] =  new_entry_org.org_id
    else:
        continue
    new_entries.append(new_entry)

for new_entry in new_entries:
    new_row = Bp_book_list(**new_entry)
    session_dugout.add(new_row)

session_dugout.commit()