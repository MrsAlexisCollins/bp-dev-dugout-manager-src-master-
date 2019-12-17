
from dugout_manager.connectors.write import session_write
from dugout_manager.connectors.ondeck import session_ondeck
from dugout_manager.ondeck_models import Od_depth_charts_batters, Od_depth_charts_pitchers
from dugout_manager.dugout_models import Bp_people_search
from sqlalchemy import func
from datetime import datetime

### Built to prime the system now, not update

### select active 40 man players, with org and primary position, names, and fill in the default initial values
bp_persons = session_write.query(Bp_people_search).filter( Bp_people_search.active==True, Bp_people_search.on_40 == True)

entry_season = 2020

pitchers = bp_persons.filter(Bp_people_search.position=='P').all() 
new_entries = []
for row in pitchers:
    new_entry = {}
    new_entry['bpid'] = row.bpid
    new_entry['fullname'] = row.full_name
    new_entry['shortname'] = row.boxscore_name
    new_entry['primary_pos'] = 1
    new_entry['org_id'] = row.org_id
    new_entry['year'] = entry_season
    new_entry['gs_pct'] = 0
    new_entry['ip_gs'] = 0
    new_entry['rp_ip_pct'] = 0
    new_entry['saves_pct'] = 0
    new_entry['updated_timestamp'] = datetime.now()  
    new_entry['user_id'] = 1

    new_entries.append(new_entry)

for new_entry in new_entries:
    new_row = Od_depth_charts_pitchers(**new_entry)
    session_ondeck.add(new_row)

session_ondeck.commit()

batters = bp_persons.filter(Bp_people_search.position != 'P').all()
new_entries = []
for row in batters:
    new_entry = {}
    new_entry['bpid'] = row.bpid
    new_entry['fullname'] = row.full_name
    new_entry['shortname'] = row.boxscore_name

    if  row.position == 'DH':
        new_entry['primary_pos'] = 10
    elif row.position == 'RF':
        new_entry['primary_pos'] = 9
    elif row.position == 'CF':
        new_entry['primary_pos'] = 8
    elif row.position == 'LF':
        new_entry['primary_pos'] = 7
    elif row.position == 'SS':
        new_entry['primary_pos'] = 6
    elif row.position == '3B':
        new_entry['primary_pos'] = 5
    elif row.position == '2B':
        new_entry['primary_pos'] = 4
    elif row.position == '1B':
        new_entry['primary_pos'] = 3
    elif row.position == 'C':
        new_entry['primary_pos'] = 2
    elif row.position == 'P':
        new_entry['primary_pos'] = 1
    else:
        new_entry['primary_pos'] = 10
    
    new_entry['org_id'] = row.org_id
    new_entry['year'] = entry_season
    new_entry['pt_c'] = 0
    new_entry['pt_1b'] = 0
    new_entry['pt_2b'] = 0
    new_entry['pt_3b'] = 0
    new_entry['pt_ss'] = 0
    new_entry['pt_lf'] = 0
    new_entry['pt_cf'] = 0
    new_entry['pt_rf'] = 0
    new_entry['pt_dh'] = 0
    new_entry['pt_ph'] = 0
    new_entry['updated_timestamp'] = datetime.now()  
    new_entry['user_id'] = 1
    new_entries.append(new_entry)



for new_entry in new_entries:
    new_row = Od_depth_charts_batters(**new_entry)
    session_ondeck.add(new_row)

session_ondeck.commit()
#two way players need to be figured out :/