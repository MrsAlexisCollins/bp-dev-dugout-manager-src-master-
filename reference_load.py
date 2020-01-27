from dugout_manager.connectors.cage import session_cage  
from dugout_manager.connectors.dugout import session_dugout
from dugout_manager.cage_models import  Pecota_ref_bat_events_by_lineup,  Pecota_ref_dyna_lg_pos_batting_stats, Pecota_ref_pitcher_league_pos
from dugout_manager.dugout_models import Bp_leagues,  Bp_levels,  Ref_batter_events_league_lineup, Ref_batting_stats_league_position, Ref_pitching_stats_league_position
from sqlalchemy import func
from datetime import datetime

bp_leagues = session_dugout.query(Bp_leagues)
bp_levels = session_dugout.query(Bp_levels)

### requires tabulation
batting_events_by_lineup_cage = session_cage.query(Pecota_ref_bat_events_by_lineup).all()

new_entries = [] 
for row in batting_events_by_lineup_cage:
    new_entry = {}
    new_entry['season']=row.year_id
    new_entry['league_id']= bp_leagues.filter(Bp_leagues.league_name==row.lg).first().league_id
    new_entry['lineup_slot']=row.bat_lineup_id
    new_entry['pa']=row.pa
    new_entry['outs']=row.outs
    new_entry['ab']=row.ab
    new_entry['h']=row.h
    new_entry['b1']=row.b1
    new_entry['b2']=row.b2
    new_entry['b3']=row.b3
    new_entry['hr']=row.hr
    new_entry['tb']=row.tb
    new_entry['bb']=row.bb
    new_entry['ubb']=row.ubb
    new_entry['ibb']=row.ibb
    new_entry['hbp']=row.hbp
    new_entry['sf']=row.sf
    new_entry['sh']=row.sh
    new_entry['roe']=row.roe
    new_entry['rbi']=row.rbi
    new_entry['dp']=row.dp
    new_entry['tp']=row.tp
    new_entry['wp']=row.wp
    new_entry['pb']=row.pb
    new_entry['so']=row.so
    new_entry['bk']=row.bk
    new_entry['interference']=row.interference
    new_entry['fc']=row.fc
    new_entry['tob']=row.tob
    new_entry['sit_dp']=row.sit_dp
    new_entry['gidp']=row.gidp
    new_entry['pitches']=row.pitches
    new_entry['strikes']=row.strikes
    new_entry['balls']=row.balls
    new_entry['fb']=row.fb
    new_entry['gb']=row.gb
    new_entry['linedr']=row.linedr
    new_entry['popup']=row.popup
    new_entry['batted_ball_type_known']=row.batted_ball_type_known
    new_entry['sf_op']=row.sf_op
    new_entry['sh_op']=row.sh_op
    new_entry['dp_op']=row.dp_op
    new_entry['tp_op']=row.tp_op

    

    new_entries.append(new_entry)


for entry in new_entries:
    new_row = Ref_batter_events_league_lineup(**entry)
    session_dugout.add(new_row)







batting_stats_by_position_cage = session_cage.query(Pecota_ref_dyna_lg_pos_batting_stats).filter(Pecota_ref_dyna_lg_pos_batting_stats.lvl=='mlb').all()

