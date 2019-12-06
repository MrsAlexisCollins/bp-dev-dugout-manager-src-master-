from dugout_manager.read import session_read  
from dugout_manager.write import session_write
from dugout_manager.mapping import *
from sqlalchemy import func
from datetime import datetime

DEFAULT_PA = 500
vintage_last = session_write.query(func.max(Bp_pecota_hitting_raw.created_datetime)).scalar() 
vintage_last_judge = session_read.query(func.max(Pecota_raw_batters.vintage)).scalar() 

if vintage_last_judge > vintage_last:
    pecota_raw = session_read.query(Pecota_raw_batters).filter(Pecota_raw_batters.vintage == vintage_last_judge).all()
    session_write.query(Bp_pecota_hitting_raw).delete()   

    for row in pecota_raw:
        new_entry = {}
        new_entry['bpid'] =  int(row.batter)
        new_entry['season']  = int(row.proj_year)
        new_entry['created_datetime'] =  row.vintage 
        new_entry['drc_plus'] = row.proj_dRC_plus
        new_entry['draa_pa'] = row.proj_dRAA_PA * DEFAULT_PA
        new_entry['hr'] = row.HR_proj_pneu * DEFAULT_PA
        new_entry['hr_sd'] = row.HR_proj_pneu_sd * DEFAULT_PA
        new_entry['b3'] = row.B3_proj_pneu * DEFAULT_PA
        new_entry['b3_sd'] = row.B3_proj_pneu_sd * DEFAULT_PA
        new_entry['b2'] = row.B2_proj_pneu * DEFAULT_PA
        new_entry['b2_sd'] = row.B2_proj_pneu_sd * DEFAULT_PA
        new_entry['b1'] = row.B1_proj_pneu * DEFAULT_PA
        new_entry['b1_sd'] = row.B1_proj_pneu_sd * DEFAULT_PA
        new_entry['roe'] = row.ROE_proj_pneu * DEFAULT_PA
        new_entry['roe_sd'] = row.ROE_proj_pneu_sd * DEFAULT_PA
        new_entry['hbp'] = row.HBP_proj_pneu * DEFAULT_PA
        new_entry['hbp_sd'] = row.HBP_proj_pneu_sd * DEFAULT_PA
        new_entry['bb'] = row.BB_proj_pneu * DEFAULT_PA
        new_entry['bb_sd'] = row.BB_proj_pneu_sd * DEFAULT_PA
        new_entry['so'] = row.SO_proj_pneu * DEFAULT_PA
        new_entry['so_sd'] = row.SO_proj_pneu_sd * DEFAULT_PA
        new_entry['gb'] = row.GB_proj_pneu * DEFAULT_PA
        new_entry['gb_sd'] = row.GB_proj_pneu_sd * DEFAULT_PA
        new_entry['out'] = row.OUT_proj_pneu * DEFAULT_PA
        new_row = Bp_pecota_hitting_raw(**new_entry)
        session_write.add(new_row) 


    session_write.commit()