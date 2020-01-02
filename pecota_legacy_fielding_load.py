from dugout_manager.connectors.read import session_read  
from dugout_manager.connectors.write import session_write
from dugout_manager.cage_models import Pecota_fielder_binomials, Pecota_of_assists
from dugout_manager.dugout_models import Bp_pecota_fielder_binomials, Bp_pecota_of_assists
from sqlalchemy import func 


pecota_raw = session_read.query(Pecota_fielder_binomials).all()
session_write.query(Bp_pecota_fielder_binomials).delete()  

for row in pecota_raw:
	new_entry = {}
	new_entry['bpid'] =  int(row.fld_id)
	new_entry['season']  = int(row.year_proj)
	new_entry['years'] = row.years
	new_entry['position'] = row.pos
	new_entry['ch'] = row.ch
	new_entry['ch_weighted'] =row.ch_weighted
	new_entry['pm_rt_var'] = row.pm_rt_var
	new_entry['pm_rt'] = row.pm_rt
	new_entry['pm_rt_lg'] = row.pm_rt_lg
	new_entry['pm_rt_raw'] = row.pm_rt_raw

	new_row = Bp_pecota_fielder_binomials(**new_entry)
	session_write.add(new_row) 

session_write.commit()




pecota_raw = session_read.query(Pecota_of_assists).all()
session_write.query(Bp_pecota_of_assists).delete()  

for row in pecota_raw:
	new_entry = {}
	new_entry['bpid'] =  int(row.fld_id)
	new_entry['season'] = int(row.year_proj)
	new_entry['years'] = row.years
	new_entry['position'] = row.pos
	new_entry['z'] = row.z
	new_entry['z_reg'] =row.z_reg
	new_entry['ast_rt_mlb'] = row.ast_rt_mlb
	new_entry['ast150'] = row.ast150
	new_entry['mlb_ast_rt'] = row.mlb_ast_rt
	new_entry['mlb_sd_rt'] = row.mlb_sd_rt
	new_entry['runs_per_ast'] = row.runs_per_ast
	new_entry['runs_per_g'] = row.runs_per_g
	new_entry['of_ass'] = row.of_ass
	new_entry['g_of'] = row.g_of
	new_entry['ast_rt'] = row.ast_rt
	new_entry['ast_rt_lg'] = row.ast_rt_lg
	new_entry['ast_sd_lg'] = row.ast_sd_lg
	new_entry['g_of_adj'] = row.g_of_adj
	new_entry['g_of_lg_adj'] = row.g_of_lg_adj

	new_row = Bp_pecota_of_assists(**new_entry)
	session_write.add(new_row) 

session_write.commit()

