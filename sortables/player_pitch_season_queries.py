# name of table going into dugout
table_name = 'player_pitch_season'

# give every query these index columns
join_key = ['season','level_id','mlbid']

query_bio = """
    SELECT
        {season} as season
        , {level_id} as level_id
        --, (select abbreviation  from mlbapi.levels where id = {level_id}) as lvl
        , pr.xref_id::int as mlbid
        , bpid
        , full_name as name
        , date_part('day', concat({season}, '-07-01')::timestamp - birth_date::timestamp)/365.25 as age
        , bats
        , throws
    from mlbapi.people_search ps 
    join xrefs.people_refs pr using (bpid)
    where xref_type='mlb'
    ;
"""

query_standard = """
  SELECT
        season, gs.level_id, pitcher_id as mlbid
        , sum(games_played) as g
        , sum(games_pitched) as gp
        , sum(games_started) as gs
        , sum(games_finished) as gf
        , (sum(outs) / 3.0)::float as ip
        --, sum(floor(innings_pitched) + ((innings_pitched - floor(innings_pitched)) * 10/3)) as ip --same thing
        -- as ip_start
        -- as ip_relief
        , sum(batters_faced) as pa
        , sum(atbats) as ab
        , sum(hits) as h
        , sum(doubles) as b2
        , sum(triples) as b3
        , sum(homeruns) as hr
        , sum(hits + doubles + triples * 2 + homeruns * 3) as tb
        , sum(strikeouts) as so
        , sum(base_on_balls) as bb
        , sum(intentional_walks) as ibb
        , sum(hit_by_pitch) as hbp
        , sum(stolen_bases) as sb
        , sum(caught_stealing) as cs
        , sum(stolen_bases) / nullif(sum(stolen_bases+caught_stealing), 0)::float as sb_success
        , sum(airouts) as flyouts
        , sum(groundouts) as groundouts
        --, sum(ground_into_double_play) as gidp
        --, sum(ground_into_triple_play) as gitp
        --, sum(left_on_base) as lob
        , sum(sac_bunts) as s
        , sum(sac_flies) as sf
        , sum(catchers_interference) as ci
        , sum(balls) as balls 
        , sum(strikes) as strikes
        , sum(number_of_pitches) as np
        , sum(strikes) / nullif(sum(number_of_pitches), 0)::float as strike_pct
        , sum(pickoffs) as pickoffs
        , sum(hits) / nullif(sum(atbats), 0)::float as avg
        , sum(hits+base_on_balls+hit_by_pitch) / nullif(sum(atbats+base_on_balls+hit_by_pitch+sac_flies), 0)::float as obp
        , sum(hits + doubles + triples * 2 + homeruns * 3) / nullif(sum(atbats), 0)::float as slg
        , sum(hits+base_on_balls+hit_by_pitch) / nullif(sum(atbats+base_on_balls+hit_by_pitch+sac_flies), 0)::float + sum(hits + doubles + triples * 2 + homeruns * 3) / nullif(sum(atbats), 0)::float as ops
        , sum(doubles + triples * 2 + homeruns * 3) / nullif(sum(atbats), 0)::float as iso
        , sum(hits-homeruns) / nullif(sum(atbats-homeruns-strikeouts+sac_flies),0)::float as babip
        , sum(runs) / nullif((sum(outs) / 27.0), 0)::float as ra9
        , sum(earned_runs) / nullif((sum(outs) / 27.0), 0)::float as era
        , sum(hits+base_on_balls) / nullif((sum(outs) / 3.0), 0)::float as whip
        , sum(hits) / nullif((sum(outs) / 27.0), 0)::float as h9
        , sum(homeruns) / nullif((sum(outs) / 27.0), 0)::float as hr9
        , sum(base_on_balls) / nullif((sum(outs) / 27.0), 0)::float as bb9
        , sum(strikeouts) / nullif((sum(outs) / 27.0), 0)::float as so9
        , sum(base_on_balls-intentional_walks) / nullif(sum(batters_faced-intentional_walks), 0)::float as ubbr
        , sum(base_on_balls) / nullif(sum(batters_faced), 0)::float as bbr
        , sum(strikeouts) / nullif(sum(batters_faced), 0)::float as sor
        , sum(strikeouts) / nullif(sum(base_on_balls), 0)::float as so_per_bb
        , sum(wins) as w 
        , sum(losses) as l
        , sum(saves) as sv
        , sum(save_opportunities) as svo
        , sum(holds) as hld
        , sum(blown_saves) as bsv
        , sum(runs) as r
        , sum(earned_runs) as er
        , sum(complete_games) as cg
        , sum(shutouts) as sho
        , sum(balks) as balks
        , sum(wild_pitches) as wp
        , sum(inherited_runners) as ir
        , sum(inherited_runners_scored) as irs
  from mlbapi.stats_pitching b
  join mlbapi.games_schedule_deduped gs on b.game_pk = gs.game_pk
  where game_type = 'R' and left(status_code, 1) = 'F' 
  and season = {season}
  and level_id = {level_id}
  group by season, level_id, pitcher_id
  having sum(games_played) > 0 --prevents nulls
  ;
"""

