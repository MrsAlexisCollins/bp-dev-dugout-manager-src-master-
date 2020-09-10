CREATE MATERIALIZED VIEW models.re AS (select
        count(*) as N,
        t.season,
        t.level_id,
        t.outs_pre,
        t.onfirst_pre,
        t.onsecond_pre,
        t.onthird_pre,
        avg(t.runs_expected)
from (
        select
                p.game_pk,
                p.event_type,
                b.event_index_end,
                p.description,
                p.at_bat_index,
        --      p.outs,
        --      p.post_on_first_id,
        --      p.post_on_second_id,
        --      p.post_on_third_id,
                b.outs_pre_window as outs_pre,
                b.away_score_pre,
                b.home_score_pre,
                case when (b.firstbase_pre is null) then false else true end as onfirst_pre,
                case when (b.secondbase_pre is null) then false else true end as onsecond_pre,
                case when (b.thirdbase_pre is null) then false else true end as onthird_pre,
        --      b.firstbase_pre,
        --      b.secondbase_pre,
        --      b.thirdbase_pre,
        --      b.outs_end_window,
                pe.away_score,
                pe.home_score,
                i.away_score,
                i.home_score,
                case when p.half_inning = 'top' then (i.away_score - b.away_score_pre) else (i.home_score - b.home_score_pre) end as runs_expected,
                case when p.half_inning = 'top' then gs.away_team else gs.home_team end as batting_team,
                gs.venue,
                gs.season,
                gs.level_id
        from mlbapi.plays p
        join (
            select distinct
                    bo.game_pk,
                    bo.at_bat_index,
                    last_value(event_index) over (
                        partition by game_pk, at_bat_index
                        order by event_index
                        range between unbounded preceding and unbounded following
                    ) as event_index_end,
                    last_value(outs_pre) over (
                        partition by game_pk, at_bat_index
                        order by event_index
                        range between unbounded preceding and unbounded following
                    ) as outs_pre_window,
                    last_value(away_score_pre) over (
                        partition by game_pk, at_bat_index
                        order by event_index
                        range between unbounded preceding and unbounded following
                    ) as away_score_pre,
                    last_value(home_score_pre) over (
                        partition by game_pk, at_bat_index
                        order by event_index
                        range between unbounded preceding and unbounded following
                    ) as home_score_pre,
                    last_value(firstbase_pre) over (
                        partition by game_pk, at_bat_index
                        order by event_index
                        range between unbounded preceding and unbounded following
                    ) as firstbase_pre,
                    last_value(secondbase_pre) over (
                        partition by game_pk, at_bat_index
                        order by event_index
                        range between unbounded preceding and unbounded following
                    ) as secondbase_pre,
                    last_value(thirdbase_pre) over (
                        partition by game_pk, at_bat_index
                        order by event_index
                        range between unbounded preceding and unbounded following
                    ) as thirdbase_pre,
                    last_value(outs_post) over (
                        partition by game_pk, at_bat_index
                        order by event_index
                        range between unbounded preceding and unbounded following
                    ) as outs_post_window,
                    last_value(firstbase_post) over (
                        partition by game_pk, at_bat_index
                        order by event_index
                        range between unbounded preceding and unbounded following
                    ) as firstbase_post,
                    last_value(secondbase_post) over (
                        partition by game_pk, at_bat_index
                        order by event_index
                        range between unbounded preceding and unbounded following
                    ) as secondbase_post,
                    last_value(thirdbase_post) over (
                        partition by game_pk, at_bat_index
                        order by event_index
                        range between unbounded preceding and unbounded following
                    ) as thirdbase_post,
                    last_value(outs_end) over (
                        partition by game_pk, at_bat_index
                        order by event_index
                        range between unbounded preceding and unbounded following
                    ) as outs_end_window,
                    last_value(firstbase_end) over (
                        partition by game_pk, at_bat_index
                        order by event_index
                        range between unbounded preceding and unbounded following
                    ) as firstbase_end,
                    last_value(secondbase_end) over (
                        partition by game_pk, at_bat_index
                        order by event_index
                        range between unbounded preceding and unbounded following
                    ) as secondbase_end,
                    last_value(thirdbase_end) over (
                        partition by game_pk, at_bat_index
                        order by event_index
                        range between unbounded preceding and unbounded following
                    ) as thirdbase_end
            from mlbapi.baseout bo
        ) b
        on p.game_pk = b.game_pk
                and p.at_bat_index = b.at_bat_index
        join mlbapi.play_events pe
        on p.game_pk = pe.game_pk
                and p.at_bat_index = pe.at_bat_index
                and b.event_index_end = pe.event_index
        join (
            select
                    i.game_pk,
                    i.inning_no,
                    sum(i.away_runs) over (partition by i.game_pk order by i.inning_no) as away_score,
                    sum(i.home_runs) over (partition by i.game_pk order by i.inning_no) as home_score
            from mlbapi.innings i
            ) i
        on p.game_pk = i.game_pk
                and p.inning = i.inning_no
        join mlbapi.games_schedule gs
        on p.game_pk = gs.game_pk
        join (
            select distinct gs.season, gs.level_id, 
                p.game_pk, p.inning, p.half_inning 
                from cage.mlbapi.plays p 
                inner join cage.mlbapi.games_schedule_deduped gs using (game_pk)
                where 
                    p.outs = 3 and (p.inning < 9 or p.half_inning = 'top')
                    and gs.game_type = 'R' and left(gs.status_code, 1) = 'F'
        ) c
        on p.game_pk = c.game_pk and p.inning = c.inning 
            and p.half_inning = c.half_inning
        where gs.game_type = 'R' and left(gs.status_code, 1) = 'F' 
            and c.game_pk is not null
) t
where t.outs_pre in (0, 1, 2)
group by t.season, t.level_id, t.outs_pre, 
        t.onfirst_pre, t.onsecond_pre, t.onthird_pre
order by t.season, t.level_id, t.outs_pre, 
        t.onfirst_pre, t.onsecond_pre, t.onthird_pre
);
