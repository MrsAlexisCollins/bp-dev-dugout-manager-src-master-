
from dugout_manager.connectors.dugout import session_dugout
from dugout_manager.connectors.ondeck import session_ondeck
from dugout_manager.ondeck_models import Od_depth_charts_batters, Od_depth_charts_pitchers
from dugout_manager.dugout_models import  Bp_pecota_depthcharts_pitchers, Bp_pecota_depthcharts_batters
from sqlalchemy import func
from datetime import datetime


### read in existing work from admins
dc_batters = session_ondeck.query(Od_depth_charts_batters) 

# clear the dugout
pecota_depthcharts_batters = session_dugout.query(Bp_pecota_depthcharts_batters) 
pecota_depthcharts_batters.delete() 
#build new entries
new_entries = []
for row in dc_batters:
	new_entry = {}
	new_entry['bpid'] =  row.bpid
	new_entry['org_id'] = row.org_id
	new_entry['season'] =  row.year
	new_entry['pt_c'] =  row.pt_c
	new_entry['pt_1b'] =  row.pt_1b
	new_entry['pt_2b'] =  row.pt_2b
	new_entry['pt_3b'] =  row.pt_3b
	new_entry['pt_ss'] =  row.pt_ss
	new_entry['pt_lf'] =  row.pt_lf
	new_entry['pt_cf'] =  row.pt_cf
	new_entry['pt_rf'] =  row.pt_rf
	new_entry['pt_dh'] =  row.pt_dh
	new_entry['pt_ph'] =  row.pt_ph
	new_entries.append(new_entry)


for new_entry in new_entries:
	new_row = Bp_pecota_depthcharts_batters(**new_entry)
	session_dugout.add(new_row)

session_dugout.commit()

### read in existing work from admins
dc_pitchers = session_ondeck.query(Od_depth_charts_pitchers) 
# clear the dugout
pecota_depthcharts_pitchers = session_dugout.query(Bp_pecota_depthcharts_pitchers) 
pecota_depthcharts_pitchers.delete() 
#build new entries
new_entries = []
for row in dc_pitchers:
	new_entry = {}
	new_entry['bpid'] =  row.bpid
	new_entry['org_id'] = row.org_id
	new_entry['season'] =  row.year
	new_entry['gs_pct'] =  row.gs_pct
	new_entry['sp_role'] =  row.sp_role
	new_entry['ip_gs'] =  row.ip_gs
	new_entry['rp_ip_pct'] =  row.rp_ip_pct
	new_entry['rp_role'] =  row.rp_role
	new_entry['saves_pct'] =  row.saves_pct
	new_entries.append(new_entry)



for new_entry in new_entries:
	new_row = Bp_pecota_depthcharts_pitchers(**new_entry)
	session_dugout.add(new_row)

session_dugout.commit()