from dugout_manager.read import session_read  
from dugout_manager.write import session_write
from dugout_manager.mapping import *
from sqlalchemy import func
from datetime import datetime

all_mlb_teams = session_read.query(Mlb_teams)
bp_teams = session_write.query(Bp_teams)
######### TO DO dupe management

mlb_stats_hitting = session_read.query(Mlb_stats_hitting).join(Mlb_people, Bp_xref).all()

for row in mlb_stats_hitting:
    new_entry = {}
    for xref in row.people.bpxref:
        new_entry['bpid'] =  xref.bpid 
    new_entry['season'] = row.season

    new_roster_entry_team = all_mlb_teams.filter(Mlb_teams.id == row.team).first()
    new_roster_entry_team_bp = bp_teams.filter(Bp_teams.team_name ==  new_roster_entry_team.name  ).first()
    if new_roster_entry_team_bp:
        new_entry['team_id'] =  new_roster_entry_team_bp.team_id
    else:
        continue

    new_entry['timestamp'] = row.timestamp
    new_entry['games_played'] = row.games_played
    new_entry['ground_outs'] = row.ground_outs
    new_entry['air_outs'] = row.air_outs
    new_entry['runs'] = row.runs
    new_entry['doubles'] = row.doubles
    new_entry['triples'] = row.triples
    new_entry['home_runs'] = row.home_runs
    new_entry['strike_outs'] = row.strike_outs
    new_entry['base_on_balls'] = row.base_on_balls
    new_entry['intentional_walks'] = row.intentional_walks
    new_entry['hits'] = row.hits
    new_entry['hit_by_pitch'] = row.hit_by_pitch
    new_entry['avg'] = row.avg
    new_entry['at_bats'] = row.at_bats
    new_entry['obp'] = row.obp
    new_entry['slg'] = row.slg
    new_entry['ops'] = row.ops
    new_entry['caught_stealing'] = row.caught_stealing
    new_entry['stolen_bases'] = row.stolen_bases
    new_entry['stolen_base_percentage'] = row.stolen_base_percentage
    new_entry['ground_into_double_play'] = row.ground_into_double_play
    new_entry['number_of_pitches'] = row.number_of_pitches
    new_entry['plate_appearances'] = row.plate_appearances
    new_entry['total_bases'] = row.total_bases
    new_entry['rbi'] = row.rbi
    new_entry['left_on_base'] = row.left_on_base
    new_entry['sac_bunts'] = row.sac_bunts
    new_entry['sac_flies'] = row.sac_flies
    new_entry['babip'] = row.babip
    new_entry['ground_outs_to_airouts'] = row.ground_outs_to_airouts
    new_entry['at_bats_per_home_run'] = row.at_bats_per_home_run

    new_row = Bp_stats_hitting(**new_entry)
    session_write.add(new_row) 

    session_write.commit()