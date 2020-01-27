from dugout_manager.connectors.cage import engine_cage #cage bound 
import pandas

players_url ='http://www.scoresheet.com/FOR_WWW/BL_Players_2020.tsv'
players_tdl = pandas.read_table(players_url)
new_columns = [column.replace(' ', '_').lower() for column in players_tdl] 
players_tdl.columns = new_columns

players_tdl.to_sql("scoresheet_players",engine_cage,schema='ingest',if_exists='append',index=False)
 