new_entries = [] 
for row in batting_stats_by_position_cage:
    new_entry = {}
    new_entry['season']=row.year
    new_entry['level_id']= bp_levels.filter(Bp_levels.level_name==row.lvl).first().level_id
    new_entry['league_id'] = bp_leagues.filter(Bp_leagues.league_name==row.lg).first().league_id
    new_entry['pos']=row.pos
    new_entry['g']=row.g
    new_entry['pa']=row.pa
    new_entry['ab']=row.ab
    new_entry['h']=row.h
    new_entry['b1']=row.b1
    new_entry['b2']=row.b2
    new_entry['b3']=row.b3
    new_entry['hr']=row.hr
    new_entry['tb']=row.tb
    new_entry['bb']=row.bb
    new_entry['ubb']=row.ubb
    new_entry['ibb']=row.ibb
    new_entry['hbp']=row.hbp
    new_entry['sf']=row.sf
    new_entry['sh']=row.sh
    new_entry['roe']=row.roe
    new_entry['rbi']=row.rbi
    new_entry['leadoff_pa']=row.leadoff_pa
    new_entry['dp']=row.dp
    new_entry['tp']=row.tp
    new_entry['wp']=row.wp
    new_entry['pb']=row.pb
    new_entry['end_game']=row.end_game
    new_entry['no_event']=row.no_event
    new_entry['gen_out']=row.gen_out
    new_entry['so']=row.so
    new_entry['bk']=row.bk
    new_entry['interference']=row.interference
    new_entry['fc']=row.fc
    new_entry['tob']=row.tob
    new_entry['obppa']=row.obppa
    new_entry['missing_play']=row.missing_play
    new_entry['outs']=row.outs
    new_entry['sit_dp']=row.sit_dp
    new_entry['gidp']=row.gidp
    new_entry['pitches']=row.pitches
    new_entry['strikes']=row.strikes
    new_entry['balls']=row.balls
    new_entry['fb']=row.fb
    new_entry['gb']=row.gb
    new_entry['linedr']=row.linedr
    new_entry['popup']=row.popup
    new_entry['batted_ball_type_known']=row.batted_ball_type_known
    new_entry['pa_p']=row.pa_p
    new_entry['pa_c']=row.pa_c
    new_entry['pa_1b']=row.pa_1b
    new_entry['pa_2b']=row.pa_2b
    new_entry['pa_3b']=row.pa_3b
    new_entry['pa_ss']=row.pa_ss
    new_entry['pa_lf']=row.pa_lf
    new_entry['pa_cf']=row.pa_cf
    new_entry['pa_rf']=row.pa_rf
    new_entry['pa_dh']=row.pa_dh
    new_entry['pa_ph']=row.pa_ph
    new_entry['pa_pr']=row.pa_pr
    new_entry['g_p']=row.g_p
    new_entry['g_c']=row.g_c
    new_entry['g_1b']=row.g_1b
    new_entry['g_2b']=row.g_2b
    new_entry['g_3b']=row.g_3b
    new_entry['g_ss']=row.g_ss
    new_entry['g_lf']=row.g_lf
    new_entry['g_cf']=row.g_cf
    new_entry['g_rf']=row.g_rf
    new_entry['g_of']=row.g_of
    new_entry['g_dh']=row.g_dh
    new_entry['g_ph']=row.g_ph
    new_entry['g_pr']=row.g_pr
    new_entry['sb']=row.sb
    new_entry['cs']=row.cs
    new_entry['pickoff']=row.pickoff
    new_entry['r']=row.r
    new_entry['grp_id']=row.grp_id
    new_entry['grp_year']=row.grp_year
    new_entry['grp_lg']=row.grp_lg
    new_entry['grp_team']=row.grp_team
    new_entry['grp_batter']=row.grp_batter
    new_entry['grp_gameid']=row.grp_gameid
    new_entry['grp_pos']=row.grp_pos
    new_entry['avg']=row.avg
    new_entry['obp']=row.obp
    new_entry['slg']=row.slg
    new_entry['ops']=row.ops
    new_entry['iso']=row.iso
    new_entry['tbp']=row.tbp
    new_entry['bbr']=row.bbr
    new_entry['ubbr']=row.ubbr
    new_entry['ibbr']=row.ibbr
    new_entry['so_bb']=row.so_bb
    new_entry['abr']=row.abr
    new_entry['hitr']=row.hitr
    new_entry['b1r']=row.b1r
    new_entry['b2r']=row.b2r
    new_entry['b3r']=row.b3r
    new_entry['hrr']=row.hrr
    new_entry['hbpr']=row.hbpr
    new_entry['sfr']=row.sfr
    new_entry['shr']=row.shr
    new_entry['roer']=row.roer
    new_entry['gen_outr']=row.gen_outr
    new_entry['sor']=row.sor
    new_entry['outr']=row.outr
    new_entry['nsor']=row.nsor
    new_entry['rbir']=row.rbir
    new_entry['leadoffr']=row.leadoffr
    new_entry['end_gamer']=row.end_gamer
    new_entry['dp_percent']=row.dp_percent
    new_entry['fb_percent']=row.fb_percent
    new_entry['gb_percent']=row.gb_percent
    new_entry['linedr_percent']=row.linedr_percent
    new_entry['popup_percent']=row.popup_percent
    new_entry['sb_percent']=row.sb_percent
    new_entry['runr']=row.runr
    new_entry['tav']=row.tav

    new_entries.append(new_entry)


for entry in new_entries:
    new_row = Ref_batting_stats_league_position(**entry)
    session_dugout.add(new_row)






pitching_stats_by_position_cage = session_cage.query(Pecota_ref_pitcher_league_pos).all()

