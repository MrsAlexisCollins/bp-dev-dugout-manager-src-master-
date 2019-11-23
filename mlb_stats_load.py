from dugout_manager.read import session_read  
from dugout_manager.write import session_write
from dugout_manager.mlb_stats.mapping import Mlb_stats_catching, Mlb_stats_fielding, Mlb_stats_hitting, Mlb_stats_pitching
from sqlalchemy import func
from datetime import datetime

######### TO DO dupe management
mlb_stats_hitting = session_read.query(Mlb_stats_hitting).limit(100)

for row in mlb_stats_hitting:
    print(row)