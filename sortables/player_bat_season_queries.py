# name of table going into dugout
table_name = 'player_bat_season'

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
        , round((date_part('day', concat({season}, '-06-30')::timestamp - birth_date::timestamp)/365.25)::numeric, 0) as age
        , bats
        , throws
    from mlbapi.people_search ps 
    join xrefs.people_refs pr using (bpid)
    where xref_type='mlb'
    ;
"""

query_standard = """
  SELECT
        season, gs.level_id, batter_id as mlbid
        , sum(games_played) as gp
        , sum(plate_appearances) as pa
        , sum(atbats) as ab
        , sum(runs) as r
        , sum(rbi) as rbi
        , sum(hits) as h
        , sum(doubles) as b2
        , sum(triples) as b3
        , sum(homeruns) as hr
        , sum(total_bases) as tb
        , sum(strikeouts) as so
        , sum(base_on_balls) as bb
        , sum(intentional_walks) as ibb
        , sum(hit_by_pitch) as hbp
        , sum(stolen_bases) as sb
        , sum(caught_stealing) as cs
        , sum(stolen_bases) / nullif(sum(stolen_bases+caught_stealing), 0)::float as sb_success
        , sum(flyouts) as flyouts
        , sum(groundouts) as groundouts
        , sum(ground_into_double_play) as gidp
        , sum(ground_into_triple_play) as gitp
        , sum(left_on_base) as lob
        , sum(sac_bunts) as s
        , sum(sac_flies) as sf
        , sum(catchers_interference) as ci
        , sum(pickoffs) as pickoffs
        , sum(hits) / nullif(sum(atbats), 0)::float as avg
        , sum(hits+base_on_balls+hit_by_pitch) / nullif(sum(atbats+base_on_balls+hit_by_pitch+sac_flies), 0)::float as obp
        , sum(total_bases) / nullif(sum(atbats), 0)::float as slg
        , sum(hits+base_on_balls+hit_by_pitch) / nullif(sum(atbats+base_on_balls+hit_by_pitch+sac_flies), 0)::float + sum(total_bases) / nullif(sum(atbats), 0)::float as ops
        , sum(total_bases-hits) / nullif(sum(atbats), 0)::float as iso
        , sum(hits-homeruns) / nullif(sum(atbats-homeruns-strikeouts+sac_flies),0)::float as babip
        , sum(base_on_balls) / nullif(sum(plate_appearances), 0)::float as bbr
        , sum(strikeouts) / nullif(sum(plate_appearances), 0)::float as sor
  from mlbapi.stats_batting b
  join mlbapi.games_schedule_deduped gs on b.game_pk = gs.game_pk
  where game_type = 'R' and left(status_code, 1) = 'F' 
  and season = {season}
  and level_id = {level_id}
  group by season, level_id, batter_id
  ;
"""

query_bb = """
    SELECT
        season, level_id
        , batter_id as mlbid
        --, count(distinct game_pk) as g
        --, count(*) as pa
        , count(trajectory) as bip
        , sum(case when trajectory = 'ground_ball' then 1 else 0 end) as gb
        , sum(case when trajectory = 'fly_ball' then 1 else 0 end) as fb
        , sum(case when trajectory = 'line_drive' then 1 else 0 end) as ld
        , sum(case when trajectory = 'popup' then 1 else 0 end) as po 
        , sum(case when trajectory in ('bunt_grounder','bunt_popup','bunt_line_drive') then 1 else 0 end) as bunt
        , sum(case when trajectory in ('bunt_grounder','bunt_popup','bunt_line_drive') and p.event_type in ('single','double','triple','home_run') then 1 else 0 end) as bunt_hit           
        , sum(case when trajectory = 'ground_ball' then 1.0 else 0.0 end) / nullif(count(trajectory),0)::float as gbr
        , sum(case when trajectory = 'fly_ball' then 1.0 else 0.0 end) / nullif(count(trajectory),0)::float as fbr 
        , sum(case when trajectory = 'line_drive' then 1.0 else 0.0 end) / nullif(count(trajectory),0)::float as ldr
        , sum(case when trajectory = 'popup' then 1.0 else 0.0 end) / nullif(count(trajectory),0)::float as por    
        , sum(case when trajectory in ('bunt_grounder','bunt_popup','bunt_line_drive') then 1.0 else 0.0 end) / nullif(count(trajectory),0)::float as buntr    
        , sum(case when p.event_type = 'home_run' and trajectory = 'fly_ball' then 1 else 0 end) / nullif(sum(case when trajectory = 'fly_ball' then 1.0 else 0.0 end), 0)::float as hr_per_fb
    from mlbapi.plays p
    join mlbapi.games_schedule_deduped gsd using (game_pk)
    join mlbapi.event_types_retrosheet etr using (event_type)
    left join (select distinct on (game_pk, at_bat_index, trajectory, hardness) * from mlbapi.batted_balls bb) b using (game_pk, at_bat_index)
    where game_type = 'R' and left(status_code, 1) = 'F'
    and etr.event_cd not in (4,5,6,7,8,9,10,11,12,13,99)
    and season = {season} and level_id = {level_id}
    group by season, level_id, batter_id
    ;
"""

query_zone = """

