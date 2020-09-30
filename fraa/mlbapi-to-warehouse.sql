drop table if exists mlbapi.event_types_retrosheet;

create table if not exists mlbapi.event_types_retrosheet (
	event_type		text,
	event_cd		int,
	primary key (event_type)
);

insert into mlbapi.event_types_retrosheet (event_type, event_cd) values
	('field_out', 2)
	,('force_out'	,2)
	,('grounded_into_double_play'	,2)
	,('grounded_into_triple_play'	,2)
	,('sac_fly'	,2)
	,('sac_fly_double_play'	,2)
	,('triple_play'	,2)
	,('double_play'	,2)
	,('sac_bunt'	,2)
	,('sac_bunt_double_play' 	,2)
	,('strike_out'	,3)
	,('strikeout'	,3)
	,('strikeout_double_play'	,3)
	,('strikeout_triple_play' 	,3)
	,('stolen_base_2b'	,4)
	,('stolen_base_3b'	,4)
	,('stolen_base_home' 	,4)
	,('defensive_indiff' 	,5)
	,('caught_stealing_1b'	,6)
	,('caught_stealing_2b'	,6)
	,('caught_stealing_3b'	,6)
	,('caught_stealing_home'	,6)
	,('cs_double_play'	,6)
	,('runner_double_play' 	,6)
	,('pickoff_error_1b'	,7)
	,('pickoff_error_2b'	,7)
	,('pickoff_error_3b' 	,7)
	,('pickoff_1b'	,8)
	,('pickoff_2b'	,8)
	,('pickoff_3b'	,8)
	,('pickoff_caught_stealing_1b'	,8)
	,('pickoff_caught_stealing_2b'	,8)
	,('pickoff_caught_stealing_3b'	,8)
	,('pickoff_caught_stealing_home' 	,8)
	,('wild_pitch' 	,9)
	,('passed_ball' 	,10)
	,('balk' 	,11)
	,('other_advance'	,12)
	,('other_out' 	,12)
	,('walk' 	,14)
	,('intent_walk' 	,15)
	,('hit_by_pitch' 	,16)
	,('catcher_interf'	,17)
	,('batter_interference'	,17)
	,('runner_interference'	,17)
	,('fan_interference' 	,17)
	,('error'	,18)
	,('field_error' 	,18)
	,('fielders_choice'	,19)
	,('fielders_choice_out' 	,19)
	,('single' 	,20)
	,('double' 	,21)
	,('triple' 	,22)
	,('home_run' 	,23)
;


drop materialized view if exists mlbapi.warehouse_events
;
create materialized view mlbapi.warehouse_events as

select distinct
	gs.season, gs.level_id, gs.game_type
	, gs.game_pk
	, p.at_bat_index as event_id
	, gs.away_team 
	, gs.home_team 
	, case half_inning when 'top' then gs.home_team else gs.away_team end as fld_team
	, case
        when p.event_type = 'fan_interference' then etr_br.event_cd
        when p.event_type = 'field_error' 
          and c.credit = 'f_error_dropped_ball' then 2
        when p.event_type = 'sac_bunt' and br.is_out = 'f' then
          case when c.credit = 'f_fielding_error' 
                 or c.credit = 'f_throwing_error'
               then 18 
               else 19 -- fielder's choice, typically (always?) f_fielded_ball
          end
        else etr.event_cd
      end as event_cd
	, p.inning as inn_ct
	, case half_inning when 'top' then 0 else 1 end as bat_home_id
	, bo.outs_pre as outs_ct
	, bo.outs_end - bo.outs_pre as event_outs_ct
	, case p.event_type when 'single' then 1 when 'double' then 2 when 'triple' then 3 when 'home_run' then 4 else 0 end as h_cd
	, case when description like '%bunt%' then 1 else 0 end as bunt_fl
	, case trajectory 
        when 'fly_ball' then 'F' 
        when 'ground_ball' then 'G' 
        when 'bunt_grounder' then 'G' 
        when 'popup' then 'P' 
        when 'bunt_popup' then 'P' 
        when 'line_drive' then 'L' 
        when 'bunt_line_drive' then 'L' 
        else null 
      end as battedball_cd
	, p.batter_id
	, p.bat_side as bat_hand_cd
	, p.pitcher_id
	, p.pitch_hand as pit_hand_cd
	, catcher_id as pos2_fld_id
	, firstbaseman_id as pos3_fld_id
	, secondbaseman_id as pos4_fld_id
	, thirdbaseman_id as pos5_fld_id
	, shortstop_id as pos6_fld_id
	, leftfielder_id as pos7_fld_id
	, centerfielder_id as pos8_fld_id
	, rightfielder_id as pos9_fld_id
	, case when firstbase_pre is not null then 1 else 0 end 
		+ case when secondbase_pre is not null then 2 else 0 end 
		+ case when thirdbase_pre is not null then 4 else 0 end as startbases_cd
	, case when firstbase_end is not null then 1 else 0 end 
		+ case when secondbase_end is not null then 2 else 0 end 
		+ case when thirdbase_end is not null then 4 else 0 end as endbases_cd
	, case half_inning when 'top' then bo.away_score_end - bo.away_score_pre else bo.home_score_end - home_score_pre end as event_runs_ct
	, coalesce(is_pitcher_hitting, 0) as is_pitcher_hitting	--not perfect here
	, case when p.event_type in ('strike_out','strikeout') then '0' else 
		coalesce((select code from mlbapi.positions where abbrev = fl.fld_cd), '0')
	end as fld_cd	--first fielder. On strikeouts, MLB logs C as putout fielder, Retrosheet logs 0
	, coalesce((select code from mlbapi.positions where abbrev = po1_fld_cd), '0') as po1_fld_cd
	, coalesce((select code from mlbapi.positions where abbrev = ass1_fld_cd), '0') as ass1_fld_cd
	, coalesce((select code from mlbapi.positions where abbrev = ass2_fld_cd), '0') as ass2_fld_cd
	, coalesce((select code from mlbapi.positions where abbrev = ass3_fld_cd), '0') as ass3_fld_cd
	, bat_play_tx
	, coalesce(run1.at_bat_index,0) as run1_origin_event_id
	, coalesce(run2.at_bat_index,coalesce(rp.at_bat_index, 0)) as run2_origin_event_id	--this is a event the runner reached 2nd, not got on base originally (which is what Retrosheet does)
	, coalesce(run3.at_bat_index,0) as run3_origin_event_id
	--, firstbase_pre
	--, secondbase_pre 
