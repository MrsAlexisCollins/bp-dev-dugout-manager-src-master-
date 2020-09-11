create table if not exists models.dra_warp (
	season			int,
	comp_date		int,
	bpid			float8,
	dra_final		float8,
	dra_minus		float8,
	cfip			float8,
	ip				float8,
	dra_pwarp		float8,
	dra_pwarp_sd	float8,
	dra_runs_saved	float8,
	primary key (season, comp_date, bpid)	
);

insert into models.dra_warp
select 
	year as season
	, comp_date, bpid
	--, full_name
	, "DRA_final" as dra_final
	--, "DRA_SD"
	, "DRA_minus" as dra_minus
	, "cFIP" as cfip
	, "IP" as ip
	, (rep_ra - "DRA_final") * "IP" / 9.0 / rpw as dra_pwarp
	, abs((rep_ra - "DRA_final") - (rep_ra - ("DRA_final" + "DRA_SD"))) * "IP" / 9.0 / rpw as dra_pwarp_sd
	, (rep_ra - "DRA_final") * "IP" / 9.0 as dra_runs_saved
from models.dra_daily dra
join (select year, max(comp_date) as comp_date from models.dra_daily group by year) mx using (year, comp_date)
join (	
		select 
			season, level_id
			, sum(rep_ra * pa) / sum(pa) as rep_ra
			, sum(rpw * g)/ sum(g) as rpw
		from legacy_models.rep_level_pitching 
		group by season, level_id) rep on dra.year = rep.season and (dra.lvl = 'mlb' and level_id = 1)
--join mlbapi.people_search ps using (bpid)
;

grant select on models.dra_pwarp to PUBLIC;
