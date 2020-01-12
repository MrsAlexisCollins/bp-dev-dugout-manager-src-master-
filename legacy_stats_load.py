from dugout_manager.connectors.read import session_read  
from dugout_manager.connectors.write import session_write
from dugout_manager.cage_models import  Legacy_batting_daily, Legacy_pitching_daily
from dugout_manager.dugout_models import Stats_legacy_batting_daily, Stats_legacy_pitching_daily
from sqlalchemy import func
from datetime import datetime


batting  = session_read.query(Legacy_batting_daily).filter(Legacy_batting_daily.version_date > '1999-01-01 00:00:00').all()
session_write.query(Stats_legacy_batting_daily).delete()   

for row in batting:
	new_entry = {}
	new_entry['bpid'] =  row.batter
	new_entry['season']  = row.year
	new_entry['level_name'] = row.lvl
	new_entry['team_name'] = row.team
	new_entry['version'] = row.version_date
	new_entry['pa'] = row.pa  
	new_entry['drc_plus'] = row.drc_plus 
	new_entry['drc_raa'] = row.drc_raa  
	new_entry['fraa'] = row.fraa 
	new_entry['brr'] = row.brr 
	new_entry['pos_adj'] = row.pos_adj  
	new_entry['rep_level'] = row.rep_level  
	new_entry['drc_warp'] = row.drc_warp 

	new_row = Stats_legacy_batting_daily(**new_entry)
	session_write.add(new_row) 

session_write.commit()

pitching = session_read.query(Legacy_pitching_daily).filter(Legacy_pitching_daily.version_date > '1999-01-01 00:00:00').all()
session_write.query(Stats_legacy_pitching_daily).delete()   

for row in pitching:
	new_entry = {} 
	new_entry['bpid'] =  row.batter
	new_entry['season']  = row.year
	new_entry['level_name'] = row.lvl
	new_entry['team_name'] = row.team
	new_entry['version'] = row.version_date
	new_entry['pa'] = row.pa  
	new_entry['dra'] = row.dra
	new_entry['dra_minus'] = row.dra_minus
	new_entry['cfip'] = row.cfip
	new_entry['dra_pwarp'] = row.dra_pwarp

	new_row = Stats_legacy_pitching_daily(**new_entry)
	session_write.add(new_row) 

session_write.commit()