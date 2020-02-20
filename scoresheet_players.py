from dugout_manager.connectors.cage import engine_cage, session_cage  
from dugout_manager.connectors.dugout import session_dugout
from dugout_manager.cage_models import Scoresheet_players, Mlb_people, Bp_xref
from dugout_manager.dugout_models import  Stats_scoresheet_players
import pandas


players_url ='http://www.scoresheet.com/FOR_WWW/BL_Players_2020.tsv'
players_tdl = pandas.read_table(players_url)

print("Fetched Scoresheet Players")

new_columns = [column.replace(' ', '_').lower() for column in players_tdl] 
players_tdl.columns = new_columns



session_cage.query(Scoresheet_players).delete() 
session_cage.commit() # commit the delete from above

players_tdl.to_sql("scoresheet_players",engine_cage,schema='ingest',if_exists='append',index=False)

print("Saved to cage")
## now to copy to dugout

session_dugout.query(Stats_scoresheet_players).delete() 


scoresheet_players = session_cage.query(Scoresheet_players).join(Mlb_people, Bp_xref).all()

for row in scoresheet_players:
    new_entry = {}
    for xref in row.people.bpxref:
        new_entry['bpid'] =  xref.bpid 
    new_entry['ssbb'] = row.ssbb
    new_entry['nl'] = row.nl
    new_entry['pos'] = row.pos
    new_entry['h'] = row.h
    new_entry['b1'] = row.b1
    new_entry['b2'] = row.b2
    new_entry['b3'] = row.b3
    new_entry['ss'] = row.ss
    new_entry['of'] = row.of
    new_entry['osbal'] = row.osbal
    new_entry['ocsal'] = row.ocsal
    new_entry['osbnl'] = row.osbnl
    new_entry['ocsnl'] = row.ocsnl
    new_entry['bavr'] = row.bavr
    new_entry['obvr'] = row.obvr
    new_entry['slvr'] = row.slvr
    new_entry['bavl'] = row.bavl
    new_entry['obvl'] = row.obvl
    new_entry['slvl'] = row.slvl

    new_row = Stats_scoresheet_players(**new_entry)
    session_dugout.add(new_row) 



session_dugout.commit()


print("Saved to dugout")