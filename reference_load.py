from dugout_manager.connectors.read import session_read  
from dugout_manager.connectors.write import session_write
from dugout_manager.cage_models import  Pectoa_ref_bat_events_by_lineup,  Pectoa_ref_dyna_lg_pos_batting_stats, Pectoa_ref_pitcher_league_pos
from dugout_manager.dugout_models import  Ref_batter_events_league_lineup, Ref_batting_stats_league_position, Ref_pitching_stats_league_position
from sqlalchemy import func
from datetime import datetime

batting_events_by_lineup_cage = session_read.query(Pectoa_ref_bat_events_by_lineup).all()

batting_stats_by_position_cage = session_read.query(Pectoa_ref_dyna_lg_pos_batting_stats).all()

pitching_stats_by_position_cage = session_read.query(Pectoa_ref_pitcher_league_pos).all()