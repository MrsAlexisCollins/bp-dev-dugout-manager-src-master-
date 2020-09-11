drop materialized view if exists legacy_models.rep_level_pitching;
create materialized view legacy_models.rep_level_pitching as
with rep_level as (
select 
	season, level_id, league
	, g, pa, rpg, rpw
	, rpg/2.0 as ra
	, ip_start
	, ip_relief
	, start_warp_rt
	, rwin 
	, win
	, (.5 - rwin) * g as warp
	, (win - rwin) * g as adj_warp
	, (g * .5 - ((.5 - rwin) * g) * def_warp_pct) / g as pwin
	, ((g * ip_split) * .5 - (((.5 - rwin) * g) * def_warp_pct * start_warp_rt)) / (g * ip_split) as pwin_start
	, ((g * (1 - ip_split)) * .5 - (((.5 - rwin) * g) * def_warp_pct * start_warp_rt)) / (g * (1 - ip_split)) as pwin_relief 
	, (g * .5 - ((win - rwin) * g) * def_warp_pct) / g as adj_pwin
	, ((g * ip_split) *.5 - (((win - rwin) * g) * def_warp_pct * start_warp_rt)) / (g * ip_split) as adj_pwin_start
	, ((g * (1 - ip_split)) *.5 - (((win - rwin) * g) * def_warp_pct * start_warp_rt)) / (g * (1 - ip_split)) as adj_pwin_relief
from (
	select distinct
		season
		, level_id
		, league
		--, gs.home_team
		, avg(sum(p.wins+losses)) over (partition by season, level_id, league) as g
		, avg(sum(p.batters_faced)) over (partition by season, level_id, league) as pa
	from mlbapi.stats_pitching p
	join mlbapi.games_schedule_deduped gs using (game_pk)
	join mlbapi.teams t  on gs.home_team = t.id
	where gs.game_type = 'R' 
	and left(gs.status_code, 1) = 'F'
	and games_pitched >= games_started
	and gs.level_id = 1
	group by season
		, level_id
		, league
		, gs.home_team
	) g
join legacy_models.lwts_runs_per_win_bylg using (season, level_id, league)
join legacy_models.start_warp_rolling using (season, level_id)
join legacy_models.ip_split_lg2 using (season, level_id, league)
join legacy_models.warp_sd using (season, level_id)
join (select distinct
			season
			, 0.0502 * ln(season - 1870) + .0803 as rwin 
			, 0.0686 * ln(season - 1870) + .17 as win
			, 1 - off_warp_pct as def_warp_pct
		from legacy_models.warp_sd) win using (season)
)
select 
	*
	, power(-(power(ra, 1.8) * (pwin - 1)) / pwin, 1/1.8) as rep_ra
	, power(-(power(ra, 1.8) * (pwin_start - 1)) / pwin_start, 1/1.8) as rep_ra_start
	, power(-(power(ra, 1.8) * (pwin_start - 1)) / pwin_start, 1/1.8) / ra as rep_ra_start_idx
	, power(-(power(ra, 1.8) * (pwin_relief - 1)) / pwin_relief, 1/1.8) as rep_ra_relief
	, power(-(power(ra, 1.8) * (pwin_relief - 1)) / pwin_relief, 1/1.8) / ra as rep_ra_relief_idx
	, power(-(power(ra, 1.8) * (adj_pwin - 1)) / adj_pwin, 1/1.8) as adj_rep_ra
	, power(-(power(ra, 1.8) * (adj_pwin_start - 1)) / adj_pwin_start, 1/1.8) as adj_rep_ra_start
	, power(-(power(ra, 1.8) * (adj_pwin_start - 1)) / adj_pwin_start, 1/1.8) / ra as adj_rep_ra_start_idx
	, power(-(power(ra, 1.8) * (adj_pwin_relief - 1)) / adj_pwin_relief, 1/1.8) as adj_rep_ra_relief
	, power(-(power(ra, 1.8) * (adj_pwin_relief - 1)) / adj_pwin_relief, 1/1.8) / ra as adj_rep_ra_relief_idx
from rep_level;

grant select on legacy_models.rep_level_pitching to PUBLIC;
grant all privileges on legacy_models.rep_level_pitching to models;