"""

query_field = """
    SELECT 
        season, level_id
        , id as mlbid
        , sum(ip_full + ip_part) as innings
        , sum(errors) as errors 
        , sum(throwing_errors) as errors_throwing
        , coalesce(sum(games) filter (where position = 'C'), 0) as g_c
        , coalesce(sum(games) filter (where position = '1B'), 0) as g_1b
        , coalesce(sum(games) filter (where position = '2B'), 0) as g_2b
        , coalesce(sum(games) filter (where position = '3B'), 0) as g_3b
        , coalesce(sum(games) filter (where position = 'SS'), 0) as g_ss
        , coalesce(sum(games) filter (where position = 'LF'), 0) as g_lf
        , coalesce(sum(games) filter (where position = 'CF'), 0) as g_cf
        , coalesce(sum(games) filter (where position = 'RF'), 0) as g_rf
        , coalesce(sum(games) filter (where position = 'DH'), 0) as g_dh
        , coalesce(sum(games) filter (where position = 'P'), 0) as g_p
        , coalesce(sum(ip_full + ip_part) filter (where position = 'C'), 0) as ip_c
        , coalesce(sum(ip_full + ip_part) filter (where position = '1B'), 0) as ip_1b
        , coalesce(sum(ip_full + ip_part) filter (where position = '2B'), 0) as ip_2b
        , coalesce(sum(ip_full + ip_part) filter (where position = '3B'), 0) as ip_3b
        , coalesce(sum(ip_full + ip_part) filter (where position = 'SS'), 0) as ip_ss
        , coalesce(sum(ip_full + ip_part) filter (where position = 'LF'), 0) as ip_lf
        , coalesce(sum(ip_full + ip_part) filter (where position = 'CF'), 0) as ip_cf
        , coalesce(sum(ip_full + ip_part) filter (where position = 'RF'), 0) as ip_rf
        , coalesce(sum(ip_full + ip_part) filter (where position = 'DH'), 0) as ip_dh
        , coalesce(sum(ip_full + ip_part) filter (where position = 'P'), 0) as ip_p
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

query_field_pa = """
    SELECT 
        season, level_id, mlbid 
        , count(*) filter (where position = 'C') as PA_c
        , count(*) filter (where position = '1B') as PA_1b
        , count(*) filter (where position = '2B') as PA_2b
        , count(*) filter (where position = '3B') as PA_3b
        , count(*) filter (where position = 'SS') as PA_ss
        , count(*) filter (where position = 'LF') as PA_lf
        , count(*) filter (where position = 'CF') as PA_cf
        , count(*) filter (where position = 'RF') as PA_rf
        , count(*) filter (where position = 'DH') as PA_dh
        , count(*) filter (where position = 'P') as PA_p
    from (
        select
            season, level_id
            , unnest(array['P', 'C', '1B', '2B', '3B', 'SS', 'LF', 'CF', 'RF', 'DH']) as position
            , unnest(array[f.pitcher_id, catcher_id, firstbaseman_id, secondbaseman_id, thirdbaseman_id, shortstop_id, leftfielder_id, centerfielder_id, rightfielder_id, designatedhitter_id]) as mlbid
        from mlbapi.plays p
        join mlbapi.fielders f using (game_pk, at_bat_index)
        join mlbapi.games_schedule_deduped gsd using (game_pk)
        join mlbapi.event_types_retrosheet etr using (event_type)
        where game_type = 'R' and left(status_code, 1) = 'F'
        and etr.event_cd not in (4,5,6,7,8,9,10,11,12,13,99)
        and season = {season} and level_id = {level_id}
    ) s
    where mlbid is not null --lost dh
    group by season, level_id, mlbid
    ;
"""

query_brr = """
    SELECT distinct on (season, level_id, d.bpid)
        season, level_id
        , xref_id::int as mlbid
        , brr_opps, brr, sbr_opps, sbr, har_opps, har, gar_opps, gar, aar_opps, aar, oar_opps, oar
    from models.brr_daily d
    join xrefs.people_refs pr on d.bpid = pr.bpid and xref_type='mlb'
    where season = {season} and level_id = {level_id}
    order by season, level_id, d.bpid, version desc
"""

query_opp = """
    SELECT 
        season, level_id, batter_id as mlbid, avg(dra_minus) as opp_dra_minus
    from mlbapi.warehouse_events we
    join (
        SELECT distinct on (season, level_id, d.bpid)
                season, level_id
                , xref_id::int as pitcher_id
                , dra_minus
        from models.dra_warp d
        join xrefs.people_refs pr on d.bpid = pr.bpid and xref_type='mlb'
        where season = {season} and level_id = {level_id}
        order by season, level_id, d.bpid, comp_date desc
    ) d using (season, level_id, pitcher_id)
    where event_cd not in (4,5,6,7,8,9,10,11,12,13,99)
    group by season, level_id, batter_id
"""

query_warp = """
    SELECT distinct on (season, level_id, d.bpid) 
        season, level_id
        , xref_id::int as mlbid
        , drc_warp
        , draa + pos_adj + brr + brr_arm + rep_level as bvorp
        , draa, brr_arm, fraa, ofa, cda, pos_adj, rep_level
        --, brr --above
         --, rpw, version
    from models.drc_warp d
    join xrefs.people_refs pr on d.bpid = pr.bpid and xref_type='mlb'
    where season = {season} and level_id = {level_id}
    order by season, level_id, d.bpid, version desc;
"""

query_drc = """
    SELECT distinct on (year, lvl, d.bpid)
        year as season
        , l.id as level_id
        , xref_id::int as mlbid
        , "dRC_plus" as drc_plus
        , "dRC_SD" as drc_sd
        --, "dRAA" as drc_raa
        --, comp_date 
    from models.drc_daily d
    join mlbapi.levels l on d.lvl = l.code
    join xrefs.people_refs pr on d.bpid = pr.bpid and xref_type='mlb'
    where year = {season} and l.id = {level_id}
    order by year, lvl, d.bpid, comp_date desc
"""

queries = [query_standard
            , query_bb
            , query_field
            , query_field_pa
            , query_brr
            , query_opp
            , query_warp
            , query_drc
        ]