--	
from mlbapi.plays p
join mlbapi.games_schedule_deduped gs on p.game_pk = gs.game_pk and left(gs.status_code, 1) = 'F'	--can join to .game_status if you want
join mlbapi.fielders f on p.game_pk = f.game_pk and p.at_bat_index = f.at_bat_index 
left join mlbapi.event_types_retrosheet etr on p.event_type = etr.event_type
left join mlbapi.runners br -- batter runner
  on p.game_pk = br.game_pk and p.at_bat_index = br.at_bat_index
  and br.start_base is null
left join mlbapi.event_types_retrosheet etr_br on br.event_type = etr_br.event_type
left join (
    select distinct on (game_pk, at_bat_index, event_index, runner_index) *
    from mlbapi.credits
    order by game_pk, at_bat_index, event_index, runner_index, 
        credit_index desc
) c on p.game_pk = c.game_pk and p.at_bat_index = c.at_bat_index
  and br.event_index = c.event_index and br.runner_index = c.runner_index
left join (select distinct game_pk, pitcher_id, 1 as is_pitcher_hitting from mlbapi.plays) ph on p.game_pk = ph.game_pk and p.batter_id = ph.pitcher_id --not perfect, if batter pitches later in game...
left join mlbapi.batted_balls bb on p.game_pk = bb.game_pk and p.at_bat_index = bb.at_bat_index and bb.trajectory is not null --does this duplicate a play?
left join (	--gets first fielder, first putout, first assist, second assist, third assist
	select game_pk, at_bat_index
			, max(fld_cd) as fld_cd
			, max(po1_fld_cd) as po1_fld_cd
			, max(ass1_fld_cd) as ass1_fld_cd
			, max(ass2_fld_cd) as ass2_fld_cd
			, max(ass3_fld_cd) as ass3_fld_cd 
		from (
			select 
				game_pk, at_bat_index
				, first_value(position_abbrev) over (partition by game_pk, at_bat_index order by event_index desc, runner_index asc, credit_index asc) as fld_cd
				, first_value(case when credit = 'f_putout' then position_abbrev else null end) over (partition by game_pk, at_bat_index, case when credit = 'f_putout' then 1 else 0 end /* fixes the ignore nulls problem */ order by event_index desc, runner_index asc, credit_index asc) as po1_fld_cd
				, first_value(case when credit = 'f_assist' then position_abbrev else null end) over (partition by game_pk, at_bat_index, case when credit = 'f_assist' then 1 else 0 end /* fixes the ignore nulls problem */ order by event_index desc, runner_index asc, credit_index asc) as ass1_fld_cd			
				, nth_value(case when credit = 'f_assist' then position_abbrev else null end, 2) over (partition by game_pk, at_bat_index, case when credit = 'f_assist' then 1 else 0 end /* fixes the ignore nulls problem */ order by event_index desc, runner_index asc, credit_index asc) as ass2_fld_cd
				, nth_value(case when credit = 'f_assist' then position_abbrev else null end, 3) over (partition by game_pk, at_bat_index, case when credit = 'f_assist' then 1 else 0 end /* fixes the ignore nulls problem */ order by event_index desc, runner_index asc, credit_index asc) as ass3_fld_cd	
			from mlbapi.credits) s
			group by game_pk, at_bat_index
	) fl on p.game_pk = fl.game_pk and p.at_bat_index = fl.at_bat_index
left join (
	select game_pk, at_bat_index
			, --replace(replace(replace(
				string_agg(code, '') as bat_play_tx--, '11', '1'), '66', '6'), '88', '8') 	--is this necessary?
	from mlbapi.credits 
	join mlbapi.positions on position_abbrev = abbrev
	group by game_pk, at_bat_index
	) bp on p.game_pk = bp.game_pk and p.at_bat_index = bp.at_bat_index