query_ip = """
    SELECT 
        season, level_id, pitcher_id as mlbid
        --, count(distinct game_pk) as g 
        --, count(distinct case when pitcher_id = starter then game_pk else null end) as gs
        , sum(case when pitcher_id = starter then event_outs_ct else 0 end)::float / 3.0 as ip_start
        , sum(case when pitcher_id != starter then event_outs_ct else 0 end)::float / 3.0 as ip_relief 
        --, sum(event_outs_ct) / 3.0 as ip
    from (
        select
            season, level_id, game_pk, bat_home_id, pitcher_id 
            , first_value(pitcher_id) over (partition by season, level_id, game_pk, bat_home_id order by at_bat_index asc, event_index asc) as starter
            , event_outs_ct 
        from mlbapi.warehouse_events we 
        where season = {season} and level_id = {level_id}
    ) s
    group by season, level_id, pitcher_id
    ;
"""

query_bb = """
    SELECT
        season, level_id
        , pitcher_id as mlbid
        --, count(distinct game_pk) as g
        --, count(*) as pa
        , count(trajectory)::int as bip
        , sum(case when trajectory = 'ground_ball' then 1 else 0 end)::int as gb
        , sum(case when trajectory = 'fly_ball' then 1 else 0 end)::int as fb
        , sum(case when trajectory = 'line_drive' then 1 else 0 end)::int as ld
        , sum(case when trajectory = 'popup' then 1 else 0 end)::int as po 
        , sum(case when trajectory in ('bunt_grounder','bunt_popup','bunt_line_drive') then 1 else 0 end)::int as bunt
        , sum(case when trajectory in ('bunt_grounder','bunt_popup','bunt_line_drive') and p.event_type in ('single','double','triple','home_run') then 1 else 0 end)::int as bunt_hit    
        , sum(case when trajectory = 'ground_ball' then 1.0 else 0.0 end) / nullif(count(trajectory),0)::float as gbr
        , sum(case when trajectory = 'fly_ball' then 1.0 else 0.0 end) / nullif(count(trajectory),0)::float as fbr 
        , sum(case when trajectory = 'line_drive' then 1.0 else 0.0 end) / nullif(count(trajectory),0)::float as ldr
        , sum(case when trajectory = 'popup' then 1.0 else 0.0 end) / nullif(count(trajectory),0)::float as por    
        , sum(case when trajectory in ('bunt_grounder','bunt_popup','bunt_line_drive') then 1.0 else 0.0 end) / nullif(count(trajectory),0)::float as buntr    
        , sum(case when p.event_type = 'home_run' and trajectory = 'fly_ball' then 1 else 0 end) / nullif(sum(case when trajectory = 'fly_ball' then 1.0 else 0.0 end), 0)::float as hr_per_fb
        , sum(case when p.event_type = 'grounded_into_double_play' then 1 else 0 end)::int as gidp
        , sum(case when p.event_type = 'grounded_into_triple_play' then 1 else 0 end)::int as gitp
    from mlbapi.plays p
    join mlbapi.games_schedule_deduped gsd using (game_pk)
    join mlbapi.event_types_retrosheet etr using (event_type)
    left join (select distinct on (game_pk, at_bat_index, trajectory, hardness) * from mlbapi.batted_balls bb) b using (game_pk, at_bat_index)
    where game_type = 'R' and left(status_code, 1) = 'F'
    and etr.event_cd not in (4,5,6,7,8,9,10,11,12,13,99)
    and season = {season} and level_id = {level_id}
    group by season, level_id, pitcher_id--, bpid
    ;
"""

