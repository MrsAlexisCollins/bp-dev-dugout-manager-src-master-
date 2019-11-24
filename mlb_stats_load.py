from dugout_manager.read import session_read  
from dugout_manager.write import session_write
from dugout_manager.mapping import Mlb_stats_catching, Mlb_stats_fielding, Mlb_stats_hitting, Mlb_stats_pitching, Bp_stats_catching, Bp_stats_fielding, Bp_stats_hitting, Bp_stats_pitching
from sqlalchemy import func
from datetime import datetime

######### TO DO dupe management

mlb_stats_hitting = session_read.query(Mlb_stats_hitting).limit(1)

for row in mlb_stats_hitting:
    print(row)