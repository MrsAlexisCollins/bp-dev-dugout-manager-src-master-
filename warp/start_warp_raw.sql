drop materialized view if exists legacy_models.start_warp_raw;
create materialized view if not exists legacy_models.start_warp_raw as
select 
	season, level_id
	--, SQRT(SUM(POWER(t.RA_START-s.RA_START,2)*t.IP_START)/SUM(t.IP_START)) AS RA_START_SD
	, stddev((t.RA_START-s.RA_START)) as ra_start_sd
	--, SQRT(SUM(POWER(t.RA_RELIEF-s.RA_RELIEF,2)*t.IP_RELIEF)/SUM(t.IP_RELIEF)) AS RA_RELIEF_SD
	, stddev(t.RA_RELIEF-s.RA_RELIEF) as ra_relief_sd
	--, SQRT(SUM(POWER((s.RA_START/9*t.IP_START)-(t.RA_START/9*t.IP_START),2)*t.IP_START)/SUM(t.IP_START)) AS PR_START_SD
	, stddev((s.RA_START/9*t.IP_START)-(t.RA_START/9*t.IP_START)) as pr_start_sd
	--, SQRT(SUM(POWER((s.RA_RELIEF/9*t.IP_RELIEF)-(t.RA_RELIEF/9*t.IP_RELIEF),2)*t.IP_RELIEF)/SUM(t.IP_RELIEF)) AS PR_RELIEF_SD
	, stddev((s.RA_RELIEF/9*t.IP_RELIEF)-(t.RA_RELIEF/9*t.IP_RELIEF)) as pr_relief_sd
--	, (SUM(POWER((s.RA_START/9*t.IP_START)-(t.RA_START/9*t.IP_START),2)*t.IP_START)/SUM(t.IP_START))
--		/((SUM(POWER((s.RA_START/9*t.IP_START)-(t.RA_START/9*t.IP_START),2)*t.IP_START)/SUM(t.IP_START))
--	 	+(SUM(POWER((s.RA_RELIEF/9*t.IP_RELIEF)-(t.RA_RELIEF/9*t.IP_RELIEF),2)*t.IP_RELIEF)/SUM(t.IP_RELIEF))) AS START_WARP_RT	
	, variance((s.RA_START/9*t.IP_START)-(t.RA_START/9*t.IP_START)) / (variance((s.RA_START/9*t.IP_START)-(t.RA_START/9*t.IP_START))+variance((s.RA_RELIEF/9*t.IP_RELIEF)-(t.RA_RELIEF/9*t.IP_RELIEF))) as start_warp_rt
from legacy_models.ip_split_team t
join legacy_models.ip_split_lg2 s using (season, level_id, league)
group by season, level_id
;

grant select on legacy_models.start_warp_raw to PUBLIC;
grant all privileges on legacy_models.start_warp_raw to models;