query_field = """
    SELECT 
        season, level_id
        , id as mlbid
        --, sum(ip_full + ip_part) as innings
        , sum(errors) as errors 
        , sum(throwing_errors) as errors_throwing
        --, coalesce(sum(games) filter (where position = 'P'), 0) as g_p
        --, coalesce(sum(ip_full + ip_part) filter (where position = 'P'), 0) as ip_p
    from ( 
        select distinct on (f.season, f.id, position)
            f.*
            , t.level as level_id
            , floor(innings) as ip_full
            , (innings - floor(innings)) * 10/3 as ip_part
        from mlbapi.stats_ytd_fielding f
        join mlbapi.teams t on f.team = t.id
        where season = {season} and level = {level_id}
        order by f.season, f.id, position, timestamp desc
    ) s
    group by season, level_id, id;
"""

query_sraa = """
    SELECT distinct on (season, l.id, d.bpid)
        season, l.id as level_id
        , pr.xref_id::int as mlbid
        , sraa 
        , sraa_sd
    from models.sraa_pitcher_season_daily d 
    join xrefs.people_refs pr on d.bpid::int = pr.bpid and xref_type='mlb'
    join mlbapi.levels l on d.lvl = l.code
    where season = {season} and l.id = {level_id}
    order by season, l.id, d.bpid, comp_date desc
    ;
"""

query_traa = """
    SELECT distinct on (season, l.id, d.bpid)
        season, l.id as level_id
        , pr.xref_id::int as mlbid
        , traa 
        , traa_sd
    from models.traa_pitcher_season_daily d 
    join xrefs.people_refs pr on d.bpid::int = pr.bpid and xref_type='mlb'
    join mlbapi.levels l on d.lvl = l.code
    where season = {season} and l.id = {level_id}
    order by season, l.id, d.bpid, comp_date desc
    ;
"""

query_opp = """
    SELECT 
        season, level_id, pitcher_id as mlbid, avg(drc_plus) as opp_drc_plus
    from mlbapi.warehouse_events we
    join (
        SELECT distinct on (year, lvl, d.bpid)
            year as season
            , l.id as level_id
            , xref_id::int as batter_id
            , "dRC_plus" as drc_plus
        from models.drc_daily d
        join mlbapi.levels l on d.lvl = l.code
        join xrefs.people_refs pr on d.bpid = pr.bpid and xref_type='mlb'
        where year = {season} and l.id = {level_id}
        order by year, lvl, d.bpid, comp_date desc
    ) d using (season, level_id, batter_id)
    where event_cd not in (4,5,6,7,8,9,10,11,12,13,99)
    group by season, level_id, pitcher_id
    ;
"""

query_warp = """
    SELECT distinct on (season, level_id, d.bpid)
            season, level_id
            , xref_id::int as mlbid
            , dra_final, dra_minus, cfip, dra_pwarp, dra_pwarp_sd, dra_runs_saved
    from models.dra_warp d
    join xrefs.people_refs pr on d.bpid = pr.bpid and xref_type='mlb'
    where season = {season} and level_id = {level_id}
    order by season, level_id, d.bpid, comp_date desc
"""

queries = [query_standard
            , query_ip
            , query_bb
            , query_field
            , query_traa
            , query_sraa
            , query_opp
            , query_warp
        ]