new_entries = [] 
for row in pitching_stats_by_position_cage:
    new_entry = {}
    new_entry['season'] = row.year
    if row.pit_start_fl == 'T':
        new_entry['starters'] = True
    else:
        new_entry['starters'] = False
    new_entry['league_id'] = bp_leagues.filter(Bp_leagues.league_name==row.lg).first().league_id
    new_entry['ip_start'] = row.ip_start
    new_entry['ip_relief'] = row.ip_relief
    new_entry['outs'] = row.outs
    new_entry['r'] = row.r
    new_entry['er'] = row.er
    new_entry['pa'] = row.pa
    new_entry['ab'] = row.ab
    new_entry['h'] = row.h
    new_entry['b1'] = row.b1
    new_entry['b2'] = row.b2
    new_entry['b3'] = row.b3
    new_entry['hr'] = row.hr
    new_entry['tb'] = row.tb
    new_entry['bb'] = row.bb
    new_entry['ubb'] = row.ubb
    new_entry['ibb'] = row.ibb
    new_entry['hbp'] = row.hbp
    new_entry['sf'] = row.sf
    new_entry['sh'] = row.sh
    new_entry['roe'] = row.roe
    new_entry['rbi'] = row.rbi
    new_entry['dp'] = row.dp
    new_entry['tp'] = row.tp
    new_entry['wp'] = row.wp
    new_entry['pb'] = row.pb
    new_entry['so'] = row.so
    new_entry['bk'] = row.bk
    new_entry['interference'] = row.interference
    new_entry['fc'] = row.fc
    new_entry['tob'] = row.tob
    new_entry['sit_dp'] = row.sit_dp
    new_entry['gidp'] = row.gidp
    new_entry['pitches'] = row.pitches
    new_entry['strikes'] = row.strikes
    new_entry['balls'] = row.balls
    new_entry['fb'] = row.fb
    new_entry['gb'] = row.gb
    new_entry['linedr'] = row.linedr
    new_entry['popup'] = row.popup
    new_entry['batted_ball_type_known'] = row.batted_ball_type_known
    new_entry['inh_runners'] = row.inh_runners
    new_entry['runs_charged_during_app'] = row.runs_charged_during_app
    new_entry['inh_runners_scored'] = row.inh_runners_scored
    new_entry['inh_score'] = row.inh_score
    new_entry['beq_resp_runners'] = row.beq_resp_runners
    new_entry['beq_runners'] = row.beq_runners
    new_entry['beq_scored'] = row.beq_scored
    new_entry['winp'] = row.winp
    new_entry['relp'] = row.relp
    new_entry['babip'] = row.babip
    new_entry['def_eff'] = row.def_eff
    new_entry['era'] = row.era
    new_entry['ra'] = row.ra
    new_entry['ura'] = row.ura
    new_entry['h_ip'] = row.h_ip
    new_entry['bb_ip'] = row.bb_ip
    new_entry['so_ip'] = row.so_ip
    new_entry['hr_ip'] = row.hr_ip
    new_entry['whip'] = row.whip
    new_entry['h9'] = row.h9
    new_entry['bb9'] = row.bb9
    new_entry['so9'] = row.so9
    new_entry['hr9'] = row.hr9
    new_entry['br9'] = row.br9
    new_entry['avg'] = row.avg
    new_entry['obp'] = row.obp
    new_entry['slg'] = row.slg
    new_entry['iso'] = row.iso
    new_entry['tbp'] = row.tbp
    new_entry['bbr'] = row.bbr
    new_entry['ubbr'] = row.ubbr
    new_entry['ibbr'] = row.ibbr
    new_entry['so_bb'] = row.so_bb
    new_entry['hitr'] = row.hitr
    new_entry['b1r'] = row.b1r
    new_entry['b2r'] = row.b2r
    new_entry['b3r'] = row.b3r
    new_entry['hrr'] = row.hrr
    new_entry['hbpr'] = row.hbpr
    new_entry['sfr'] = row.sfr
    new_entry['shr'] = row.shr
    new_entry['roer'] = row.roer
    new_entry['sor'] = row.sor
    new_entry['outr'] = row.outr
    new_entry['nsor'] = row.nsor
    new_entry['rbir'] = row.rbir
    new_entry['runr'] = row.runr
    new_entry['dp_percent'] = row.dp_percent
    new_entry['fb_percent'] = row.fb_percent
    new_entry['gb_percent'] = row.gb_percent
    new_entry['linedr_percent'] = row.linedr_percent
    new_entry['popup_percent'] = row.popup_percent
    new_entries.append(new_entry)


for entry in new_entries:
    new_row = Ref_pitching_stats_league_position(**entry)
    session_dugout.add(new_row)

session_dugout.commit()