left join (	--h/t Cory
	select distinct 
		baseout.game_pk,
		baseout.at_bat_index,
		LAST_VALUE(baseout.event_index) OVER (
			PARTITION BY game_pk, at_bat_index
			ORDER BY event_index
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED following
		) AS event_index_end,
		LAST_VALUE(baseout.outs_pre) OVER (
			PARTITION BY game_pk, at_bat_index
			ORDER BY event_index
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED following
		) AS outs_pre,
		LAST_VALUE(baseout.away_score_pre) OVER (
			PARTITION BY game_pk, at_bat_index
			ORDER BY event_index
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED following
		) AS away_score_pre,
		LAST_VALUE(baseout.home_score_pre) OVER (
			PARTITION BY game_pk, at_bat_index
			ORDER BY event_index
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED following
		) AS home_score_pre,
		LAST_VALUE(baseout.firstbase_pre) OVER (
			PARTITION BY game_pk, at_bat_index
			ORDER BY event_index
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED following
		) AS firstbase_pre,
		LAST_VALUE(baseout.secondbase_pre) OVER (
			PARTITION BY game_pk, at_bat_index
			ORDER BY event_index
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED following
		) AS secondbase_pre,
		LAST_VALUE(baseout.thirdbase_pre) OVER (
			PARTITION BY game_pk, at_bat_index
			ORDER BY event_index
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED following
		) AS thirdbase_pre,
		LAST_VALUE(baseout.outs_end) OVER (
			PARTITION BY game_pk, at_bat_index
			ORDER BY event_index
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED following
		) AS outs_end,
		LAST_VALUE(baseout.away_score_end) OVER (
			PARTITION BY game_pk, at_bat_index
			ORDER BY event_index
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED following
		) AS away_score_end,
		LAST_VALUE(baseout.home_score_end) OVER (
			PARTITION BY game_pk, at_bat_index
			ORDER BY event_index
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED following
		) AS home_score_end,
		LAST_VALUE(baseout.firstbase_end) OVER (
			PARTITION BY game_pk, at_bat_index
			ORDER BY event_index
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED following
		) AS firstbase_end,
		LAST_VALUE(baseout.secondbase_end) OVER (
			PARTITION BY game_pk, at_bat_index
			ORDER BY event_index
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED following
		) AS secondbase_end,
		LAST_VALUE(baseout.thirdbase_end) OVER (
			PARTITION BY game_pk, at_bat_index
			ORDER BY event_index
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED following
		) AS thirdbase_end
	FROM mlbapi.baseout baseout
) bo on p.game_pk = bo.game_pk and p.at_bat_index = bo.at_bat_index 
-- these three might have edge cases in bat-around innings?? could probably fix with at_bat_index in a [-4,4] range instead of <
left join (
	select 
		r.game_pk, r.runner_id, r.end_base, p.inning, min(r.at_bat_index) as at_bat_index	--get the first index where the runner appeared on base
	from mlbapi.runners r
	join mlbapi.plays p using (game_pk, at_bat_index)
	where end_base = '1B'
	group by r.game_pk, r.runner_id, r.end_base, p.inning
	) run1 on p.game_pk = run1.game_pk and run1.runner_id = bo.firstbase_pre and p.inning = run1.inning and run1.at_bat_index < p.at_bat_index 
--
left join (
	select 
		r.game_pk, r.runner_id, r.end_base, p.inning, min(r.at_bat_index) as at_bat_index	--get the first index where the runner appeared on base
	from mlbapi.runners r
	join mlbapi.plays p using (game_pk, at_bat_index)
	where end_base = '2B'
	group by r.game_pk, r.runner_id, r.end_base, p.inning
	) run2 on p.game_pk = run2.game_pk and run2.runner_id = bo.secondbase_pre and p.inning = run2.inning and run2.at_bat_index < p.at_bat_index 
--
left join (
	select 
		r.game_pk, r.runner_id, r.end_base, p.inning, min(r.at_bat_index) as at_bat_index	--get the first index where the runner appeared on base
	from mlbapi.runners r
	join mlbapi.plays p using (game_pk, at_bat_index)
	where end_base = '3B'
	group by r.game_pk, r.runner_id, r.end_base, p.inning
	) run3 on p.game_pk = run3.game_pk and run3.runner_id = bo.thirdbase_pre and p.inning = run3.inning and run3.at_bat_index < p.at_bat_index 
-- for specific extra-inn rule runner on 2b
left join (
	select 
		game_pk, at_bat_index
	from mlbapi.play_events where event_type = 'runner_placed'
) rp on p.game_pk = rp.game_pk and p.at_bat_index = rp.at_bat_index
--
where p.event_type not in ('defensive_switch','game_advisory')
order by game_pk, event_id asc
;

grant select on mlbapi.warehouse_events to PUBLIC;
alter materialized view mlbapi.warehouse_events owner to akoo;
