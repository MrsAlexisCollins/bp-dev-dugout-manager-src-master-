
drop MATERIALIZED VIEW stats.pecota_batting_lines  cascade;

CREATE MATERIALIZED VIEW stats.pecota_batting_lines
TABLESPACE pg_default
AS WITH statsline_primer AS (
         SELECT a.sortable_name,
            (b.b1_pa + b.bb_pa + b.hbp_pa + b.roe_pa) * c.sba AS sba_pa,
            (b.b1_pa + b.bb_pa + b.hbp_pa + b.roe_pa) * c.sba * c.sb AS sb_pa,
            (b.b1_pa + b.bb_pa + b.hbp_pa + b.roe_pa) * c.sba - (b.b1_pa + b.bb_pa + b.hbp_pa + b.roe_pa) * c.sba * c.sb AS cs_pa,
            b.on_base_pa AS oba,
            b.total_base_pa / b.ab_pa AS slg,
            b.id,
            b.bpid,
            b.season,
            b.created_datetime,
            b.drc_plus,
            b.draa_pa,
            b.hr_pa,
            b.hr_sd,
            b.b3_pa,
            b.b3_sd,
            b.b2_pa,
            b.b2_sd,
            b.b1_pa,
            b.b1_sd,
            b.roe_pa,
            b.roe_sd,
            b.hbp_pa,
            b.hbp_sd,
            b.bb_pa,
            b.bb_sd,
            b.so_pa,
            b.so_sd,
            b.gb_pa,
            b.gb_sd,
            b.out_pa,
            b.hits_pa,
            b.total_base_pa,
            b.on_base_pa,
            b.ab_pa,
            d.xref_id::integer AS mlbid,
            e.brr_50 / 50::double precision * (b.b1_pa + b.bb_pa + b.hbp_pa + b.roe_pa) AS brr_pa,
            e.brr_50_sd / 50::double precision * (b.b1_pa + b.bb_pa + b.hbp_pa + b.roe_pa) AS brr_pa_sd,
            f."position",
            f.fraa_100,
            f.fraa_100_sd,
            round((700 * (dc.pt_c + dc.pt_1b + dc.pt_2b + dc.pt_3b + dc.pt_ss + dc.pt_lf + dc.pt_cf + dc.pt_rf + dc.pt_dh + dc.pt_ph / 5) / 100)::numeric, 0)::integer AS pa_expected
           FROM entitas.people_search a
             JOIN stats.pecota_hitting_raw b USING (bpid)
             LEFT JOIN stats.pecota_runner_binomials c USING (bpid)
             LEFT JOIN xrefs.people_refs d USING (bpid)
             LEFT JOIN stats.pecota_running_raw e USING (bpid)
             LEFT JOIN stats.pecota_fielding_raw f USING (bpid)
             LEFT JOIN entitas.depth_chart_batters dc USING (bpid)
          WHERE d.xref_type = 'mlb'::text
        )
 SELECT statsline_primer.sortable_name,
    statsline_primer.pa_expected,
    statsline_primer.sba_pa,
    statsline_primer.sb_pa,
    statsline_primer.cs_pa,
    statsline_primer.oba,
    statsline_primer.slg,
    statsline_primer.id,
    statsline_primer.bpid,
    statsline_primer.season,
    statsline_primer.created_datetime,
    statsline_primer.drc_plus,
    statsline_primer.draa_pa,
    statsline_primer.hr_pa,
    statsline_primer.hr_sd,
    statsline_primer.b3_pa,
    statsline_primer.b3_sd,
    statsline_primer.b2_pa,
    statsline_primer.b2_sd,
    statsline_primer.b1_pa,
    statsline_primer.b1_sd,
    statsline_primer.roe_pa,
    statsline_primer.roe_sd,
    statsline_primer.hbp_pa,
    statsline_primer.hbp_sd,
    statsline_primer.bb_pa,
    statsline_primer.bb_sd,
    statsline_primer.so_pa,
    statsline_primer.so_sd,
    statsline_primer.gb_pa,
    statsline_primer.gb_sd,
    statsline_primer.out_pa,
    statsline_primer.hits_pa,
    statsline_primer.total_base_pa,
    statsline_primer.on_base_pa,
    statsline_primer.ab_pa,
    statsline_primer.mlbid,
    statsline_primer.brr_pa,
    statsline_primer.brr_pa_sd,
    statsline_primer."position",
    statsline_primer.fraa_100,
    statsline_primer.fraa_100_sd,
    0.270208::double precision * statsline_primer.oba - 0.0252913::double precision * statsline_primer.slg + 0.0841804::double precision * statsline_primer.sba_pa + 0.00663647::double precision * statsline_primer.sb_pa + statsline_primer.hr_pa AS runs_pa,
    0.0242057::double precision + 0.152508::double precision * statsline_primer.slg - 0.0300806::double precision * statsline_primer.sba_pa + statsline_primer.hr_pa AS rbi_pa
   FROM statsline_primer ;



drop  MATERIALIZED VIEW stats.pecota_batting_lines_park_adj cascade ;

CREATE MATERIALIZED VIEW stats.pecota_batting_lines_park_adj
TABLESPACE pg_default
AS WITH statsline_primer AS (
         SELECT a.sortable_name,
            (b.b1_pa + b.bb_pa + b.hbp_pa + b.roe_pa) * c.sba AS sba_pa,
            (b.b1_pa + b.bb_pa + b.hbp_pa + b.roe_pa) * c.sba * c.sb AS sb_pa,
            (b.b1_pa + b.bb_pa + b.hbp_pa + b.roe_pa) * c.sba - (b.b1_pa + b.bb_pa + b.hbp_pa + b.roe_pa) * c.sba * c.sb AS cs_pa,
            b.on_base_pa AS oba,
            b.total_base_pa / b.ab_pa AS slg,
            b.id,
            b.bpid,
            b.season,
            b.created_datetime,
            b.drc_plus,
            b.draa_pa,
            b.hr_pa,
            b.hr_sd,
            b.b3_pa,
            b.b3_sd,
            b.b2_pa,
            b.b2_sd,
            b.b1_pa,
            b.b1_sd,
            b.roe_pa,
            b.roe_sd,
            b.hbp_pa,
            b.hbp_sd,
            b.bb_pa,
            b.bb_sd,
            b.so_pa,
            b.so_sd,
            b.gb_pa,
            b.gb_sd,
            b.out_pa,
            b.hits_pa,
            b.total_base_pa,
            b.on_base_pa,
            b.ab_pa,
            d.xref_id::integer AS mlbid,
            e.brr_50 / 50::double precision * (b.b1_pa + b.bb_pa + b.hbp_pa + b.roe_pa) AS brr_pa,
            e.brr_50_sd / 50::double precision * (b.b1_pa + b.bb_pa + b.hbp_pa + b.roe_pa) AS brr_pa_sd,
            f."position",
            f.fraa_100,
            f.fraa_100_sd,
            round((700 * (dc.pt_c + dc.pt_1b + dc.pt_2b + dc.pt_3b + dc.pt_ss + dc.pt_lf + dc.pt_cf + dc.pt_rf + dc.pt_dh + dc.pt_ph / 5) / 100)::numeric, 0)::integer AS pa_expected
           FROM entitas.people_search a
             JOIN stats.pecota_hitting_park_adj b USING (bpid)
             LEFT JOIN stats.pecota_runner_binomials c USING (bpid)
             LEFT JOIN xrefs.people_refs d USING (bpid)
             LEFT JOIN stats.pecota_running_raw e USING (bpid)
             LEFT JOIN stats.pecota_fielding_raw f USING (bpid)
             LEFT JOIN entitas.depth_chart_batters dc USING (bpid)
          WHERE d.xref_type = 'mlb'::text
        )
 SELECT statsline_primer.sortable_name,
    statsline_primer.pa_expected,
    statsline_primer.sba_pa,
    statsline_primer.sb_pa,
    statsline_primer.cs_pa,
    statsline_primer.oba,
    statsline_primer.slg,
    statsline_primer.id,
    statsline_primer.bpid,
    statsline_primer.season,
    statsline_primer.created_datetime,
    statsline_primer.drc_plus,
    statsline_primer.draa_pa,
    statsline_primer.hr_pa,
    statsline_primer.hr_sd,
    statsline_primer.b3_pa,
    statsline_primer.b3_sd,
    statsline_primer.b2_pa,
    statsline_primer.b2_sd,
    statsline_primer.b1_pa,
    statsline_primer.b1_sd,
    statsline_primer.roe_pa,
    statsline_primer.roe_sd,
    statsline_primer.hbp_pa,
    statsline_primer.hbp_sd,
    statsline_primer.bb_pa,
    statsline_primer.bb_sd,
    statsline_primer.so_pa,
    statsline_primer.so_sd,
    statsline_primer.gb_pa,
    statsline_primer.gb_sd,
    statsline_primer.out_pa,
    statsline_primer.hits_pa,
    statsline_primer.total_base_pa,
    statsline_primer.on_base_pa,
    statsline_primer.ab_pa,
    statsline_primer.mlbid,
    statsline_primer.brr_pa,
    statsline_primer.brr_pa_sd,
    statsline_primer."position",
    statsline_primer.fraa_100,
    statsline_primer.fraa_100_sd,
    0.270208::double precision * statsline_primer.oba - 0.0252913::double precision * statsline_primer.slg + 0.0841804::double precision * statsline_primer.sba_pa + 0.00663647::double precision * statsline_primer.sb_pa + statsline_primer.hr_pa AS runs_pa,
    0.0242057::double precision + 0.152508::double precision * statsline_primer.slg - 0.0300806::double precision * statsline_primer.sba_pa + statsline_primer.hr_pa AS rbi_pa
   FROM statsline_primer ;



  
 -- no park adjustment required
drop  MATERIALIZED VIEW stats.pecota_pitcher_role_innings_org cascade;
 
CREATE MATERIALIZED VIEW stats.pecota_pitcher_role_innings_org as  
select org_id
,sum(gs_pct) gs 
,round(1.62*sum(gs_pct*ip_gs)) ips
,round(1440 - 1.62*sum(gs_pct*ip_gs)) ipr
from entitas.depth_chart_pitchers group by org_id   ;
 
 

 -- no park adjustment required
CREATE MATERIALIZED VIEW stats.pecota_pitcher_role_innings_player as  
select a.bpid,b.org_id,1.62*gs_pct*ip_gs as IP_SP, ipr*rp_ip_pct/100 as IP_RP
from stats.pecota_pitching_raw a   
join entitas.depth_chart_pitchers b using (bpid)
join stats.pecota_pitcher_role_innings_org c using (org_id);
 


CREATE MATERIALIZED VIEW stats.pecota_team_runs_raw as  
select  org_id,  c.team_name,round( sum(pa_expected*draa_pa) + ((6300 - sum(pa_expected))*-.16 ) +  780 ) as team_runs 
from stats.pecota_batting_lines a 
join entitas.depth_chart_batters  b using (bpid)
join entitas.teams c using   (org_id)
where c.level_id = 1
group by org_id , c.league_id, c.team_name order by  c.league_id,team_runs desc;
 
 


 
CREATE MATERIALIZED VIEW stats.pecota_team_runs_park_adj as  
select  org_id,  c.team_name,round( sum(pa_expected*draa_pa) + ((6300 - sum(pa_expected))*-.16 ) +  780 ) as team_runs 
from stats.pecota_batting_lines_park_adj a 
join entitas.depth_chart_batters  b using (bpid)
join entitas.teams c using   (org_id)
where c.level_id = 1
group by org_id , c.league_id, c.team_name order by  c.league_id,team_runs desc;
 
 

drop  MATERIALIZED VIEW stats.pecota_pitcher_ra cascade;

CREATE MATERIALIZED VIEW stats.pecota_pitcher_ra as  
select a.bpid,
case
when b.league_id = 2 then .97
else 1
end *
(	((a.hbp_pa * c.hbp 
	+ a.bb_pa * c.uibb 
	+ a.so_pa * c.so 
	+ a.hr_pa * c.hr 
	+ a.out_pa* c.bip_out 
	+ a.roe_pa * (c.roe_throw+c.roe_drop)/2 
	+ a.b1_pa * c.b1 
	+ a.b2_pa * c.b2 
	+ a.b3_pa * c.b3 
	+  0.125857 )   
	/
(1-a.hbp_pa-a.bb_pa-a.b1_pa-a.b2_pa-a.b3_pa-a.hr_pa) * 27 ) * .92 )
	as  ra   
from  stats.pecota_pitching_raw a 
join entitas.people_search d on (a.bpid = d.bpid) 
join entitas.teams b using   (org_id), stats.ref_lwts_crosstab c  
where b.level_id = 1;

 


drop  MATERIALIZED VIEW stats.pecota_pitcher_ra_park_adj cascade;

CREATE MATERIALIZED VIEW stats.pecota_pitcher_ra_park_adj as  
select a.bpid,
case
when b.league_id = 2 then .97
else 1
end *
(	((a.hbp_pa * c.hbp 
	+ a.bb_pa * c.uibb 
	+ a.so_pa * c.so 
	+ a.hr_pa * c.hr 
	+ a.out_pa* c.bip_out 
	+ a.roe_pa * (c.roe_throw+c.roe_drop)/2 
	+ a.b1_pa * c.b1 
	+ a.b2_pa * c.b2 
	+ a.b3_pa * c.b3 
	+  0.125857 )   
	/
(1-a.hbp_pa-a.bb_pa-a.b1_pa-a.b2_pa-a.b3_pa-a.hr_pa) * 27 ) * .92 )
	as  ra   
from  stats.pecota_pitching_park_adj a 
join entitas.people_search d on (a.bpid = d.bpid) 
join entitas.teams b using   (org_id), stats.ref_lwts_crosstab c  
where b.level_id = 1;

 



 

CREATE MATERIALIZED VIEW stats.pecota_pitcher_team_ra as  
with first_pass as (
select  org_id,league_id,c.team_name
, sum(ra*ip_sp)/sum(ip_sp)  as sp_ra
, sum(ra*ip_rp )/sum(ip_rp)   as rp_ra
, sum(ip_sp) as  ip_sp
, sum(ip_rp) ip_rp
, team_runs/162 as run_support
from stats.pecota_pitching_raw a 
join stats.pecota_pitcher_role_innings_player b using (bpid) 
join entitas.teams c using   (org_id)
join stats.pecota_pitcher_role_innings_org d using (org_id) 
join stats.pecota_team_runs_raw e using (org_id)
join stats.pecota_pitcher_ra using (bpid)
where c.level_id = 1
group by org_id,league_id,c.team_name,team_runs  )
select org_id,team_name,sp_ra,rp_ra
,(sp_ra*ip_sp/8.888 + rp_ra*ip_rp/8.888)/162 as runs_allowed 
, run_support
, ip_sp
, ip_rp
, ip_sp+ip_rp as ip
from first_pass ;




CREATE MATERIALIZED VIEW stats.pecota_pitcher_team_ra_park_adj as  
with first_pass as (
select  org_id,league_id,c.team_name
, sum(ra*ip_sp)/sum(ip_sp)  as sp_ra
, sum(ra*ip_rp )/sum(ip_rp)   as rp_ra
, sum(ip_sp) as  ip_sp
, sum(ip_rp) ip_rp
, team_runs/162 as run_support
from stats.pecota_pitching_park_adj a 
join stats.pecota_pitcher_role_innings_player b using (bpid) 
join entitas.teams c using   (org_id)
join stats.pecota_pitcher_role_innings_org d using (org_id) 
join stats.pecota_team_runs_park_adj e using (org_id)
join stats.pecota_pitcher_ra_park_adj using (bpid)
where c.level_id = 1
group by org_id,league_id,c.team_name,team_runs  )
select org_id,team_name,sp_ra,rp_ra
,(sp_ra*ip_sp/8.888 + rp_ra*ip_rp/8.888)/162 as runs_allowed 
, run_support
, ip_sp
, ip_rp
, ip_sp+ip_rp as ip
from first_pass ;

CREATE MATERIALIZED VIEW stats.pecota_team_win_exp_01 as  
with get_exp as (select org_id,team_name,runs_allowed,run_support,
 ((run_support + runs_allowed)^0.285) as exp_pat from stats.pecota_pitcher_team_ra)
select org_id, team_name, 162*((run_support^exp_pat)/(run_support^exp_pat + runs_allowed^exp_pat)) as w
from get_exp order by w desc ;

CREATE MATERIALIZED VIEW stats.pecota_team_win_exp_01_park_adj as  
with get_exp as (select org_id,team_name,runs_allowed,run_support,
 ((run_support + runs_allowed)^0.285) as exp_pat from stats.pecota_pitcher_team_ra_park_adj)
select org_id, team_name, 162*((run_support^exp_pat)/(run_support^exp_pat + runs_allowed^exp_pat)) as w
from get_exp order by w desc ;

 
 

CREATE MATERIALIZED VIEW stats.pecota_pitcher_extended_lines as  
with first_pass as (
	with pd_cons as (select  
		1.01 as dra_coeff
		, 1.05 as ipgs_coeff 
		, 0.010 as wpct_offset
		, 0.98 as decisions_ratio 
		, 1.000 as gs_ratio)
		select 
		a.bpid
		, b.org_id
		, a.dra
		, (1.62*d.gs_pct + (b.ip_rp/1.05821890)) as g 
		, 1.62*d.gs_pct as gs
		, (b.ip_rp/1.05821890) as gr 
		, b.ip_sp
		, b.ip_rp
		, (b.ip_sp + b.ip_rp) as ip
			,  decisions_ratio * (0.112603 + d.ip_gs* ipgs_coeff * 0.0839526 + (a.dra* dra_coeff) * 0.0199013) AS decision -- Ratio of decisions by SP
			,  (0.229415 +  wpct_offset + 0.0205924 * d.ip_gs* ipgs_coeff - 0.0602726 * (a.dra* dra_coeff) + 0.0944838 * c.run_support) AS wpct , x.*, d.rp_role, d.sp_role, d.saves_pct
		from pd_cons x, stats.pecota_pitching_raw a 
		join stats.pecota_pitcher_role_innings_player b using (bpid)  
		join stats.pecota_pitcher_team_ra c using (org_id)  
	join entitas.depth_chart_pitchers d using (bpid)
	) 
select a.bpid, a.org_id, a.g, a.gs, a.gr, a.ip_sp, a.ip_rp, a.ip 
,a.gs*a.decision*a.wpct + a.gr* (0.0630654 - (a.dra * a.dra_coeff)*0.00279252) AS w
,a.gs*a.decision * (1-a.wpct) + a.gr * (0.0349775 + (a.DRA* dra_coeff)*0.00341275)	AS l
, a.gs * (0.983255397 - (a.dra * a.dra_coeff)*0.105770277) AS qs
, a.saves_pct/100 *  .48 * b.w as sv
, CASE 
	WHEN a.rp_role = 'cl' THEN .51 * (1-(0.942156295 -(a.DRA* dra_coeff)*0.0224213055601231))
	WHEN a.rp_role = 'su' THEN .12 * (1-(0.5 -(a.DRA* dra_coeff)*0.0224213055601231))
	WHEN a.rp_role = 'mi' THEN .04 * (1-(0.5 -(a.DRA* dra_coeff)*0.0224213055601231))
	ELSE 0
end  * a.ip_rp/1.05821890 as bs
, CASE 
	WHEN a.rp_role = 'cl' THEN a.ip_rp/1.05821890 * (0.049141+(a.DRA* dra_coeff)*0.00440364)
	WHEN a.rp_role = 'su' THEN a.ip_rp/1.05821890 * (0.449241-(a.DRA* dra_coeff)*0.0596005)
	WHEN a.rp_role = 'mi' THEN a.ip_rp/1.05821890 * (0.32615-(a.DRA* dra_coeff)*0.0371148)
	WHEN a.rp_role = 'lg' THEN a.ip_rp/1.05821890 * (0.18513-(a.DRA* dra_coeff)*0.0125247)
	ELSE 0
end as hd
from first_pass a join stats.pecota_team_win_exp_01 b using (org_id);


 
 

CREATE MATERIALIZED VIEW stats.pecota_pitcher_extended_lines_park_adj as  
with first_pass as (
	with pd_cons as (select  
		1.01 as dra_coeff
		, 1.05 as ipgs_coeff 
		, 0.010 as wpct_offset
		, 0.98 as decisions_ratio 
		, 1.000 as gs_ratio)
		select 
		a.bpid
		, b.org_id
		, a.dra
		, (1.62*d.gs_pct + (b.ip_rp/1.05821890)) as g 
		, 1.62*d.gs_pct as gs
		, (b.ip_rp/1.05821890) as gr 
		, b.ip_sp
		, b.ip_rp
		, (b.ip_sp + b.ip_rp) as ip
			,  decisions_ratio * (0.112603 + d.ip_gs* ipgs_coeff * 0.0839526 + (a.dra* dra_coeff) * 0.0199013) AS decision -- Ratio of decisions by SP
			,  (0.229415 +  wpct_offset + 0.0205924 * d.ip_gs* ipgs_coeff - 0.0602726 * (a.dra* dra_coeff) + 0.0944838 * c.run_support) AS wpct , x.*, d.rp_role, d.sp_role, d.saves_pct
		from pd_cons x, stats.pecota_pitching_park_adj a 
		join stats.pecota_pitcher_role_innings_player b using (bpid)  
		join stats.pecota_pitcher_team_ra_park_adj c using (org_id)  
	join entitas.depth_chart_pitchers d using (bpid)
	) 
select a.bpid, a.org_id, a.g, a.gs, a.gr, a.ip_sp, a.ip_rp, a.ip 
,a.gs*a.decision*a.wpct + a.gr* (0.0630654 - (a.dra * a.dra_coeff)*0.00279252) AS w
,a.gs*a.decision * (1-a.wpct) + a.gr * (0.0349775 + (a.DRA* dra_coeff)*0.00341275)	AS l
, a.gs * (0.983255397 - (a.dra * a.dra_coeff)*0.105770277) AS qs
, a.saves_pct/100 *  .48 * b.w as sv
, CASE 
	WHEN a.rp_role = 'cl' THEN .51 * (1-(0.942156295 -(a.DRA* dra_coeff)*0.0224213055601231))
	WHEN a.rp_role = 'su' THEN .12 * (1-(0.5 -(a.DRA* dra_coeff)*0.0224213055601231))
	WHEN a.rp_role = 'mi' THEN .04 * (1-(0.5 -(a.DRA* dra_coeff)*0.0224213055601231))
	ELSE 0
end  * a.ip_rp/1.05821890 as bs
, CASE 
	WHEN a.rp_role = 'cl' THEN a.ip_rp/1.05821890 * (0.049141+(a.DRA* dra_coeff)*0.00440364)
	WHEN a.rp_role = 'su' THEN a.ip_rp/1.05821890 * (0.449241-(a.DRA* dra_coeff)*0.0596005)
	WHEN a.rp_role = 'mi' THEN a.ip_rp/1.05821890 * (0.32615-(a.DRA* dra_coeff)*0.0371148)	WHEN a.rp_role = 'lg' THEN a.ip_rp/1.05821890 * (0.18513-(a.DRA* dra_coeff)*0.0125247)
	ELSE 0
end as hd
from first_pass a join stats.pecota_team_win_exp_01_park_adj b using (org_id);


 

CREATE MATERIALIZED VIEW stats.pecota_pitching_lines as  
select *,  ip*(3/(so_pa+out_pa)) as expected_pa from stats.pecota_pitching_raw a left join stats.pecota_pitcher_extended_lines b using (bpid);
 


CREATE MATERIALIZED VIEW stats.pecota_pitching_lines_park_adj as  
select *,  ip*(3/(so_pa+out_pa)) as expected_pa from stats.pecota_pitching_park_adj a left join stats.pecota_pitcher_extended_lines_park_adj b using (bpid);
 

drop   MATERIALIZED VIEW stats.bp_pecota2020__projected_fielder_position  ;

CREATE MATERIALIZED VIEW stats.bp_pecota2020__projected_fielder_position
as 
with total_def as (
select bpid , (pt_c+pt_1b+pt_2b+pt_3b+pt_ss+pt_lf+pt_cf+pt_rf+pt_dh + pt_ph/5 )::numeric as total_defense_time from  entitas.depth_chart_batters
)
select bpid as fld_id, 2020 as year_proj, pt_c/total_defense_time as PA_RT, 2 as pos  from entitas.depth_chart_batters a join total_def  using (bpid) where pt_c > 0
union
select bpid as fld_id, 2020 as year_proj, pt_1b/total_defense_time as PA_RT, 3 as pos  from entitas.depth_chart_batters a join total_def  using (bpid) where pt_1b > 0
union
select bpid as fld_id, 2020 as year_proj, pt_2b/total_defense_time as PA_RT, 4 as pos  from entitas.depth_chart_batters a join total_def  using (bpid) where pt_2b > 0
union
select bpid as fld_id, 2020 as year_proj, pt_3b/total_defense_time as PA_RT, 5 as pos  from entitas.depth_chart_batters a join total_def  using (bpid) where pt_3b > 0
union
select bpid as fld_id, 2020 as year_proj, pt_ss/total_defense_time as PA_RT, 6 as pos  from entitas.depth_chart_batters a join total_def  using (bpid) where pt_ss > 0
union
select bpid as fld_id, 2020 as year_proj, pt_lf/total_defense_time as PA_RT, 7 as pos  from entitas.depth_chart_batters a join total_def  using (bpid) where pt_lf > 0
union
select bpid as fld_id, 2020 as year_proj, pt_cf/total_defense_time as PA_RT, 8 as pos  from entitas.depth_chart_batters a join total_def  using (bpid) where pt_cf > 0
union
select bpid as fld_id, 2020 as year_proj, pt_rf/total_defense_time as PA_RT, 9 as pos  from entitas.depth_chart_batters a join total_def  using (bpid) where pt_rf > 0
union
select bpid as fld_id, 2020 as year_proj, (pt_ph/5)/total_defense_time as PA_RT, 11 as pos  from entitas.depth_chart_batters a join total_def  using (bpid) where pt_ph > 0
union
select bpid as fld_id, 2020 as year_proj, pt_dh/total_defense_time as PA_RT, 10 as pos  from entitas.depth_chart_batters a join total_def  using (bpid) where pt_dh > 0
order by fld_id
;


create materialized view stats.bp_pfm__dc_pitchers_MOD as (
select 
a.bpid playerid,
2020 as year,
a.bpid as team,
1 pos,
'mlb' as lev,
a.ip as ip,
a.ip as adjip,
b.saves_pct adj_sv,
a.gs,
now() as updated,
b.ip_gs ipgs,
b.rp_ip_pct as rppct,
a.sv as sv,
b.gs_pct as  gspct
from
stats.pecota_pitching_lines_park_adj a 
join
entitas.depth_chart_pitchers b using (bpid)
)
;


create materialized view  stats.bp_pecota2020__dc_hitters_MOD_sum_dupe as    (
select 2020 as year_proj,
bpid as playerid,
pa_expected as pa,
org_id as team
from stats.pecota_batting_lines_park_adj a join entitas.depth_chart_batters b using (bpid))
;

create materialized view stats.bp_pecota2020__pos_adj as (
select f.pos
    , sum(
    	(f.pa_rt*t.pa_expected)
    	*(t.draa_pa+.12)
    	/.12
    )
    /
    sum(f.pa_rt*t.pa_expected)
    as rpa_plus
from 
stats.pecota_batting_lines_park_adj t, 
stats.bp_pecota2020__projected_fielder_position f 
where t.bpid = f.fld_id
and t.season = f.year_proj 
group by pos 
)
;


create materialized view stats.bp_pecota2020__projected_pos_value  as (
select 
c.bpid as bat_id, 
p.year_proj 
, sum(c.pa_expected*p.pa_rt) as pa
, sum(c.pa_expected*p.pa_rt*w.r_pa)-sum(c.pa_expected*p.pa_rt*w.r_pa*o.rpa_plus) as pos_adj
from 
stats.bp_pecota2020__projected_fielder_position p, 
stats.pecota_batting_lines_park_adj c, 
stats.bp_pecota2020__pos_adj o, 
stats.ref_lwts_constants w
where p.fld_id = c.bpid
and p.year_proj = c.season
and p.pos = o.pos
and c.season = w.season + 1
and w.lvl = 'mlb'
group by 
bat_id, year_proj
)
; 
 

 

create materialized view stats.bp_pecota2020__projected_catcher_defense as  (
with cda_runs as 
(select 
-.28 as epaa_rpc,
.15 as csaa_rpc,
.20 as sb_runs_rpc,
-.48 as cs_runs_rpc,
.71 as sbrate)
select c.bpid, c.sortable_name, csaa_proj, epaa_proj, h.traa_proj, h.sraa_proj
, c.pa_expected as pa_tot2
, p.pa_rt as pa_rt2
, c.pa_expected * p.pa_rt as pa_c2
, c.pa_expected * p.pa_rt * 17 * csaa_rpc *h.csaa_proj as csaa_runs  
, c.pa_expected * p.pa_rt * 11 * epaa_rpc * h.epaa_proj as epaa_runs  
, greatest(0, c.pa_expected * p.pa_rt * -3 * ((sb_runs_rpc * (sbrate )) + (cs_runs_rpc * (1-(sbrate ))))  * h.traa_proj) as traa_runs   
, c.pa_expected * p.pa_rt * -(.17+h.traa_proj) *  (sb_runs_rpc - cs_runs_rpc) *h.sraa_proj as sraa_runs   
from cda_runs  
, stats.bp_pecota2020__projected_fielder_position p
join stats.pecota_batting_lines_park_adj c on (p.fld_id = c.bpid  )
left join  stats.pecota_catcher_fraa  h using (bpid)
where  p.pos=2
order by traa_runs desc 
);
 
 

create materialized view  stats.bp_pecota2020__projected_fraa_pos as (
select p.fld_id as bat_id
, p.year_proj
, p.pos
, c.pa_expected *p.pa_rt as pa
, c.pa_expected*p.pa_rt*h.ch_per_pa as ch
,( 
	((coalesce(f.pm_rt,f.pm_rt_lg,l.pm_rt)-coalesce(f.pm_rt_lg,l.pm_rt))*c.pa_expected*p.pa_rt*h.ch_per_pa)*.78
	+ 2.0 * 
	    case  when p.pos between 7 and 9 then ( c.pa_expected*p.pa_rt / 4.0 ) * o.runs_per_g else 0 end
	    + 2.0 * case when p.pos between 7 and 9 then (c.pa_expected*p.pa_rt / 4.0  )
	    * 
	    case when p.pos between 7 and 9 then o.ast_rt_mlb else 0 end * o.runs_per_ast else 0 end 
    + 2.0 * ( coalesce(c2.csaa_runs,0)+coalesce(c2.epaa_runs,0)+coalesce(c2.sraa_runs,0)+coalesce(c2.traa_runs,0) )
)/2
as fraa 
, c.pa_expected as pa_tot
, p.pa_rt
, f.pm_rt,f.pm_rt_lg
from stats.bp_pecota2020__projected_fielder_position  p
join stats.seasonal_fielding_binomials_league l on p.year_proj = l.season + 1 and p.pos = l."position" and 'mlb' = l.level_text
join stats.ch_per_pa_lg h  on p.year_proj = h.year_id + 1 and p.pos = h.pos
join stats.pecota_batting_lines_park_adj c 	on p.fld_id = c.bpid 
left join stats.pecota_fielder_binomials f 	on p.fld_id = f.bpid and p.year_proj = f.season and p.pos = f."position"
left join stats.pecota_of_assists o 	on p.fld_id = o.bpid and p.year_proj = o.season and p.pos = o."position"
left join stats.bp_pecota2020__projected_catcher_defense  c2 	on p.fld_id=c2.bpid and p.pos=2
order by bat_id, pos
); 

create materialized view  stats.bp_pecota2020__projected_fraa as (
select bat_id, year_proj, sum(fraa  ) as fraa
from stats.bp_pecota2020__projected_fraa_pos
group by bat_id, year_proj
);




create materialized view  stats.bp_pecota2020__fraa_text_raw_pecota as (
select year_proj, bat_id, pos, ch
    , rank() OVER (PARTITION BY bat_id ORDER BY ch DESC) as "rank" 
    , fraa 
from stats.bp_pecota2020__projected_fraa_pos 
);
 

drop materialized view  stats.bp_pecota2020__fraa_text_pecota

create materialized view  stats.bp_pecota2020__fraa_text_pecota as 
 (
select a.year_proj, a.bat_id, concat(a.field,
case when b.field is null then '' else ', ' end ,coalesce(b.field,'')) as field
FROM (SELECT year_proj, bat_id, CONCAT((CASE WHEN pos = 1 THEN 'P' WHEN pos = 2 THEN 'C' WHEN pos = 3 THEN '1B' WHEN pos = 4 THEN '2B'
    WHEN pos = 5 THEN '3B' WHEN pos = 6 THEN 'SS' WHEN pos = 7 THEN 'LF' WHEN pos = 8 THEN 'CF' WHEN pos = 9 THEN 'RF' ELSE NULL END),' '
    ,ROUND(fraa)) AS field
FROM STATS.BP_PECOTA2020__FRAA_TEXT_RAW_PECOTA WHERE RANK = 1) A
LEFT JOIN (SELECT year_proj, bat_id, CONCAT((CASE WHEN pos = 1 THEN 'P' WHEN pos = 2 THEN 'C' WHEN pos = 3 THEN '1B' WHEN pos = 4 THEN '2B'
    WHEN pos = 5 THEN '3B' WHEN pos = 6 THEN 'SS' WHEN pos = 7 THEN 'LF' WHEN pos = 8 THEN 'CF' WHEN pos = 9 THEN 'RF' ELSE NULL END),' '
    ,round(fraa)) as field
from stats.bp_pecota2020__fraa_text_raw_pecota where rank = 2) b
on a.year_proj = b.year_proj
and a.bat_id = b.bat_id);


 

drop materialized view stats.bp_pecota2020__pecota_bat_raw

create materialized view stats.bp_pecota2020__pecota_bat_raw as (
select 
 bpid as bat_id
, 2020 as year_id
, x.xref_id  as team 
, case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end  as pa
, round((ab_pa *  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end) ) as ab 
, round((runs_pa *  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end) ) as r
, round((b1_pa *  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end) ) as "1b"
, round((b2_pa *  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end) ) as "2b"
, round((b3_pa *  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end) ) as "3b" 
, round((hr_pa *  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end) ) as hr
, round((rbi_pa *  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end) ) as rbi 
, round((bb_pa *  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end) ) as bb 
, 0 as ibb
, round((hbp_pa *  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end) ) as hbp 
, round((so_pa *  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end)  ) as so 
, round((sb_pa *  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end) ) as sb 
, round((cs_pa *  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end) ) as cs 
, 0 as sh
, 0 as sf 
, 0 as dp
, round((hits_pa/ab_pa)::numeric,3) as "avg"
, round((oba)::numeric,3) as obp 
, round((slg)::numeric,3) as slg
, 0 as tav
, round((((b1_pa *  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end) + (b2_pa *  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end) + (b3_pa *  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end))
      /(  (1 - bb_pa - hbp_pa - so_pa - hr_pa) *  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end))::numeric  ,3) as babip
, round((brr_pa*  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end)::numeric,1) as brr  -- ROUND(@brr := l.SB*0.12380300+l.CS*-0.40688049+l.OBRR,1) AS BRR
, round(coalesce(pos_adj,0)::numeric,1) as pos_adj
, round((.028* case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end)::numeric,1) as rep_adj
, round((draa_pa *  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end)::numeric,1) as raa 
, coalesce(field,'') as fraa 
, round( ( (coalesce( pos_adj ,0)+ .028* case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end  + draa_pa *  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end + (brr_pa*  case when  coalesce(pa_expected,0) = 0 then 251 else pa_expected end) )  )::numeric ,1 ) as vorp
, round( ( (coalesce(fraa,0) + coalesce( pos_adj ,0)+ .028* case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end + draa_pa *  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end 
+ coalesce( (brr_pa*  case when coalesce(pa_expected,0) = 0 then 251 else pa_expected end) ,0) )/( (9.1 + 
w.rpw)/2 )  )::numeric ,1) as warp
, round(coalesce(fraa,0)::numeric,0) as fraa_val
, round(drc_plus::numeric,0) as drc_plus
from  stats.ref_runs_per_win w ,
stats.pecota_batting_lines  -- _park_adj 
join entitas.book_list using (bpid)
join entitas.organizations using (org_id)
join xrefs.org_refs x using (org_id)
left join stats.bp_pecota2020__projected_fraa a on (bpid=bat_id) 
left join stats.bp_pecota2020__fraa_text_pecota b  using (bat_id) 
left join stats.bp_pecota2020__projected_pos_value c   using (bat_id)  
where x.xref_id not in ('ANA','MON') and w.season=2019 and w.lvl='mlb'
order by warp desc
);
 
 grant select on all tables in schema stats to basecoach  ;

select b.full_name,a.* from stats.bp_pecota2020__pecota_bat_raw a join entitas.people_search b on (bat_id=bpid) order by warp desc;
--
--SELECT full_name,  round(fraa) as fraa 
--FROM stats.projected_fraa  a join entitas.people_search b on (bpid=bat_id) order by fraa desc;
--
--select full_name, a.* from 
--stats.bp_pecota2020__projected_catcher_defense  a join entitas.people_search b using (bpid)  

--select a.bpid,e.full_name, a."position", 
--d.fraa_100 * (((pa_rt * d.pa_expected) * c.ch_per_pa)/100) as fraa_proj 
--from stats.pecota_fielding_raw a 
--join stats.bp_pecota2020__projected_fielder_position b on  (bpid=fld_id and pos="position") 
--join stats.ch_per_pa_lg c on ( b.year_proj = c.year_id + 1 and b.pos = c.pos)
--join stats.pecota_batting_lines_park_adj d on (a.bpid=d.bpid)
--join entitas.people_search e on (a.bpid=e.bpid)
--order by fraa_proj desc 

 

REFRESH MATERIALIZED VIEW stats.pecota_batting_lines WITH DATA;  -- raw no park adjust
REFRESH MATERIALIZED VIEW stats.pecota_batting_lines_park_adj  WITH DATA; -- park adjusted!
REFRESH MATERIALIZED VIEW stats.pecota_pitcher_role_innings_org WITH DATA; -- figuring out innings needed by relievers by team
REFRESH MATERIALIZED VIEW stats.pecota_pitcher_role_innings_player WITH DATA; -- handing out those innings
REFRESH MATERIALIZED VIEW stats.pecota_team_runs_raw WITH DATA; --  team offense
REFRESH MATERIALIZED VIEW stats.pecota_team_runs_park_adj WITH DATA; --  team offense
REFRESH MATERIALIZED VIEW stats.pecota_pitcher_ra WITH DATA; --  pitcher runs allowed
REFRESH MATERIALIZED VIEW stats.pecota_pitcher_ra_park_adj WITH DATA; --  pitcher runs allowed
REFRESH MATERIALIZED VIEW stats.pecota_pitcher_team_ra WITH DATA; -- tabulate team runs allowed
REFRESH MATERIALIZED VIEW stats.pecota_pitcher_team_ra_park_adj WITH DATA; -- tabulate team runs allowed
REFRESH MATERIALIZED VIEW stats.pecota_team_win_exp_01 WITH DATA; -- estimated W/L records
REFRESH MATERIALIZED VIEW stats.pecota_team_win_exp_01_park_adj WITH DATA; -- estimated W/L records
REFRESH MATERIALIZED VIEW stats.pecota_pitcher_extended_lines WITH DATA; -- is joined to raw next
REFRESH MATERIALIZED VIEW stats.pecota_pitcher_extended_lines_park_adj WITH DATA; -- is joined to raw next
REFRESH MATERIALIZED VIEW stats.pecota_pitching_lines WITH DATA; -- there we are -- not park adjusted
REFRESH MATERIALIZED VIEW stats.pecota_pitching_lines_park_adj WITH DATA; -- there we are --  
REFRESH MATERIALIZED VIEW stats.bp_pecota2020__projected_fielder_position WITH DATA; -- positional playing time summary
REFRESH MATERIALIZED VIEW stats.bp_pfm__dc_pitchers_MOD WITH DATA; -- playing time summary
REFRESH MATERIALIZED VIEW stats.bp_pecota2020__dc_hitters_MOD_sum_dupe WITH DATA; -- playing time summary
REFRESH MATERIALIZED VIEW stats.bp_pecota2020__pos_adj WITH DATA; -- reference data
REFRESH MATERIALIZED VIEW stats.bp_pecota2020__projected_pos_value WITH DATA; -- this is by player position for our projections/DC
REFRESH MATERIALIZED VIEW stats.bp_pecota2020__projected_catcher_defense WITH DATA; -- fraa runs based on DC
REFRESH MATERIALIZED VIEW stats.bp_pecota2020__projected_fraa_pos WITH DATA; -- by player-position
REFRESH MATERIALIZED VIEW stats.bp_pecota2020__projected_fraa WITH DATA; -- by player
REFRESH MATERIALIZED VIEW stats.bp_pecota2020__fraa_text_raw_pecota WITH DATA; -- by player
REFRESH MATERIALIZED VIEW stats.bp_pecota2020__fraa_text_pecota WITH DATA; -- pretty for books
REFRESH MATERIALIZED VIEW stats.bp_pecota2020__pecota_bat_raw WITH DATA; -- batter final book input lines, currently park neutral

select * from stats.bp_pecota2020__pecota_bat_dc

grant select on all tables in schema stats to pgexport;

-- select pos,round(rpa_plus::numeric,2) from stats.bp_pecota2020__pos_adj order by rpa_plus  

--select (fraa_100*(a.pa_expected*b.ch_per_pa)/100  )
--+ case when p.pos between 7 and 9 then 
--( a.pa_expected*p.pa_rt / 4.0 ) * c.runs_per_g   + (a.pa_expected*p.pa_rt / 4.0  ) * c.ast_rt_mlb  * c.runs_per_ast  
--else 0 end
--as fraa
--,a.bpid,p.pos, 
--a."position",
--a.pa_expected  
--from 
--stats.pecota_batting_lines_park_adj a 
--join stats.bp_pecota2020__projected_fielder_position  p on (a.bpid=p.fld_id and  a.season=p.year_proj)
--join stats.ch_per_pa_lg b on (b.pos=p.pos and b.year_id+1 = a.season) 
--left join stats.pecota_of_assists c on (a.bpid=c.bpid and a.season=c.season and b.pos=c."position")
--where  a.pa_expected > 0
--order by bpid desc;

--select b.full_name,a.fraa  fraa_pos, a.pos,c.fraa_100 as alt_rate  from stats.projected_fraa_pos a join entitas.people_search b on (bpid=bat_id)
--left join stats.pecota_fielding_raw c  using (bpid) where a.pos != 2
--order by fraa desc;



grant all privileges on all tables in schema stats to basecoach;

grant select on all tables in schema stats to pgexport;

grant usage on all sequences in schema stats to basecoach;

--select * from stats.pecota_team_win_exp_01 a join entitas.organizations using (org_id);
--
--select full_name,csaa_proj from stats.pecota_catcher_fraa join entitas.people_search using ( bpid)  order by csaa_proj desc;
--
-- select b.full_name,bpid, 
-- round(a.dra::numeric,2) as dra, 
-- round(dra_minus) as dra_minus, 
-- round(a.cfip) as cfip, 
-- round(a.ip) as ip,
--  round(a.expected_pa) as tbf,
-- round(a.g) as g,
-- round(a.gs) as gs,
-- round(a.qs) as qs,
-- round(a.w) as w,
-- round(a.l) as l,
-- round(a.sv) as sv,
-- round(a.hd) as hd,
-- round(a.bs) as bs,
-- round((a.so_pa * a.expected_pa)::numeric,0) as so,
-- round((a.bb_pa * a.expected_pa)::numeric,0) as bb 
-- from stats.pecota_pitching_lines  a join entitas.people_search b using (bpid) order by a.dra;

--can start this with or without park factors
--1. for each team establish the expected SP and RP inning distribution (DONE sql inning_orgs) [MV: stats.pecota_pitcher_role_innings_org]
--2. assign RP inning totals to players based on their RP% and the team's value from Step 1.   [MV: stats.pecota_pitcher_role_innings_player]
--3. using a baseline 700 PA season, estimate batter PAs based on PT% (DONE in MV)             [MV: stats.pecota_batting_lines]
--4. estimate offense, use for run support                                                     [MV: stats.pecota_team_runs_raw]
--6. estimate team RC and RA [-.16 per pitcher PA]                                             [MV: stats.pecota_pitcher_team_ra]                                   
--7. pyth that into W-L                                                                        [MV: stats.pecota_team_win_exp_01]
--5. build pitching lines                                                                      [MV: stats.pecota_pitching_lines]
--8. fraa
--10. replacement level & positional adjustments 
 
 --bp_book20.pecota_bat20
-- CREATE TABLE tech_rmcquown.`brr_2016_2018` AS 
--SELECT BATTER,NAME
--,SUM(PA) AS PA_TOT
--,SUM(BRR)/SUM(PA) AS '$BRR'
--,SUM(BRR) AS BRR
--,SUM(SB*0.15) AS BRR_SB
--,SUM(CS*-0.43) AS BRR_CS 
--,SUM(brr-SB*0.15-CS*-0.43) AS BRR_OTHER
--,SUM(brr-SB*0.15-CS*-0.43)/SUM(PA) AS '$BRR_OTHER'
--
--

--create table stats.seasonal_fielding_binomials_league   (
--season int4 ,
--level_text	text ,
--"position"	float4 ,
--ch	float4,
--pm_rt	float4
--);

--create table stats.ch_per_pa_lg (
--year_id	int4,
--pos	int4,
--ch_per_pa float4
--);


--describe bp_pecota2020.projected_fielder_binomials_regressed;
--
--create foreign table pecota.pecota_fielder_binomials (  
--year_proj	int4 not null,
--fld_id	int4 not null,
--years	int4 not null,
--pos	int4 not null,
--ch	numeric NULL,
--ch_weighted numeric NULL,
--pm_rt_var	numeric NULL,
--pm_rt	numeric NULL,
--pm_rt_lg	numeric NULL,
--pm_rt_raw	numeric NULL )
--SERVER mysql_bpstatslegacy
--OPTIONS (dbname 'bp_pecota2020', table_name 'projected_fielder_binomials_regressed');
--
--
--describe bp_pecota2020.projected_fielder_outfield_assists_binomials_regressed;
--
--create foreign table pecota.pecota_of_assists (  
--z	numeric NULL,
--z_reg	numeric NULL,
--ast_rt_mlb	numeric NULL,
--ast150	numeric NULL,
--fullname	text null,
--mlb_ast_rt	numeric NULL,
--mlb_sd_rt	numeric NULL,
--runs_per_ast	numeric NULL,
--runs_per_g	numeric NULL,
--fld_id	int4 not null,
--year_proj	int4 not null,
--pos	int4 not null,
--years	int4 not null,
--of_ass	numeric NULL,
--g_of	numeric NULL,
--ast_rt	numeric NULL,
--ast_rt_lg	numeric NULL,
--ast_sd_lg	numeric NULL,
--g_of_adj	numeric NULL,
--g_of_lg_adj	numeric NULL)
--SERVER mysql_bpstatslegacy
--OPTIONS (dbname 'bp_pecota2020', table_name 'projected_fielder_outfield_assists_binomials_regressed');

-- grant select on all tables in schema pecota to basecoach;

-- grant usage on schema jjudge to basecoach;
-- grant select on all tables in schema jjudge to basecoach;


 --bp_book20.pecota_pit20
 
--	, @sh := $SH*(l.SH_OP/(l.GB_OUT+l.AiB_OUT+l.UNK_OUT)*(@so+@field_bip-@reach_field)) AS SH
--	, @sf := $SF*(l.SF_OP/(l.GB_OUT+l.AiB_OUT+l.UNK_OUT)*(@so+@field_bip-@reach_field)) AS SF
--	, @dp := $DP*(l.DP_OP/(l.GB_OUT+l.AiB_OUT+l.UNK_OUT)*(@so+@field_bip-@reach_field)) AS DP
--	, @tp := $TP*(l.TP_OP/(l.GB_OUT+l.AiB_OUT+l.UNK_OUT)*(@so+@field_bip-@reach_field)) AS TP
-----------------------------------------------------
--https://bitbucket.org/bp-dev/pecota19/src/master/sql/10p_bio_lines_pit.sql
--https://bitbucket.org/bp-dev/pecota19/src/master/sql/13a_pitcher_pecota.sql
-- https://bitbucket.org/bp-dev/pecota20/src/master/sql/15b_comps_b_ten.sql
--
--create   table stats.pecota_of_assists (  
--z	numeric NULL,
--z_reg	numeric NULL,
--ast_rt_mlb	numeric NULL,
--ast150	numeric NULL, 
--mlb_ast_rt	numeric NULL,
--mlb_sd_rt	numeric NULL,
--runs_per_ast	numeric NULL,
--runs_per_g	numeric NULL,
--bpid	int4 not null,
--season	int4 not null,
--"position"	int4 not null,
--years	int4 not null,
--of_ass	numeric NULL,
--g_of	numeric NULL,
--ast_rt	numeric NULL,
--ast_rt_lg	numeric NULL,
--ast_sd_lg	numeric NULL,
--g_of_adj	numeric NULL,
--g_of_lg_adj	numeric NULL)
--
--
--
--create   table stats.pecota_fielder_binomials (  
--season	int4 not null,
--bpid	int4 not null,
--years	int4 not null,
--"position"	int4 not null,
--ch	numeric NULL,
--ch_weighted numeric NULL,
--pm_rt_var	numeric NULL,
--pm_rt	numeric NULL,
--pm_rt_lg	numeric NULL,
--pm_rt_raw	numeric NULL )






--
--
--
--
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1921,'mlb',1,62026,0.0647)
--,(1921,'mlb',2,62026,0.0070)
--,(1921,'mlb',3,62026,0.0380)
--,(1921,'mlb',4,62026,0.0871)
--,(1921,'mlb',5,62026,0.0607)
--,(1921,'mlb',6,62026,0.0917)
--,(1921,'mlb',7,62026,0.0680)
--,(1921,'mlb',8,62026,0.0798)
--,(1921,'mlb',9,62026,0.0576)
--,(1922,'mlb',1,62807,0.0624)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1922,'mlb',2,62807,0.0066)
--,(1922,'mlb',3,62807,0.0419)
--,(1922,'mlb',4,62807,0.0896)
--,(1922,'mlb',5,62807,0.0599)
--,(1922,'mlb',6,62807,0.0939)
--,(1922,'mlb',7,62807,0.0664)
--,(1922,'mlb',8,62807,0.0822)
--,(1922,'mlb',9,62807,0.0587)
--,(1923,'mlb',1,64035,0.0642)
--,(1923,'mlb',2,64035,0.0058)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1923,'mlb',3,64035,0.0372)
--,(1923,'mlb',4,64035,0.0885)
--,(1923,'mlb',5,64035,0.0612)
--,(1923,'mlb',6,64035,0.0917)
--,(1923,'mlb',7,64035,0.0665)
--,(1923,'mlb',8,64035,0.0822)
--,(1923,'mlb',9,64035,0.0620)
--,(1924,'mlb',1,65071,0.0625)
--,(1924,'mlb',2,65071,0.0062)
--,(1924,'mlb',3,65071,0.0405)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1924,'mlb',4,65071,0.0905)
--,(1924,'mlb',5,65071,0.0570)
--,(1924,'mlb',6,65071,0.0904)
--,(1924,'mlb',7,65071,0.0675)
--,(1924,'mlb',8,65071,0.0842)
--,(1924,'mlb',9,65071,0.0594)
--,(1925,'mlb',1,65048,0.0638)
--,(1925,'mlb',2,65048,0.0051)
--,(1925,'mlb',3,65048,0.0395)
--,(1925,'mlb',4,65048,0.0876)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1925,'mlb',5,65048,0.0583)
--,(1925,'mlb',6,65048,0.0891)
--,(1925,'mlb',7,65048,0.0661)
--,(1925,'mlb',8,65048,0.0860)
--,(1925,'mlb',9,65048,0.0635)
--,(1926,'mlb',1,64216,0.0654)
--,(1926,'mlb',2,64216,0.0059)
--,(1926,'mlb',3,64216,0.0400)
--,(1926,'mlb',4,64216,0.0925)
--,(1926,'mlb',5,64216,0.0610)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1926,'mlb',6,64216,0.0882)
--,(1926,'mlb',7,64216,0.0655)
--,(1926,'mlb',8,64216,0.0840)
--,(1926,'mlb',9,64216,0.0619)
--,(1927,'mlb',1,66371,0.0615)
--,(1927,'mlb',2,66371,0.0056)
--,(1927,'mlb',3,66371,0.0438)
--,(1927,'mlb',4,66371,0.0922)
--,(1927,'mlb',5,66371,0.0583)
--,(1927,'mlb',6,66371,0.0881)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1927,'mlb',7,66371,0.0673)
--,(1927,'mlb',8,66371,0.0845)
--,(1927,'mlb',9,66371,0.0626)
--,(1928,'mlb',1,64072,0.0611)
--,(1928,'mlb',2,64072,0.0050)
--,(1928,'mlb',3,64072,0.0412)
--,(1928,'mlb',4,64072,0.0883)
--,(1928,'mlb',5,64072,0.0621)
--,(1928,'mlb',6,64072,0.0873)
--,(1928,'mlb',7,64072,0.0683)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1928,'mlb',8,64072,0.0847)
--,(1928,'mlb',9,64072,0.0630)
--,(1929,'mlb',1,60206,0.0577)
--,(1929,'mlb',2,60206,0.0046)
--,(1929,'mlb',3,60206,0.0422)
--,(1929,'mlb',4,60206,0.0903)
--,(1929,'mlb',5,60206,0.0575)
--,(1929,'mlb',6,60206,0.0884)
--,(1929,'mlb',7,60206,0.0667)
--,(1929,'mlb',8,60206,0.0889)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1929,'mlb',9,60206,0.0629)
--,(1930,'mlb',1,65168,0.0536)
--,(1930,'mlb',2,65168,0.0041)
--,(1930,'mlb',3,65168,0.0412)
--,(1930,'mlb',4,65168,0.0918)
--,(1930,'mlb',5,65168,0.0576)
--,(1930,'mlb',6,65168,0.0885)
--,(1930,'mlb',7,65168,0.0618)
--,(1930,'mlb',8,65168,0.0839)
--,(1930,'mlb',9,65168,0.0635)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1931,'mlb',1,65469,0.0551)
--,(1931,'mlb',2,65469,0.0048)
--,(1931,'mlb',3,65469,0.0402)
--,(1931,'mlb',4,65469,0.0865)
--,(1931,'mlb',5,65469,0.0576)
--,(1931,'mlb',6,65469,0.0892)
--,(1931,'mlb',7,65469,0.0669)
--,(1931,'mlb',8,65469,0.0873)
--,(1931,'mlb',9,65469,0.0661)
--,(1932,'mlb',1,61540,0.0547)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1932,'mlb',2,61540,0.0046)
--,(1932,'mlb',3,61540,0.0433)
--,(1932,'mlb',4,61540,0.0870)
--,(1932,'mlb',5,61540,0.0590)
--,(1932,'mlb',6,61540,0.0872)
--,(1932,'mlb',7,61540,0.0667)
--,(1932,'mlb',8,61540,0.0887)
--,(1932,'mlb',9,61540,0.0658)
--,(1933,'mlb',1,63534,0.0594)
--,(1933,'mlb',2,63534,0.0048)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1933,'mlb',3,63534,0.0413)
--,(1933,'mlb',4,63534,0.0904)
--,(1933,'mlb',5,63534,0.0595)
--,(1933,'mlb',6,63534,0.0903)
--,(1933,'mlb',7,63534,0.0687)
--,(1933,'mlb',8,63534,0.0825)
--,(1933,'mlb',9,63534,0.0644)
--,(1934,'mlb',1,55846,0.0561)
--,(1934,'mlb',2,55846,0.0044)
--,(1934,'mlb',3,55846,0.0389)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1934,'mlb',4,55846,0.0896)
--,(1934,'mlb',5,55846,0.0610)
--,(1934,'mlb',6,55846,0.0918)
--,(1934,'mlb',7,55846,0.0659)
--,(1934,'mlb',8,55846,0.0820)
--,(1934,'mlb',9,55846,0.0627)
--,(1935,'mlb',1,54959,0.0570)
--,(1935,'mlb',2,54959,0.0049)
--,(1935,'mlb',3,54959,0.0422)
--,(1935,'mlb',4,54959,0.0896)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1935,'mlb',5,54959,0.0583)
--,(1935,'mlb',6,54959,0.0873)
--,(1935,'mlb',7,54959,0.0679)
--,(1935,'mlb',8,54959,0.0854)
--,(1935,'mlb',9,54959,0.0634)
--,(1936,'mlb',1,59336,0.0530)
--,(1936,'mlb',2,59336,0.0052)
--,(1936,'mlb',3,59336,0.0435)
--,(1936,'mlb',4,59336,0.0897)
--,(1936,'mlb',5,59336,0.0565)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1936,'mlb',6,59336,0.0876)
--,(1936,'mlb',7,59336,0.0638)
--,(1936,'mlb',8,59336,0.0863)
--,(1936,'mlb',9,59336,0.0646)
--,(1937,'mlb',1,61000,0.0550)
--,(1937,'mlb',2,61000,0.0048)
--,(1937,'mlb',3,61000,0.0436)
--,(1937,'mlb',4,61000,0.0881)
--,(1937,'mlb',5,61000,0.0615)
--,(1937,'mlb',6,61000,0.0887)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1937,'mlb',7,61000,0.0656)
--,(1937,'mlb',8,61000,0.0846)
--,(1937,'mlb',9,61000,0.0606)
--,(1938,'mlb',1,50471,0.0533)
--,(1938,'mlb',2,50471,0.0047)
--,(1938,'mlb',3,50471,0.0462)
--,(1938,'mlb',4,50471,0.0867)
--,(1938,'mlb',5,50471,0.0631)
--,(1938,'mlb',6,50471,0.0851)
--,(1938,'mlb',7,50471,0.0675)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1938,'mlb',8,50471,0.0855)
--,(1938,'mlb',9,50471,0.0632)
--,(1939,'mlb',1,62918,0.0476)
--,(1939,'mlb',2,62918,0.0038)
--,(1939,'mlb',3,62918,0.0408)
--,(1939,'mlb',4,62918,0.0794)
--,(1939,'mlb',5,62918,0.0605)
--,(1939,'mlb',6,62918,0.0839)
--,(1939,'mlb',7,62918,0.0665)
--,(1939,'mlb',8,62918,0.0809)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1939,'mlb',9,62918,0.0602)
--,(1940,'mlb',1,63240,0.0503)
--,(1940,'mlb',2,63240,0.0044)
--,(1940,'mlb',3,63240,0.0429)
--,(1940,'mlb',4,63240,0.0821)
--,(1940,'mlb',5,63240,0.0603)
--,(1940,'mlb',6,63240,0.0846)
--,(1940,'mlb',7,63240,0.0681)
--,(1940,'mlb',8,63240,0.0820)
--,(1940,'mlb',9,63240,0.0612)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1941,'mlb',1,58690,0.0505)
--,(1941,'mlb',2,58690,0.0049)
--,(1941,'mlb',3,58690,0.0441)
--,(1941,'mlb',4,58690,0.0786)
--,(1941,'mlb',5,58690,0.0635)
--,(1941,'mlb',6,58690,0.0802)
--,(1941,'mlb',7,58690,0.0683)
--,(1941,'mlb',8,58690,0.0817)
--,(1941,'mlb',9,58690,0.0597)
--,(1942,'mlb',1,58459,0.0551)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1942,'mlb',2,58459,0.0044)
--,(1942,'mlb',3,58459,0.0451)
--,(1942,'mlb',4,58459,0.0797)
--,(1942,'mlb',5,58459,0.0590)
--,(1942,'mlb',6,58459,0.0810)
--,(1942,'mlb',7,58459,0.0665)
--,(1942,'mlb',8,58459,0.0797)
--,(1942,'mlb',9,58459,0.0610)
--,(1943,'mlb',1,52223,0.0530)
--,(1943,'mlb',2,52223,0.0041)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1943,'mlb',3,52223,0.0439)
--,(1943,'mlb',4,52223,0.0786)
--,(1943,'mlb',5,52223,0.0601)
--,(1943,'mlb',6,52223,0.0841)
--,(1943,'mlb',7,52223,0.0669)
--,(1943,'mlb',8,52223,0.0804)
--,(1943,'mlb',9,52223,0.0635)
--,(1944,'mlb',1,51247,0.0502)
--,(1944,'mlb',2,51247,0.0037)
--,(1944,'mlb',3,51247,0.0410)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1944,'mlb',4,51247,0.0783)
--,(1944,'mlb',5,51247,0.0664)
--,(1944,'mlb',6,51247,0.0919)
--,(1944,'mlb',7,51247,0.0709)
--,(1944,'mlb',8,51247,0.0902)
--,(1944,'mlb',9,51247,0.0629)
--,(1945,'mlb',1,56300,0.0528)
--,(1945,'mlb',2,56300,0.0040)
--,(1945,'mlb',3,56300,0.0479)
--,(1945,'mlb',4,56300,0.0802)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1945,'mlb',5,56300,0.0636)
--,(1945,'mlb',6,56300,0.0882)
--,(1945,'mlb',7,56300,0.0694)
--,(1945,'mlb',8,56300,0.0859)
--,(1945,'mlb',9,56300,0.0633)
--,(1946,'mlb',1,57030,0.0518)
--,(1946,'mlb',2,57030,0.0045)
--,(1946,'mlb',3,57030,0.0471)
--,(1946,'mlb',4,57030,0.0804)
--,(1946,'mlb',5,57030,0.0632)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1946,'mlb',6,57030,0.0866)
--,(1946,'mlb',7,57030,0.0703)
--,(1946,'mlb',8,57030,0.0869)
--,(1946,'mlb',9,57030,0.0636)
--,(1947,'mlb',1,62719,0.0491)
--,(1947,'mlb',2,62719,0.0044)
--,(1947,'mlb',3,62719,0.0444)
--,(1947,'mlb',4,62719,0.0787)
--,(1947,'mlb',5,62719,0.0629)
--,(1947,'mlb',6,62719,0.0903)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1947,'mlb',7,62719,0.0733)
--,(1947,'mlb',8,62719,0.0914)
--,(1947,'mlb',9,62719,0.0670)
--,(1948,'mlb',1,62398,0.0493)
--,(1948,'mlb',2,62398,0.0039)
--,(1948,'mlb',3,62398,0.0459)
--,(1948,'mlb',4,62398,0.0798)
--,(1948,'mlb',5,62398,0.0634)
--,(1948,'mlb',6,62398,0.0883)
--,(1948,'mlb',7,62398,0.0738)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1948,'mlb',8,62398,0.0919)
--,(1948,'mlb',9,62398,0.0655)
--,(1949,'mlb',1,63997,0.0502)
--,(1949,'mlb',2,63997,0.0041)
--,(1949,'mlb',3,63997,0.0462)
--,(1949,'mlb',4,63997,0.0763)
--,(1949,'mlb',5,63997,0.0683)
--,(1949,'mlb',6,63997,0.0891)
--,(1949,'mlb',7,63997,0.0766)
--,(1949,'mlb',8,63997,0.0917)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1949,'mlb',9,63997,0.0660)
--,(1950,'mlb',1,64855,0.0501)
--,(1950,'mlb',2,64855,0.0036)
--,(1950,'mlb',3,64855,0.0421)
--,(1950,'mlb',4,64855,0.0772)
--,(1950,'mlb',5,64855,0.0694)
--,(1950,'mlb',6,64855,0.0910)
--,(1950,'mlb',7,64855,0.0753)
--,(1950,'mlb',8,64855,0.0921)
--,(1950,'mlb',9,64855,0.0632)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1951,'mlb',1,68077,0.0504)
--,(1951,'mlb',2,68077,0.0043)
--,(1951,'mlb',3,68077,0.0444)
--,(1951,'mlb',4,68077,0.0806)
--,(1951,'mlb',5,68077,0.0683)
--,(1951,'mlb',6,68077,0.0864)
--,(1951,'mlb',7,68077,0.0757)
--,(1951,'mlb',8,68077,0.0912)
--,(1951,'mlb',9,68077,0.0650)
--,(1952,'mlb',1,66588,0.0520)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1952,'mlb',2,66588,0.0043)
--,(1952,'mlb',3,66588,0.0477)
--,(1952,'mlb',4,66588,0.0821)
--,(1952,'mlb',5,66588,0.0706)
--,(1952,'mlb',6,66588,0.0886)
--,(1952,'mlb',7,66588,0.0702)
--,(1952,'mlb',8,66588,0.0930)
--,(1952,'mlb',9,66588,0.0643)
--,(1953,'mlb',1,69378,0.0478)
--,(1953,'mlb',2,69378,0.0036)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1953,'mlb',3,69378,0.0443)
--,(1953,'mlb',4,69378,0.0789)
--,(1953,'mlb',5,69378,0.0695)
--,(1953,'mlb',6,69378,0.0905)
--,(1953,'mlb',7,69378,0.0701)
--,(1953,'mlb',8,69378,0.0942)
--,(1953,'mlb',9,69378,0.0654)
--,(1954,'mlb',1,69992,0.0492)
--,(1954,'mlb',2,69992,0.0041)
--,(1954,'mlb',3,69992,0.0443)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1954,'mlb',4,69992,0.0761)
--,(1954,'mlb',5,69992,0.0722)
--,(1954,'mlb',6,69992,0.0908)
--,(1954,'mlb',7,69992,0.0718)
--,(1954,'mlb',8,69992,0.0921)
--,(1954,'mlb',9,69992,0.0646)
--,(1955,'mlb',1,68586,0.0490)
--,(1955,'mlb',2,68586,0.0040)
--,(1955,'mlb',3,68586,0.0454)
--,(1955,'mlb',4,68586,0.0763)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1955,'mlb',5,68586,0.0686)
--,(1955,'mlb',6,68586,0.0917)
--,(1955,'mlb',7,68586,0.0709)
--,(1955,'mlb',8,68586,0.0921)
--,(1955,'mlb',9,68586,0.0659)
--,(1956,'mlb',1,69197,0.0489)
--,(1956,'mlb',2,69197,0.0040)
--,(1956,'mlb',3,69197,0.0469)
--,(1956,'mlb',4,69197,0.0805)
--,(1956,'mlb',5,69197,0.0700)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1956,'mlb',6,69197,0.0918)
--,(1956,'mlb',7,69197,0.0686)
--,(1956,'mlb',8,69197,0.0923)
--,(1956,'mlb',9,69197,0.0672)
--,(1957,'mlb',1,70853,0.0495)
--,(1957,'mlb',2,70853,0.0043)
--,(1957,'mlb',3,70853,0.0466)
--,(1957,'mlb',4,70853,0.0806)
--,(1957,'mlb',5,70853,0.0691)
--,(1957,'mlb',6,70853,0.0949)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1957,'mlb',7,70853,0.0689)
--,(1957,'mlb',8,70853,0.0924)
--,(1957,'mlb',9,70853,0.0643)
--,(1958,'mlb',1,70570,0.0492)
--,(1958,'mlb',2,70570,0.0037)
--,(1958,'mlb',3,70570,0.0441)
--,(1958,'mlb',4,70570,0.0791)
--,(1958,'mlb',5,70570,0.0724)
--,(1958,'mlb',6,70570,0.0948)
--,(1958,'mlb',7,70570,0.0689)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1958,'mlb',8,70570,0.0915)
--,(1958,'mlb',9,70570,0.0664)
--,(1959,'mlb',1,70821,0.0502)
--,(1959,'mlb',2,70821,0.0042)
--,(1959,'mlb',3,70821,0.0470)
--,(1959,'mlb',4,70821,0.0833)
--,(1959,'mlb',5,70821,0.0712)
--,(1959,'mlb',6,70821,0.0972)
--,(1959,'mlb',7,70821,0.0683)
--,(1959,'mlb',8,70821,0.0900)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1959,'mlb',9,70821,0.0640)
--,(1960,'mlb',1,70891,0.0503)
--,(1960,'mlb',2,70891,0.0046)
--,(1960,'mlb',3,70891,0.0450)
--,(1960,'mlb',4,70891,0.0833)
--,(1960,'mlb',5,70891,0.0707)
--,(1960,'mlb',6,70891,0.0966)
--,(1960,'mlb',7,70891,0.0693)
--,(1960,'mlb',8,70891,0.0892)
--,(1960,'mlb',9,70891,0.0658)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1961,'mlb',1,80963,0.0519)
--,(1961,'mlb',2,80963,0.0041)
--,(1961,'mlb',3,80963,0.0465)
--,(1961,'mlb',4,80963,0.0828)
--,(1961,'mlb',5,80963,0.0716)
--,(1961,'mlb',6,80963,0.0947)
--,(1961,'mlb',7,80963,0.0656)
--,(1961,'mlb',8,80963,0.0890)
--,(1961,'mlb',9,80963,0.0671)
--,(1962,'mlb',1,91753,0.0506)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1962,'mlb',2,91753,0.0038)
--,(1962,'mlb',3,91753,0.0491)
--,(1962,'mlb',4,91753,0.0833)
--,(1962,'mlb',5,91753,0.0703)
--,(1962,'mlb',6,91753,0.0952)
--,(1962,'mlb',7,91753,0.0646)
--,(1962,'mlb',8,91753,0.0863)
--,(1962,'mlb',9,91753,0.0657)
--,(1963,'mlb',1,90287,0.0520)
--,(1963,'mlb',2,90287,0.0045)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1963,'mlb',3,90287,0.0488)
--,(1963,'mlb',4,90287,0.0862)
--,(1963,'mlb',5,90287,0.0715)
--,(1963,'mlb',6,90287,0.0958)
--,(1963,'mlb',7,90287,0.0638)
--,(1963,'mlb',8,90287,0.0862)
--,(1963,'mlb',9,90287,0.0661)
--,(1964,'mlb',1,90415,0.0531)
--,(1964,'mlb',2,90415,0.0046)
--,(1964,'mlb',3,90415,0.0473)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1964,'mlb',4,90415,0.0876)
--,(1964,'mlb',5,90415,0.0725)
--,(1964,'mlb',6,90415,0.0987)
--,(1964,'mlb',7,90415,0.0608)
--,(1964,'mlb',8,90415,0.0833)
--,(1964,'mlb',9,90415,0.0648)
--,(1965,'mlb',1,89153,0.0540)
--,(1965,'mlb',2,89153,0.0046)
--,(1965,'mlb',3,89153,0.0464)
--,(1965,'mlb',4,89153,0.0880)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1965,'mlb',5,89153,0.0736)
--,(1965,'mlb',6,89153,0.0986)
--,(1965,'mlb',7,89153,0.0625)
--,(1965,'mlb',8,89153,0.0832)
--,(1965,'mlb',9,89153,0.0662)
--,(1966,'mlb',1,89339,0.0500)
--,(1966,'mlb',2,89339,0.0039)
--,(1966,'mlb',3,89339,0.0457)
--,(1966,'mlb',4,89339,0.0854)
--,(1966,'mlb',5,89339,0.0751)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1966,'mlb',6,89339,0.1012)
--,(1966,'mlb',7,89339,0.0615)
--,(1966,'mlb',8,89339,0.0857)
--,(1966,'mlb',9,89339,0.0675)
--,(1967,'mlb',1,88955,0.0516)
--,(1967,'mlb',2,88955,0.0049)
--,(1967,'mlb',3,88955,0.0463)
--,(1967,'mlb',4,88955,0.0847)
--,(1967,'mlb',5,88955,0.0769)
--,(1967,'mlb',6,88955,0.1026)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1967,'mlb',7,88955,0.0629)
--,(1967,'mlb',8,88955,0.0843)
--,(1967,'mlb',9,88955,0.0671)
--,(1968,'mlb',1,88074,0.0500)
--,(1968,'mlb',2,88074,0.0052)
--,(1968,'mlb',3,88074,0.0468)
--,(1968,'mlb',4,88074,0.0891)
--,(1968,'mlb',5,88074,0.0748)
--,(1968,'mlb',6,88074,0.1053)
--,(1968,'mlb',7,88074,0.0609)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1968,'mlb',8,88074,0.0868)
--,(1968,'mlb',9,88074,0.0678)
--,(1969,'mlb',1,107061,0.0488)
--,(1969,'mlb',2,107061,0.0046)
--,(1969,'mlb',3,107061,0.0458)
--,(1969,'mlb',4,107061,0.0846)
--,(1969,'mlb',5,107061,0.0753)
--,(1969,'mlb',6,107061,0.1027)
--,(1969,'mlb',7,107061,0.0642)
--,(1969,'mlb',8,107061,0.0848)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1969,'mlb',9,107061,0.0658)
--,(1970,'mlb',1,108206,0.0460)
--,(1970,'mlb',2,108206,0.0039)
--,(1970,'mlb',3,108206,0.0464)
--,(1970,'mlb',4,108206,0.0868)
--,(1970,'mlb',5,108206,0.0737)
--,(1970,'mlb',6,108206,0.1023)
--,(1970,'mlb',7,108206,0.0613)
--,(1970,'mlb',8,108206,0.0867)
--,(1970,'mlb',9,108206,0.0688)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1971,'mlb',1,108908,0.0485)
--,(1971,'mlb',2,108908,0.0043)
--,(1971,'mlb',3,108908,0.0462)
--,(1971,'mlb',4,108908,0.0870)
--,(1971,'mlb',5,108908,0.0736)
--,(1971,'mlb',6,108908,0.1051)
--,(1971,'mlb',7,108908,0.0647)
--,(1971,'mlb',8,108908,0.0927)
--,(1971,'mlb',9,108908,0.0702)
--,(1972,'mlb',1,104084,0.0470)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1972,'mlb',2,104084,0.0047)
--,(1972,'mlb',3,104084,0.0464)
--,(1972,'mlb',4,104084,0.0879)
--,(1972,'mlb',5,104084,0.0747)
--,(1972,'mlb',6,104084,0.1061)
--,(1972,'mlb',7,104084,0.0655)
--,(1972,'mlb',8,104084,0.0913)
--,(1972,'mlb',9,104084,0.0709)
--,(1973,'mlb',1,111221,0.0451)
--,(1973,'mlb',2,111221,0.0041)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1973,'mlb',3,111221,0.0446)
--,(1973,'mlb',4,111221,0.0872)
--,(1973,'mlb',5,111221,0.0733)
--,(1973,'mlb',6,111221,0.1049)
--,(1973,'mlb',7,111221,0.0679)
--,(1973,'mlb',8,111221,0.0917)
--,(1973,'mlb',9,111221,0.0684)
--,(1974,'mlb',1,112934,0.0442)
--,(1974,'mlb',2,112934,0.0042)
--,(1974,'mlb',3,112934,0.0434)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1974,'mlb',4,112934,0.0836)
--,(1974,'mlb',5,112934,0.0756)
--,(1974,'mlb',6,112934,0.1027)
--,(1974,'mlb',7,112934,0.0683)
--,(1974,'mlb',8,112934,0.0955)
--,(1974,'mlb',9,112934,0.0697)
--,(1975,'mlb',1,112424,0.0440)
--,(1975,'mlb',2,112424,0.0042)
--,(1975,'mlb',3,112424,0.0457)
--,(1975,'mlb',4,112424,0.0875)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1975,'mlb',5,112424,0.0756)
--,(1975,'mlb',6,112424,0.1001)
--,(1975,'mlb',7,112424,0.0706)
--,(1975,'mlb',8,112424,0.0931)
--,(1975,'mlb',9,112424,0.0683)
--,(1976,'mlb',1,113514,0.0432)
--,(1976,'mlb',2,113514,0.0039)
--,(1976,'mlb',3,113514,0.0459)
--,(1976,'mlb',4,113514,0.0887)
--,(1976,'mlb',5,113514,0.0710)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1976,'mlb',6,113514,0.1020)
--,(1976,'mlb',7,113514,0.0700)
--,(1976,'mlb',8,113514,0.0972)
--,(1976,'mlb',9,113514,0.0718)
--,(1977,'mlb',1,121599,0.0449)
--,(1977,'mlb',2,121599,0.0040)
--,(1977,'mlb',3,121599,0.0474)
--,(1977,'mlb',4,121599,0.0908)
--,(1977,'mlb',5,121599,0.0733)
--,(1977,'mlb',6,121599,0.0986)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1977,'mlb',7,121599,0.0673)
--,(1977,'mlb',8,121599,0.0936)
--,(1977,'mlb',9,121599,0.0696)
--,(1978,'mlb',1,121800,0.0448)
--,(1978,'mlb',2,121800,0.0046)
--,(1978,'mlb',3,121800,0.0471)
--,(1978,'mlb',4,121800,0.0901)
--,(1978,'mlb',5,121800,0.0740)
--,(1978,'mlb',6,121800,0.0976)
--,(1978,'mlb',7,121800,0.0695)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1978,'mlb',8,121800,0.0966)
--,(1978,'mlb',9,121800,0.0722)
--,(1979,'mlb',1,122518,0.0430)
--,(1979,'mlb',2,122518,0.0039)
--,(1979,'mlb',3,122518,0.0471)
--,(1979,'mlb',4,122518,0.0887)
--,(1979,'mlb',5,122518,0.0731)
--,(1979,'mlb',6,122518,0.0992)
--,(1979,'mlb',7,122518,0.0695)
--,(1979,'mlb',8,122518,0.0951)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1979,'mlb',9,122518,0.0725)
--,(1980,'mlb',1,124040,0.0431)
--,(1980,'mlb',2,124040,0.0038)
--,(1980,'mlb',3,124040,0.0465)
--,(1980,'mlb',4,124040,0.0923)
--,(1980,'mlb',5,124040,0.0719)
--,(1980,'mlb',6,124040,0.0996)
--,(1980,'mlb',7,124040,0.0725)
--,(1980,'mlb',8,124040,0.0953)
--,(1980,'mlb',9,124040,0.0680)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1981,'mlb',1,81528,0.0457)
--,(1981,'mlb',2,81528,0.0041)
--,(1981,'mlb',3,81528,0.0473)
--,(1981,'mlb',4,81528,0.0954)
--,(1981,'mlb',5,81528,0.0714)
--,(1981,'mlb',6,81528,0.1004)
--,(1981,'mlb',7,81528,0.0745)
--,(1981,'mlb',8,81528,0.0953)
--,(1981,'mlb',9,81528,0.0697)
--,(1982,'mlb',1,122503,0.0422)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1982,'mlb',2,122503,0.0036)
--,(1982,'mlb',3,122503,0.0477)
--,(1982,'mlb',4,122503,0.0911)
--,(1982,'mlb',5,122503,0.0731)
--,(1982,'mlb',6,122503,0.0996)
--,(1982,'mlb',7,122503,0.0728)
--,(1982,'mlb',8,122503,0.0926)
--,(1982,'mlb',9,122503,0.0712)
--,(1983,'mlb',1,121338,0.0405)
--,(1983,'mlb',2,121338,0.0036)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1983,'mlb',3,121338,0.0477)
--,(1983,'mlb',4,121338,0.0904)
--,(1983,'mlb',5,121338,0.0727)
--,(1983,'mlb',6,121338,0.0975)
--,(1983,'mlb',7,121338,0.0727)
--,(1983,'mlb',8,121338,0.0969)
--,(1983,'mlb',9,121338,0.0711)
--,(1984,'mlb',1,120716,0.0404)
--,(1984,'mlb',2,120716,0.0032)
--,(1984,'mlb',3,120716,0.0480)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1984,'mlb',4,120716,0.0923)
--,(1984,'mlb',5,120716,0.0676)
--,(1984,'mlb',6,120716,0.0981)
--,(1984,'mlb',7,120716,0.0723)
--,(1984,'mlb',8,120716,0.0975)
--,(1984,'mlb',9,120716,0.0724)
--,(1985,'mlb',1,119688,0.0421)
--,(1985,'mlb',2,119688,0.0034)
--,(1985,'mlb',3,119688,0.0507)
--,(1985,'mlb',4,119688,0.0927)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1985,'mlb',5,119688,0.0719)
--,(1985,'mlb',6,119688,0.0958)
--,(1985,'mlb',7,119688,0.0710)
--,(1985,'mlb',8,119688,0.0955)
--,(1985,'mlb',9,119688,0.0707)
--,(1986,'mlb',1,117261,0.0411)
--,(1986,'mlb',2,117261,0.0035)
--,(1986,'mlb',3,117261,0.0524)
--,(1986,'mlb',4,117261,0.0926)
--,(1986,'mlb',5,117261,0.0688)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1986,'mlb',6,117261,0.0934)
--,(1986,'mlb',7,117261,0.0733)
--,(1986,'mlb',8,117261,0.0949)
--,(1986,'mlb',9,117261,0.0703)
--,(1987,'mlb',1,117076,0.0424)
--,(1987,'mlb',2,117076,0.0033)
--,(1987,'mlb',3,117076,0.0507)
--,(1987,'mlb',4,117076,0.0910)
--,(1987,'mlb',5,117076,0.0716)
--,(1987,'mlb',6,117076,0.0960)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1987,'mlb',7,117076,0.0714)
--,(1987,'mlb',8,117076,0.0919)
--,(1987,'mlb',9,117076,0.0709)
--,(1988,'mlb',1,118928,0.0418)
--,(1988,'mlb',2,118928,0.0030)
--,(1988,'mlb',3,118928,0.0506)
--,(1988,'mlb',4,118928,0.0914)
--,(1988,'mlb',5,118928,0.0694)
--,(1988,'mlb',6,118928,0.0950)
--,(1988,'mlb',7,118928,0.0751)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1988,'mlb',8,118928,0.0968)
--,(1988,'mlb',9,118928,0.0736)
--,(1989,'mlb',1,118954,0.0425)
--,(1989,'mlb',2,118954,0.0035)
--,(1989,'mlb',3,118954,0.0490)
--,(1989,'mlb',4,118954,0.0922)
--,(1989,'mlb',5,118954,0.0690)
--,(1989,'mlb',6,118954,0.0956)
--,(1989,'mlb',7,118954,0.0738)
--,(1989,'mlb',8,118954,0.0945)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1989,'mlb',9,118954,0.0761)
--,(1990,'mlb',1,118411,0.0392)
--,(1990,'mlb',2,118411,0.0032)
--,(1990,'mlb',3,118411,0.0506)
--,(1990,'mlb',4,118411,0.0921)
--,(1990,'mlb',5,118411,0.0689)
--,(1990,'mlb',6,118411,0.0933)
--,(1990,'mlb',7,118411,0.0746)
--,(1990,'mlb',8,118411,0.0948)
--,(1990,'mlb',9,118411,0.0757)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1991,'mlb',1,118068,0.0402)
--,(1991,'mlb',2,118068,0.0031)
--,(1991,'mlb',3,118068,0.0512)
--,(1991,'mlb',4,118068,0.0928)
--,(1991,'mlb',5,118068,0.0719)
--,(1991,'mlb',6,118068,0.0967)
--,(1991,'mlb',7,118068,0.0752)
--,(1991,'mlb',8,118068,0.0933)
--,(1991,'mlb',9,118068,0.0728)
--,(1992,'mlb',1,119277,0.0392)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1992,'mlb',2,119277,0.0036)
--,(1992,'mlb',3,119277,0.0499)
--,(1992,'mlb',4,119277,0.0910)
--,(1992,'mlb',5,119277,0.0701)
--,(1992,'mlb',6,119277,0.0954)
--,(1992,'mlb',7,119277,0.0763)
--,(1992,'mlb',8,119277,0.0985)
--,(1992,'mlb',9,119277,0.0734)
--,(1993,'mlb',1,127882,0.0410)
--,(1993,'mlb',2,127882,0.0037)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1993,'mlb',3,127882,0.0487)
--,(1993,'mlb',4,127882,0.0906)
--,(1993,'mlb',5,127882,0.0679)
--,(1993,'mlb',6,127882,0.0955)
--,(1993,'mlb',7,127882,0.0740)
--,(1993,'mlb',8,127882,0.0950)
--,(1993,'mlb',9,127882,0.0746)
--,(1994,'mlb',1,89371,0.0406)
--,(1994,'mlb',2,89371,0.0034)
--,(1994,'mlb',3,89371,0.0487)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1994,'mlb',4,89371,0.0936)
--,(1994,'mlb',5,89371,0.0683)
--,(1994,'mlb',6,89371,0.0965)
--,(1994,'mlb',7,89371,0.0701)
--,(1994,'mlb',8,89371,0.0939)
--,(1994,'mlb',9,89371,0.0748)
--,(1995,'mlb',1,111717,0.0411)
--,(1995,'mlb',2,111717,0.0033)
--,(1995,'mlb',3,111717,0.0510)
--,(1995,'mlb',4,111717,0.0928)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1995,'mlb',5,111717,0.0708)
--,(1995,'mlb',6,111717,0.0965)
--,(1995,'mlb',7,111717,0.0708)
--,(1995,'mlb',8,111717,0.0914)
--,(1995,'mlb',9,111717,0.0715)
--,(1996,'mlb',1,125474,0.0412)
--,(1996,'mlb',2,125474,0.0034)
--,(1996,'mlb',3,125474,0.0488)
--,(1996,'mlb',4,125474,0.0897)
--,(1996,'mlb',5,125474,0.0688)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1996,'mlb',6,125474,0.0963)
--,(1996,'mlb',7,125474,0.0700)
--,(1996,'mlb',8,125474,0.0925)
--,(1996,'mlb',9,125474,0.0735)
--,(1997,'mlb',1,123821,0.0409)
--,(1997,'mlb',2,123821,0.0033)
--,(1997,'mlb',3,123821,0.0496)
--,(1997,'mlb',4,123821,0.0912)
--,(1997,'mlb',5,123821,0.0703)
--,(1997,'mlb',6,123821,0.0958)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1997,'mlb',7,123821,0.0704)
--,(1997,'mlb',8,123821,0.0910)
--,(1997,'mlb',9,123821,0.0739)
--,(1998,'mlb',1,133266,0.0414)
--,(1998,'mlb',2,133266,0.0032)
--,(1998,'mlb',3,133266,0.0506)
--,(1998,'mlb',4,133266,0.0908)
--,(1998,'mlb',5,133266,0.0678)
--,(1998,'mlb',6,133266,0.0963)
--,(1998,'mlb',7,133266,0.0696)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1998,'mlb',8,133266,0.0921)
--,(1998,'mlb',9,133266,0.0737)
--,(1999,'mlb',1,133558,0.0400)
--,(1999,'mlb',2,133558,0.0033)
--,(1999,'mlb',3,133558,0.0479)
--,(1999,'mlb',4,133558,0.0907)
--,(1999,'mlb',5,133558,0.0685)
--,(1999,'mlb',6,133558,0.0935)
--,(1999,'mlb',7,133558,0.0709)
--,(1999,'mlb',8,133558,0.0938)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(1999,'mlb',9,133558,0.0743)
--,(2000,'mlb',1,133383,0.0385)
--,(2000,'mlb',2,133383,0.0034)
--,(2000,'mlb',3,133383,0.0480)
--,(2000,'mlb',4,133383,0.0887)
--,(2000,'mlb',5,133383,0.0694)
--,(2000,'mlb',6,133383,0.0944)
--,(2000,'mlb',7,133383,0.0709)
--,(2000,'mlb',8,133383,0.0949)
--,(2000,'mlb',9,133383,0.0757)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2001,'mlb',1,131403,0.0410)
--,(2001,'mlb',2,131403,0.0035)
--,(2001,'mlb',3,131403,0.0485)
--,(2001,'mlb',4,131403,0.0896)
--,(2001,'mlb',5,131403,0.0701)
--,(2001,'mlb',6,131403,0.0940)
--,(2001,'mlb',7,131403,0.0715)
--,(2001,'mlb',8,131403,0.0940)
--,(2001,'mlb',9,131403,0.0743)
--,(2002,'mlb',1,132161,0.0420)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2002,'mlb',2,132161,0.0044)
--,(2002,'mlb',3,132161,0.0461)
--,(2002,'mlb',4,132161,0.0890)
--,(2002,'mlb',5,132161,0.0711)
--,(2002,'mlb',6,132161,0.0946)
--,(2002,'mlb',7,132161,0.0714)
--,(2002,'mlb',8,132161,0.0949)
--,(2002,'mlb',9,132161,0.0737)
--,(2003,'mlb',1,133691,0.0422)
--,(2003,'mlb',2,133691,0.0038)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2003,'mlb',3,133691,0.0500)
--,(2003,'mlb',4,133691,0.0914)
--,(2003,'mlb',5,133691,0.0711)
--,(2003,'mlb',6,133691,0.0936)
--,(2003,'mlb',7,133691,0.0709)
--,(2003,'mlb',8,133691,0.0928)
--,(2003,'mlb',9,133691,0.0733)
--,(2004,'mlb',1,133168,0.0416)
--,(2004,'mlb',2,133168,0.0041)
--,(2004,'mlb',3,133168,0.0507)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2004,'mlb',4,133168,0.0894)
--,(2004,'mlb',5,133168,0.0702)
--,(2004,'mlb',6,133168,0.0949)
--,(2004,'mlb',7,133168,0.0682)
--,(2004,'mlb',8,133168,0.0915)
--,(2004,'mlb',9,133168,0.0754)
--,(2005,'aaa',1,115261,0.0385)
--,(2005,'aaa',2,115261,0.0037)
--,(2005,'aaa',3,115261,0.0467)
--,(2005,'aaa',4,115261,0.0888)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2005,'aaa',5,115261,0.0722)
--,(2005,'aaa',6,115261,0.0947)
--,(2005,'aaa',7,115261,0.0647)
--,(2005,'aaa',8,115261,0.0896)
--,(2005,'aaa',9,115261,0.0715)
--,(2005,'aax',1,111197,0.0444)
--,(2005,'aax',2,111197,0.0039)
--,(2005,'aax',3,111197,0.0432)
--,(2005,'aax',4,111197,0.0910)
--,(2005,'aax',5,111197,0.0708)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2005,'aax',6,111197,0.0974)
--,(2005,'aax',7,111197,0.0633)
--,(2005,'aax',8,111197,0.0869)
--,(2005,'aax',9,111197,0.0712)
--,(2005,'afa',1,7746,0.0345)
--,(2005,'afa',2,7746,0.0032)
--,(2005,'afa',3,7746,0.0422)
--,(2005,'afa',4,7746,0.0922)
--,(2005,'afa',5,7746,0.0689)
--,(2005,'afa',6,7746,0.1109)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2005,'afa',7,7746,0.0622)
--,(2005,'afa',8,7746,0.0870)
--,(2005,'afa',9,7746,0.0745)
--,(2005,'afx',1,109932,0.0371)
--,(2005,'afx',2,109932,0.0029)
--,(2005,'afx',3,109932,0.0424)
--,(2005,'afx',4,109932,0.0910)
--,(2005,'afx',5,109932,0.0728)
--,(2005,'afx',6,109932,0.1022)
--,(2005,'afx',7,109932,0.0601)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2005,'afx',8,109932,0.0856)
--,(2005,'afx',9,109932,0.0703)
--,(2005,'asx',1,43668,0.0427)
--,(2005,'asx',2,43668,0.0035)
--,(2005,'asx',3,43668,0.0405)
--,(2005,'asx',4,43668,0.0932)
--,(2005,'asx',5,43668,0.0735)
--,(2005,'asx',6,43668,0.1019)
--,(2005,'asx',7,43668,0.0551)
--,(2005,'asx',8,43668,0.0807)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2005,'asx',9,43668,0.0659)
--,(2005,'mex',1,50620,0.0354)
--,(2005,'mex',2,50620,0.0021)
--,(2005,'mex',3,50620,0.0343)
--,(2005,'mex',4,50620,0.0863)
--,(2005,'mex',5,50620,0.0773)
--,(2005,'mex',6,50620,0.1014)
--,(2005,'mex',7,50620,0.0578)
--,(2005,'mex',8,50620,0.0799)
--,(2005,'mex',9,50620,0.0662)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2005,'mlb',1,133609,0.0407)
--,(2005,'mlb',2,133609,0.0042)
--,(2005,'mlb',3,133609,0.0507)
--,(2005,'mlb',4,133609,0.0897)
--,(2005,'mlb',5,133609,0.0724)
--,(2005,'mlb',6,133609,0.0939)
--,(2005,'mlb',7,133609,0.0704)
--,(2005,'mlb',8,133609,0.0915)
--,(2005,'mlb',9,133609,0.0738)
--,(2005,'rok',1,76941,0.0439)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2005,'rok',2,76941,0.0033)
--,(2005,'rok',3,76941,0.0336)
--,(2005,'rok',4,76941,0.0912)
--,(2005,'rok',5,76941,0.0792)
--,(2005,'rok',6,76941,0.1089)
--,(2005,'rok',7,76941,0.0515)
--,(2005,'rok',8,76941,0.0740)
--,(2005,'rok',9,76941,0.0620)
--,(2006,'aaa',1,113187,0.0402)
--,(2006,'aaa',2,113187,0.0041)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2006,'aaa',3,113187,0.0346)
--,(2006,'aaa',4,113187,0.0898)
--,(2006,'aaa',5,113187,0.0736)
--,(2006,'aaa',6,113187,0.0974)
--,(2006,'aaa',7,113187,0.0636)
--,(2006,'aaa',8,113187,0.0892)
--,(2006,'aaa',9,113187,0.0721)
--,(2006,'aax',1,109884,0.0422)
--,(2006,'aax',2,109884,0.0044)
--,(2006,'aax',3,109884,0.0343)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2006,'aax',4,109884,0.0901)
--,(2006,'aax',5,109884,0.0732)
--,(2006,'aax',6,109884,0.0974)
--,(2006,'aax',7,109884,0.0633)
--,(2006,'aax',8,109884,0.0907)
--,(2006,'aax',9,109884,0.0713)
--,(2006,'afa',1,110144,0.0374)
--,(2006,'afa',2,110144,0.0032)
--,(2006,'afa',3,110144,0.0330)
--,(2006,'afa',4,110144,0.0895)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2006,'afa',5,110144,0.0718)
--,(2006,'afa',6,110144,0.0990)
--,(2006,'afa',7,110144,0.0626)
--,(2006,'afa',8,110144,0.0872)
--,(2006,'afa',9,110144,0.0701)
--,(2006,'afx',1,108371,0.0389)
--,(2006,'afx',2,108371,0.0034)
--,(2006,'afx',3,108371,0.0327)
--,(2006,'afx',4,108371,0.0922)
--,(2006,'afx',5,108371,0.0741)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2006,'afx',6,108371,0.1006)
--,(2006,'afx',7,108371,0.0623)
--,(2006,'afx',8,108371,0.0845)
--,(2006,'afx',9,108371,0.0700)
--,(2006,'asx',1,43328,0.0421)
--,(2006,'asx',2,43328,0.0038)
--,(2006,'asx',3,43328,0.0349)
--,(2006,'asx',4,43328,0.0952)
--,(2006,'asx',5,43328,0.0742)
--,(2006,'asx',6,43328,0.1022)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2006,'asx',7,43328,0.0591)
--,(2006,'asx',8,43328,0.0829)
--,(2006,'asx',9,43328,0.0685)
--,(2006,'mlb',1,133347,0.0392)
--,(2006,'mlb',2,133347,0.0041)
--,(2006,'mlb',3,133347,0.0464)
--,(2006,'mlb',4,133347,0.0879)
--,(2006,'mlb',5,133347,0.0733)
--,(2006,'mlb',6,133347,0.0942)
--,(2006,'mlb',7,133347,0.0702)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2006,'mlb',8,133347,0.0924)
--,(2006,'mlb',9,133347,0.0754)
--,(2006,'rok',1,134335,0.0447)
--,(2006,'rok',2,134335,0.0041)
--,(2006,'rok',3,134335,0.0263)
--,(2006,'rok',4,134335,0.0851)
--,(2006,'rok',5,134335,0.0866)
--,(2006,'rok',6,134335,0.1094)
--,(2006,'rok',7,134335,0.0521)
--,(2006,'rok',8,134335,0.0753)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2006,'rok',9,134335,0.0607)
--,(2007,'aaa',1,116367,0.0401)
--,(2007,'aaa',2,116367,0.0041)
--,(2007,'aaa',3,116367,0.0334)
--,(2007,'aaa',4,116367,0.0893)
--,(2007,'aaa',5,116367,0.0712)
--,(2007,'aaa',6,116367,0.0957)
--,(2007,'aaa',7,116367,0.0654)
--,(2007,'aaa',8,116367,0.0907)
--,(2007,'aaa',9,116367,0.0708)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2007,'aax',1,112096,0.0385)
--,(2007,'aax',2,112096,0.0035)
--,(2007,'aax',3,112096,0.0342)
--,(2007,'aax',4,112096,0.0891)
--,(2007,'aax',5,112096,0.0703)
--,(2007,'aax',6,112096,0.0929)
--,(2007,'aax',7,112096,0.0671)
--,(2007,'aax',8,112096,0.0923)
--,(2007,'aax',9,112096,0.0727)
--,(2007,'afa',1,112403,0.0360)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2007,'afa',2,112403,0.0031)
--,(2007,'afa',3,112403,0.0314)
--,(2007,'afa',4,112403,0.0923)
--,(2007,'afa',5,112403,0.0715)
--,(2007,'afa',6,112403,0.1009)
--,(2007,'afa',7,112403,0.0609)
--,(2007,'afa',8,112403,0.0878)
--,(2007,'afa',9,112403,0.0704)
--,(2007,'afx',1,109221,0.0410)
--,(2007,'afx',2,109221,0.0036)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2007,'afx',3,109221,0.0322)
--,(2007,'afx',4,109221,0.0926)
--,(2007,'afx',5,109221,0.0730)
--,(2007,'afx',6,109221,0.1000)
--,(2007,'afx',7,109221,0.0594)
--,(2007,'afx',8,109221,0.0823)
--,(2007,'afx',9,109221,0.0697)
--,(2007,'asx',1,42621,0.0413)
--,(2007,'asx',2,42621,0.0041)
--,(2007,'asx',3,42621,0.0321)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2007,'asx',4,42621,0.0959)
--,(2007,'asx',5,42621,0.0716)
--,(2007,'asx',6,42621,0.1011)
--,(2007,'asx',7,42621,0.0591)
--,(2007,'asx',8,42621,0.0767)
--,(2007,'asx',9,42621,0.0637)
--,(2007,'mlb',1,133618,0.0382)
--,(2007,'mlb',2,133618,0.0044)
--,(2007,'mlb',3,133618,0.0471)
--,(2007,'mlb',4,133618,0.0871)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2007,'mlb',5,133618,0.0701)
--,(2007,'mlb',6,133618,0.0943)
--,(2007,'mlb',7,133618,0.0720)
--,(2007,'mlb',8,133618,0.0960)
--,(2007,'mlb',9,133618,0.0747)
--,(2007,'rok',1,68050,0.0415)
--,(2007,'rok',2,68050,0.0036)
--,(2007,'rok',3,68050,0.0292)
--,(2007,'rok',4,68050,0.0899)
--,(2007,'rok',5,68050,0.0766)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2007,'rok',6,68050,0.1045)
--,(2007,'rok',7,68050,0.0547)
--,(2007,'rok',8,68050,0.0752)
--,(2007,'rok',9,68050,0.0648)
--,(2008,'aaa',1,114422,0.0403)
--,(2008,'aaa',2,114422,0.0046)
--,(2008,'aaa',3,114422,0.0342)
--,(2008,'aaa',4,114422,0.0885)
--,(2008,'aaa',5,114422,0.0701)
--,(2008,'aaa',6,114422,0.0923)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2008,'aaa',7,114422,0.0665)
--,(2008,'aaa',8,114422,0.0883)
--,(2008,'aaa',9,114422,0.0697)
--,(2008,'aax',1,113273,0.0407)
--,(2008,'aax',2,113273,0.0039)
--,(2008,'aax',3,113273,0.0335)
--,(2008,'aax',4,113273,0.0893)
--,(2008,'aax',5,113273,0.0710)
--,(2008,'aax',6,113273,0.0957)
--,(2008,'aax',7,113273,0.0628)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2008,'aax',8,113273,0.0875)
--,(2008,'aax',9,113273,0.0723)
--,(2008,'afa',1,111822,0.0401)
--,(2008,'afa',2,111822,0.0037)
--,(2008,'afa',3,111822,0.0337)
--,(2008,'afa',4,111822,0.0938)
--,(2008,'afa',5,111822,0.0692)
--,(2008,'afa',6,111822,0.0986)
--,(2008,'afa',7,111822,0.0616)
--,(2008,'afa',8,111822,0.0865)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2008,'afa',9,111822,0.0680)
--,(2008,'afx',1,108014,0.0438)
--,(2008,'afx',2,108014,0.0040)
--,(2008,'afx',3,108014,0.0343)
--,(2008,'afx',4,108014,0.0942)
--,(2008,'afx',5,108014,0.0716)
--,(2008,'afx',6,108014,0.0981)
--,(2008,'afx',7,108014,0.0601)
--,(2008,'afx',8,108014,0.0790)
--,(2008,'afx',9,108014,0.0674)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2008,'asx',1,42961,0.0439)
--,(2008,'asx',2,42961,0.0041)
--,(2008,'asx',3,42961,0.0338)
--,(2008,'asx',4,42961,0.0895)
--,(2008,'asx',5,42961,0.0709)
--,(2008,'asx',6,42961,0.0989)
--,(2008,'asx',7,42961,0.0594)
--,(2008,'asx',8,42961,0.0776)
--,(2008,'asx',9,42961,0.0679)
--,(2008,'mlb',1,131843,0.0381)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2008,'mlb',2,131843,0.0043)
--,(2008,'mlb',3,131843,0.0491)
--,(2008,'mlb',4,131843,0.0891)
--,(2008,'mlb',5,131843,0.0718)
--,(2008,'mlb',6,131843,0.0932)
--,(2008,'mlb',7,131843,0.0699)
--,(2008,'mlb',8,131843,0.0953)
--,(2008,'mlb',9,131843,0.0756)
--,(2008,'rok',1,68184,0.0441)
--,(2008,'rok',2,68184,0.0043)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2008,'rok',3,68184,0.0281)
--,(2008,'rok',4,68184,0.0922)
--,(2008,'rok',5,68184,0.0745)
--,(2008,'rok',6,68184,0.1044)
--,(2008,'rok',7,68184,0.0533)
--,(2008,'rok',8,68184,0.0714)
--,(2008,'rok',9,68184,0.0618)
--,(2009,'aaa',1,116926,0.0405)
--,(2009,'aaa',2,116926,0.0041)
--,(2009,'aaa',3,116926,0.0340)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2009,'aaa',4,116926,0.0846)
--,(2009,'aaa',5,116926,0.0691)
--,(2009,'aaa',6,116926,0.0943)
--,(2009,'aaa',7,116926,0.0666)
--,(2009,'aaa',8,116926,0.0960)
--,(2009,'aaa',9,116926,0.0755)
--,(2009,'aax',1,113182,0.0397)
--,(2009,'aax',2,113182,0.0037)
--,(2009,'aax',3,113182,0.0349)
--,(2009,'aax',4,113182,0.0897)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2009,'aax',5,113182,0.0674)
--,(2009,'aax',6,113182,0.0940)
--,(2009,'aax',7,113182,0.0675)
--,(2009,'aax',8,113182,0.0921)
--,(2009,'aax',9,113182,0.0733)
--,(2009,'afa',1,108602,0.0394)
--,(2009,'afa',2,108602,0.0039)
--,(2009,'afa',3,108602,0.0355)
--,(2009,'afa',4,108602,0.0949)
--,(2009,'afa',5,108602,0.0701)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2009,'afa',6,108602,0.0954)
--,(2009,'afa',7,108602,0.0628)
--,(2009,'afa',8,108602,0.0867)
--,(2009,'afa',9,108602,0.0687)
--,(2009,'afx',1,107717,0.0434)
--,(2009,'afx',2,107717,0.0045)
--,(2009,'afx',3,107717,0.0309)
--,(2009,'afx',4,107717,0.0890)
--,(2009,'afx',5,107717,0.0749)
--,(2009,'afx',6,107717,0.0993)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2009,'afx',7,107717,0.0600)
--,(2009,'afx',8,107717,0.0828)
--,(2009,'afx',9,107717,0.0707)
--,(2009,'asx',1,43402,0.0412)
--,(2009,'asx',2,43402,0.0029)
--,(2009,'asx',3,43402,0.0351)
--,(2009,'asx',4,43402,0.0942)
--,(2009,'asx',5,43402,0.0725)
--,(2009,'asx',6,43402,0.0978)
--,(2009,'asx',7,43402,0.0609)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2009,'asx',8,43402,0.0817)
--,(2009,'asx',9,43402,0.0638)
--,(2009,'mlb',1,130217,0.0384)
--,(2009,'mlb',2,130217,0.0045)
--,(2009,'mlb',3,130217,0.0506)
--,(2009,'mlb',4,130217,0.0879)
--,(2009,'mlb',5,130217,0.0703)
--,(2009,'mlb',6,130217,0.0937)
--,(2009,'mlb',7,130217,0.0725)
--,(2009,'mlb',8,130217,0.0963)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2009,'mlb',9,130217,0.0753)
--,(2009,'rok',1,65419,0.0427)
--,(2009,'rok',2,65419,0.0039)
--,(2009,'rok',3,65419,0.0299)
--,(2009,'rok',4,65419,0.0915)
--,(2009,'rok',5,65419,0.0776)
--,(2009,'rok',6,65419,0.1042)
--,(2009,'rok',7,65419,0.0546)
--,(2009,'rok',8,65419,0.0760)
--,(2009,'rok',9,65419,0.0628)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2010,'aaa',1,116341,0.0395)
--,(2010,'aaa',2,116341,0.0042)
--,(2010,'aaa',3,116341,0.0411)
--,(2010,'aaa',4,116341,0.0887)
--,(2010,'aaa',5,116341,0.0678)
--,(2010,'aaa',6,116341,0.0912)
--,(2010,'aaa',7,116341,0.0662)
--,(2010,'aaa',8,116341,0.0926)
--,(2010,'aaa',9,116341,0.0722)
--,(2010,'aax',1,112001,0.0390)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2010,'aax',2,112001,0.0041)
--,(2010,'aax',3,112001,0.0405)
--,(2010,'aax',4,112001,0.0922)
--,(2010,'aax',5,112001,0.0698)
--,(2010,'aax',6,112001,0.0970)
--,(2010,'aax',7,112001,0.0660)
--,(2010,'aax',8,112001,0.0898)
--,(2010,'aax',9,112001,0.0711)
--,(2010,'afa',1,109984,0.0395)
--,(2010,'afa',2,109984,0.0037)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2010,'afa',3,109984,0.0356)
--,(2010,'afa',4,109984,0.0928)
--,(2010,'afa',5,109984,0.0748)
--,(2010,'afa',6,109984,0.0978)
--,(2010,'afa',7,109984,0.0606)
--,(2010,'afa',8,109984,0.0847)
--,(2010,'afa',9,109984,0.0686)
--,(2010,'afx',1,108942,0.0421)
--,(2010,'afx',2,108942,0.0041)
--,(2010,'afx',3,108942,0.0358)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2010,'afx',4,108942,0.0901)
--,(2010,'afx',5,108942,0.0733)
--,(2010,'afx',6,108942,0.0986)
--,(2010,'afx',7,108942,0.0606)
--,(2010,'afx',8,108942,0.0815)
--,(2010,'afx',9,108942,0.0697)
--,(2010,'asx',1,43495,0.0439)
--,(2010,'asx',2,43495,0.0046)
--,(2010,'asx',3,43495,0.0397)
--,(2010,'asx',4,43495,0.0956)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2010,'asx',5,43495,0.0771)
--,(2010,'asx',6,43495,0.1022)
--,(2010,'asx',7,43495,0.0581)
--,(2010,'asx',8,43495,0.0805)
--,(2010,'asx',9,43495,0.0653)
--,(2010,'mlb',1,129279,0.0399)
--,(2010,'mlb',2,129279,0.0047)
--,(2010,'mlb',3,129279,0.0487)
--,(2010,'mlb',4,129279,0.0894)
--,(2010,'mlb',5,129279,0.0716)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2010,'mlb',6,129279,0.0949)
--,(2010,'mlb',7,129279,0.0699)
--,(2010,'mlb',8,129279,0.0969)
--,(2010,'mlb',9,129279,0.0758)
--,(2010,'rok',1,136767,0.0424)
--,(2010,'rok',2,136767,0.0039)
--,(2010,'rok',3,136767,0.0278)
--,(2010,'rok',4,136767,0.0879)
--,(2010,'rok',5,136767,0.0831)
--,(2010,'rok',6,136767,0.1034)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2010,'rok',7,136767,0.0533)
--,(2010,'rok',8,136767,0.0763)
--,(2010,'rok',9,136767,0.0630)
--,(2011,'aaa',1,114467,0.0368)
--,(2011,'aaa',2,114467,0.0040)
--,(2011,'aaa',3,114467,0.0451)
--,(2011,'aaa',4,114467,0.0875)
--,(2011,'aaa',5,114467,0.0694)
--,(2011,'aaa',6,114467,0.0928)
--,(2011,'aaa',7,114467,0.0668)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2011,'aaa',8,114467,0.0943)
--,(2011,'aaa',9,114467,0.0719)
--,(2011,'aax',1,109498,0.0379)
--,(2011,'aax',2,109498,0.0037)
--,(2011,'aax',3,109498,0.0450)
--,(2011,'aax',4,109498,0.0877)
--,(2011,'aax',5,109498,0.0725)
--,(2011,'aax',6,109498,0.0950)
--,(2011,'aax',7,109498,0.0674)
--,(2011,'aax',8,109498,0.0920)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2011,'aax',9,109498,0.0727)
--,(2011,'afa',1,108665,0.0380)
--,(2011,'afa',2,108665,0.0036)
--,(2011,'afa',3,108665,0.0426)
--,(2011,'afa',4,108665,0.0884)
--,(2011,'afa',5,108665,0.0727)
--,(2011,'afa',6,108665,0.0986)
--,(2011,'afa',7,108665,0.0620)
--,(2011,'afa',8,108665,0.0877)
--,(2011,'afa',9,108665,0.0736)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2011,'afx',1,106411,0.0392)
--,(2011,'afx',2,106411,0.0036)
--,(2011,'afx',3,106411,0.0416)
--,(2011,'afx',4,106411,0.0927)
--,(2011,'afx',5,106411,0.0723)
--,(2011,'afx',6,106411,0.0975)
--,(2011,'afx',7,106411,0.0614)
--,(2011,'afx',8,106411,0.0870)
--,(2011,'afx',9,106411,0.0709)
--,(2011,'asx',1,42863,0.0403)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2011,'asx',2,42863,0.0031)
--,(2011,'asx',3,42863,0.0437)
--,(2011,'asx',4,42863,0.0977)
--,(2011,'asx',5,42863,0.0719)
--,(2011,'asx',6,42863,0.0994)
--,(2011,'asx',7,42863,0.0601)
--,(2011,'asx',8,42863,0.0817)
--,(2011,'asx',9,42863,0.0695)
--,(2011,'mlb',1,129605,0.0410)
--,(2011,'mlb',2,129605,0.0049)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2011,'mlb',3,129605,0.0498)
--,(2011,'mlb',4,129605,0.0911)
--,(2011,'mlb',5,129605,0.0701)
--,(2011,'mlb',6,129605,0.0953)
--,(2011,'mlb',7,129605,0.0721)
--,(2011,'mlb',8,129605,0.0944)
--,(2011,'mlb',9,129605,0.0747)
--,(2011,'rok',1,146354,0.0410)
--,(2011,'rok',2,146354,0.0037)
--,(2011,'rok',3,146354,0.0329)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2011,'rok',4,146354,0.0858)
--,(2011,'rok',5,146354,0.0824)
--,(2011,'rok',6,146354,0.1034)
--,(2011,'rok',7,146354,0.0560)
--,(2011,'rok',8,146354,0.0770)
--,(2011,'rok',9,146354,0.0639)
--,(2012,'aaa',1,114649,0.0369)
--,(2012,'aaa',2,114649,0.0041)
--,(2012,'aaa',3,114649,0.0495)
--,(2012,'aaa',4,114649,0.0907)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2012,'aaa',5,114649,0.0676)
--,(2012,'aaa',6,114649,0.0924)
--,(2012,'aaa',7,114649,0.0680)
--,(2012,'aaa',8,114649,0.0918)
--,(2012,'aaa',9,114649,0.0717)
--,(2012,'aax',1,108714,0.0384)
--,(2012,'aax',2,108714,0.0039)
--,(2012,'aax',3,108714,0.0427)
--,(2012,'aax',4,108714,0.0883)
--,(2012,'aax',5,108714,0.0760)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2012,'aax',6,108714,0.1007)
--,(2012,'aax',7,108714,0.0639)
--,(2012,'aax',8,108714,0.0908)
--,(2012,'aax',9,108714,0.0737)
--,(2012,'afa',1,107119,0.0371)
--,(2012,'afa',2,107119,0.0036)
--,(2012,'afa',3,107119,0.0424)
--,(2012,'afa',4,107119,0.0881)
--,(2012,'afa',5,107119,0.0731)
--,(2012,'afa',6,107119,0.0996)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2012,'afa',7,107119,0.0631)
--,(2012,'afa',8,107119,0.0890)
--,(2012,'afa',9,107119,0.0729)
--,(2012,'afx',1,108446,0.0395)
--,(2012,'afx',2,108446,0.0038)
--,(2012,'afx',3,108446,0.0433)
--,(2012,'afx',4,108446,0.0924)
--,(2012,'afx',5,108446,0.0722)
--,(2012,'afx',6,108446,0.0997)
--,(2012,'afx',7,108446,0.0622)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2012,'afx',8,108446,0.0848)
--,(2012,'afx',9,108446,0.0712)
--,(2012,'asx',1,43709,0.0413)
--,(2012,'asx',2,43709,0.0035)
--,(2012,'asx',3,43709,0.0415)
--,(2012,'asx',4,43709,0.0917)
--,(2012,'asx',5,43709,0.0738)
--,(2012,'asx',6,43709,0.1018)
--,(2012,'asx',7,43709,0.0599)
--,(2012,'asx',8,43709,0.0828)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2012,'asx',9,43709,0.0682)
--,(2012,'mlb',1,126593,0.0409)
--,(2012,'mlb',2,126593,0.0047)
--,(2012,'mlb',3,126593,0.0498)
--,(2012,'mlb',4,126593,0.0934)
--,(2012,'mlb',5,126593,0.0710)
--,(2012,'mlb',6,126593,0.0968)
--,(2012,'mlb',7,126593,0.0695)
--,(2012,'mlb',8,126593,0.0947)
--,(2012,'mlb',9,126593,0.0738)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2012,'rok',1,143289,0.0401)
--,(2012,'rok',2,143289,0.0036)
--,(2012,'rok',3,143289,0.0350)
--,(2012,'rok',4,143289,0.0879)
--,(2012,'rok',5,143289,0.0817)
--,(2012,'rok',6,143289,0.1019)
--,(2012,'rok',7,143289,0.0559)
--,(2012,'rok',8,143289,0.0774)
--,(2012,'rok',9,143289,0.0622)
--,(2013,'aaa',1,111720,0.0381)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2013,'aaa',2,111720,0.0044)
--,(2013,'aaa',3,111720,0.0465)
--,(2013,'aaa',4,111720,0.0891)
--,(2013,'aaa',5,111720,0.0696)
--,(2013,'aaa',6,111720,0.0961)
--,(2013,'aaa',7,111720,0.0652)
--,(2013,'aaa',8,111720,0.0905)
--,(2013,'aaa',9,111720,0.0726)
--,(2013,'aax',1,106599,0.0377)
--,(2013,'aax',2,106599,0.0041)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2013,'aax',3,106599,0.0457)
--,(2013,'aax',4,106599,0.0900)
--,(2013,'aax',5,106599,0.0737)
--,(2013,'aax',6,106599,0.0987)
--,(2013,'aax',7,106599,0.0659)
--,(2013,'aax',8,106599,0.0916)
--,(2013,'aax',9,106599,0.0733)
--,(2013,'afa',1,106540,0.0365)
--,(2013,'afa',2,106540,0.0036)
--,(2013,'afa',3,106540,0.0409)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2013,'afa',4,106540,0.0863)
--,(2013,'afa',5,106540,0.0727)
--,(2013,'afa',6,106540,0.1003)
--,(2013,'afa',7,106540,0.0632)
--,(2013,'afa',8,106540,0.0907)
--,(2013,'afa',9,106540,0.0729)
--,(2013,'afx',1,104863,0.0412)
--,(2013,'afx',2,104863,0.0040)
--,(2013,'afx',3,104863,0.0424)
--,(2013,'afx',4,104863,0.0921)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2013,'afx',5,104863,0.0738)
--,(2013,'afx',6,104863,0.1005)
--,(2013,'afx',7,104863,0.0612)
--,(2013,'afx',8,104863,0.0845)
--,(2013,'afx',9,104863,0.0689)
--,(2013,'asx',1,42225,0.0406)
--,(2013,'asx',2,42225,0.0049)
--,(2013,'asx',3,42225,0.0441)
--,(2013,'asx',4,42225,0.0994)
--,(2013,'asx',5,42225,0.0739)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2013,'asx',6,42225,0.1022)
--,(2013,'asx',7,42225,0.0617)
--,(2013,'asx',8,42225,0.0782)
--,(2013,'asx',9,42225,0.0652)
--,(2013,'mlb',1,127302,0.0397)
--,(2013,'mlb',2,127302,0.0046)
--,(2013,'mlb',3,127302,0.0499)
--,(2013,'mlb',4,127302,0.0915)
--,(2013,'mlb',5,127302,0.0718)
--,(2013,'mlb',6,127302,0.0957)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2013,'mlb',7,127302,0.0702)
--,(2013,'mlb',8,127302,0.0962)
--,(2013,'mlb',9,127302,0.0767)
--,(2013,'rok',1,75063,0.0390)
--,(2013,'rok',2,75063,0.0039)
--,(2013,'rok',3,75063,0.0401)
--,(2013,'rok',4,75063,0.0917)
--,(2013,'rok',5,75063,0.0751)
--,(2013,'rok',6,75063,0.1043)
--,(2013,'rok',7,75063,0.0571)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2013,'rok',8,75063,0.0782)
--,(2013,'rok',9,75063,0.0649)
--,(2014,'aaa',1,112024,0.0368)
--,(2014,'aaa',2,112024,0.0038)
--,(2014,'aaa',3,112024,0.0455)
--,(2014,'aaa',4,112024,0.0893)
--,(2014,'aaa',5,112024,0.0696)
--,(2014,'aaa',6,112024,0.0942)
--,(2014,'aaa',7,112024,0.0670)
--,(2014,'aaa',8,112024,0.0924)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2014,'aaa',9,112024,0.0723)
--,(2014,'aax',1,109433,0.0368)
--,(2014,'aax',2,109433,0.0038)
--,(2014,'aax',3,109433,0.0403)
--,(2014,'aax',4,109433,0.0881)
--,(2014,'aax',5,109433,0.0740)
--,(2014,'aax',6,109433,0.0977)
--,(2014,'aax',7,109433,0.0663)
--,(2014,'aax',8,109433,0.0941)
--,(2014,'aax',9,109433,0.0775)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2014,'afa',1,104423,0.0368)
--,(2014,'afa',2,104423,0.0032)
--,(2014,'afa',3,104423,0.0420)
--,(2014,'afa',4,104423,0.0928)
--,(2014,'afa',5,104423,0.0719)
--,(2014,'afa',6,104423,0.0998)
--,(2014,'afa',7,104423,0.0634)
--,(2014,'afa',8,104423,0.0879)
--,(2014,'afa',9,104423,0.0710)
--,(2014,'afx',1,107255,0.0383)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2014,'afx',2,107255,0.0036)
--,(2014,'afx',3,107255,0.0445)
--,(2014,'afx',4,107255,0.0915)
--,(2014,'afx',5,107255,0.0726)
--,(2014,'afx',6,107255,0.0977)
--,(2014,'afx',7,107255,0.0625)
--,(2014,'afx',8,107255,0.0856)
--,(2014,'afx',9,107255,0.0695)
--,(2014,'asx',1,43395,0.0366)
--,(2014,'asx',2,43395,0.0038)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2014,'asx',3,43395,0.0442)
--,(2014,'asx',4,43395,0.0972)
--,(2014,'asx',5,43395,0.0712)
--,(2014,'asx',6,43395,0.1044)
--,(2014,'asx',7,43395,0.0598)
--,(2014,'asx',8,43395,0.0816)
--,(2014,'asx',9,43395,0.0659)
--,(2014,'mlb',1,126607,0.0379)
--,(2014,'mlb',2,126607,0.0044)
--,(2014,'mlb',3,126607,0.0510)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2014,'mlb',4,126607,0.0921)
--,(2014,'mlb',5,126607,0.0707)
--,(2014,'mlb',6,126607,0.0958)
--,(2014,'mlb',7,126607,0.0712)
--,(2014,'mlb',8,126607,0.0972)
--,(2014,'mlb',9,126607,0.0766)
--,(2014,'rok',1,147885,0.0377)
--,(2014,'rok',2,147885,0.0037)
--,(2014,'rok',3,147885,0.0359)
--,(2014,'rok',4,147885,0.0889)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2014,'rok',5,147885,0.0786)
--,(2014,'rok',6,147885,0.1015)
--,(2014,'rok',7,147885,0.0577)
--,(2014,'rok',8,147885,0.0803)
--,(2014,'rok',9,147885,0.0636)
--,(2015,'aaa',1,114899,0.0378)
--,(2015,'aaa',2,114899,0.0044)
--,(2015,'aaa',3,114899,0.0423)
--,(2015,'aaa',4,114899,0.0884)
--,(2015,'aaa',5,114899,0.0713)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2015,'aaa',6,114899,0.0960)
--,(2015,'aaa',7,114899,0.0673)
--,(2015,'aaa',8,114899,0.0943)
--,(2015,'aaa',9,114899,0.0755)
--,(2015,'aax',1,109336,0.0363)
--,(2015,'aax',2,109336,0.0038)
--,(2015,'aax',3,109336,0.0438)
--,(2015,'aax',4,109336,0.0886)
--,(2015,'aax',5,109336,0.0684)
--,(2015,'aax',6,109336,0.0963)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2015,'aax',7,109336,0.0710)
--,(2015,'aax',8,109336,0.0938)
--,(2015,'aax',9,109336,0.0747)
--,(2015,'afa',1,108032,0.0370)
--,(2015,'afa',2,108032,0.0039)
--,(2015,'afa',3,108032,0.0427)
--,(2015,'afa',4,108032,0.0918)
--,(2015,'afa',5,108032,0.0693)
--,(2015,'afa',6,108032,0.1003)
--,(2015,'afa',7,108032,0.0664)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2015,'afa',8,108032,0.0896)
--,(2015,'afa',9,108032,0.0722)
--,(2015,'afx',1,108533,0.0400)
--,(2015,'afx',2,108533,0.0042)
--,(2015,'afx',3,108533,0.0428)
--,(2015,'afx',4,108533,0.0899)
--,(2015,'afx',5,108533,0.0725)
--,(2015,'afx',6,108533,0.0966)
--,(2015,'afx',7,108533,0.0631)
--,(2015,'afx',8,108533,0.0889)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2015,'afx',9,108533,0.0704)
--,(2015,'asx',1,43506,0.0378)
--,(2015,'asx',2,43506,0.0034)
--,(2015,'asx',3,43506,0.0409)
--,(2015,'asx',4,43506,0.0958)
--,(2015,'asx',5,43506,0.0703)
--,(2015,'asx',6,43506,0.0973)
--,(2015,'asx',7,43506,0.0630)
--,(2015,'asx',8,43506,0.0846)
--,(2015,'asx',9,43506,0.0683)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2015,'mlb',1,125566,0.0392)
--,(2015,'mlb',2,125566,0.0044)
--,(2015,'mlb',3,125566,0.0482)
--,(2015,'mlb',4,125566,0.0935)
--,(2015,'mlb',5,125566,0.0723)
--,(2015,'mlb',6,125566,0.0988)
--,(2015,'mlb',7,125566,0.0687)
--,(2015,'mlb',8,125566,0.0957)
--,(2015,'mlb',9,125566,0.0749)
--,(2015,'rok',1,156823,0.0374)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2015,'rok',2,156823,0.0035)
--,(2015,'rok',3,156823,0.0366)
--,(2015,'rok',4,156823,0.0882)
--,(2015,'rok',5,156823,0.0758)
--,(2015,'rok',6,156823,0.1003)
--,(2015,'rok',7,156823,0.0586)
--,(2015,'rok',8,156823,0.0808)
--,(2015,'rok',9,156823,0.0641)
--,(2016,'aaa',1,110559,0.0383)
--,(2016,'aaa',2,110559,0.0040)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2016,'aaa',3,110559,0.0429)
--,(2016,'aaa',4,110559,0.0899)
--,(2016,'aaa',5,110559,0.0711)
--,(2016,'aaa',6,110559,0.0979)
--,(2016,'aaa',7,110559,0.0652)
--,(2016,'aaa',8,110559,0.0898)
--,(2016,'aaa',9,110559,0.0745)
--,(2016,'aax',1,107544,0.0369)
--,(2016,'aax',2,107544,0.0042)
--,(2016,'aax',3,107544,0.0424)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2016,'aax',4,107544,0.0904)
--,(2016,'aax',5,107544,0.0704)
--,(2016,'aax',6,107544,0.0974)
--,(2016,'aax',7,107544,0.0681)
--,(2016,'aax',8,107544,0.0942)
--,(2016,'aax',9,107544,0.0752)
--,(2016,'afa',1,106285,0.0365)
--,(2016,'afa',2,106285,0.0033)
--,(2016,'afa',3,106285,0.0434)
--,(2016,'afa',4,106285,0.0882)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2016,'afa',5,106285,0.0698)
--,(2016,'afa',6,106285,0.0959)
--,(2016,'afa',7,106285,0.0661)
--,(2016,'afa',8,106285,0.0915)
--,(2016,'afa',9,106285,0.0727)
--,(2016,'afx',1,104929,0.0395)
--,(2016,'afx',2,104929,0.0043)
--,(2016,'afx',3,104929,0.0455)
--,(2016,'afx',4,104929,0.0904)
--,(2016,'afx',5,104929,0.0691)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2016,'afx',6,104929,0.0920)
--,(2016,'afx',7,104929,0.0676)
--,(2016,'afx',8,104929,0.0895)
--,(2016,'afx',9,104929,0.0710)
--,(2016,'asx',1,42407,0.0382)
--,(2016,'asx',2,42407,0.0035)
--,(2016,'asx',3,42407,0.0420)
--,(2016,'asx',4,42407,0.0923)
--,(2016,'asx',5,42407,0.0733)
--,(2016,'asx',6,42407,0.0981)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2016,'asx',7,42407,0.0627)
--,(2016,'asx',8,42407,0.0833)
--,(2016,'asx',9,42407,0.0681)
--,(2016,'mlb',1,123211,0.0382)
--,(2016,'mlb',2,123211,0.0047)
--,(2016,'mlb',3,123211,0.0470)
--,(2016,'mlb',4,123211,0.0906)
--,(2016,'mlb',5,123211,0.0744)
--,(2016,'mlb',6,123211,0.0964)
--,(2016,'mlb',7,123211,0.0691)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2016,'mlb',8,123211,0.0930)
--,(2016,'mlb',9,123211,0.0778)
--,(2016,'rok',1,151782,0.0373)
--,(2016,'rok',2,151782,0.0033)
--,(2016,'rok',3,151782,0.0363)
--,(2016,'rok',4,151782,0.0869)
--,(2016,'rok',5,151782,0.0775)
--,(2016,'rok',6,151782,0.1019)
--,(2016,'rok',7,151782,0.0603)
--,(2016,'rok',8,151782,0.0820)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2016,'rok',9,151782,0.0630)
--,(2017,'aaa',1,108283,0.0350)
--,(2017,'aaa',2,108283,0.0041)
--,(2017,'aaa',3,108283,0.0446)
--,(2017,'aaa',4,108283,0.0870)
--,(2017,'aaa',5,108283,0.0681)
--,(2017,'aaa',6,108283,0.0940)
--,(2017,'aaa',7,108283,0.0692)
--,(2017,'aaa',8,108283,0.0936)
--,(2017,'aaa',9,108283,0.0733)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2017,'aax',1,105390,0.0370)
--,(2017,'aax',2,105390,0.0043)
--,(2017,'aax',3,105390,0.0424)
--,(2017,'aax',4,105390,0.0881)
--,(2017,'aax',5,105390,0.0696)
--,(2017,'aax',6,105390,0.0933)
--,(2017,'aax',7,105390,0.0677)
--,(2017,'aax',8,105390,0.0959)
--,(2017,'aax',9,105390,0.0756)
--,(2017,'afa',1,103093,0.0378)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2017,'afa',2,103093,0.0039)
--,(2017,'afa',3,103093,0.0421)
--,(2017,'afa',4,103093,0.0870)
--,(2017,'afa',5,103093,0.0708)
--,(2017,'afa',6,103093,0.0914)
--,(2017,'afa',7,103093,0.0661)
--,(2017,'afa',8,103093,0.0936)
--,(2017,'afa',9,103093,0.0743)
--,(2017,'afx',1,103024,0.0380)
--,(2017,'afx',2,103024,0.0042)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2017,'afx',3,103024,0.0419)
--,(2017,'afx',4,103024,0.0872)
--,(2017,'afx',5,103024,0.0678)
--,(2017,'afx',6,103024,0.0947)
--,(2017,'afx',7,103024,0.0690)
--,(2017,'afx',8,103024,0.0911)
--,(2017,'afx',9,103024,0.0734)
--,(2017,'asx',1,41005,0.0348)
--,(2017,'asx',2,41005,0.0035)
--,(2017,'asx',3,41005,0.0422)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2017,'asx',4,41005,0.0896)
--,(2017,'asx',5,41005,0.0702)
--,(2017,'asx',6,41005,0.0990)
--,(2017,'asx',7,41005,0.0649)
--,(2017,'asx',8,41005,0.0822)
--,(2017,'asx',9,41005,0.0700)
--,(2017,'mlb',1,121451,0.0375)
--,(2017,'mlb',2,121451,0.0048)
--,(2017,'mlb',3,121451,0.0480)
--,(2017,'mlb',4,121451,0.0862)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2017,'mlb',5,121451,0.0734)
--,(2017,'mlb',6,121451,0.0967)
--,(2017,'mlb',7,121451,0.0717)
--,(2017,'mlb',8,121451,0.0942)
--,(2017,'mlb',9,121451,0.0767)
--,(2017,'rok',1,149340,0.0339)
--,(2017,'rok',2,149340,0.0031)
--,(2017,'rok',3,149340,0.0358)
--,(2017,'rok',4,149340,0.0847)
--,(2017,'rok',5,149340,0.0751)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2017,'rok',6,149340,0.0977)
--,(2017,'rok',7,149340,0.0608)
--,(2017,'rok',8,149340,0.0852)
--,(2017,'rok',9,149340,0.0671)
--,(2018,'aaa',1,104593,0.0354)
--,(2018,'aaa',2,104593,0.0046)
--,(2018,'aaa',3,104593,0.0432)
--,(2018,'aaa',4,104593,0.0849)
--,(2018,'aaa',5,104593,0.0695)
--,(2018,'aaa',6,104593,0.0911)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2018,'aaa',7,104593,0.0701)
--,(2018,'aaa',8,104593,0.0946)
--,(2018,'aaa',9,104593,0.0781)
--,(2018,'aax',1,102098,0.0346)
--,(2018,'aax',2,102098,0.0038)
--,(2018,'aax',3,102098,0.0437)
--,(2018,'aax',4,102098,0.0827)
--,(2018,'aax',5,102098,0.0686)
--,(2018,'aax',6,102098,0.0910)
--,(2018,'aax',7,102098,0.0698)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2018,'aax',8,102098,0.0992)
--,(2018,'aax',9,102098,0.0778)
--,(2018,'afa',1,100937,0.0340)
--,(2018,'afa',2,100937,0.0036)
--,(2018,'afa',3,100937,0.0437)
--,(2018,'afa',4,100937,0.0853)
--,(2018,'afa',5,100937,0.0664)
--,(2018,'afa',6,100937,0.0919)
--,(2018,'afa',7,100937,0.0719)
--,(2018,'afa',8,100937,0.0936)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2018,'afa',9,100937,0.0763)
--,(2018,'afx',1,99610,0.0359)
--,(2018,'afx',2,99610,0.0038)
--,(2018,'afx',3,99610,0.0425)
--,(2018,'afx',4,99610,0.0847)
--,(2018,'afx',5,99610,0.0674)
--,(2018,'afx',6,99610,0.0910)
--,(2018,'afx',7,99610,0.0672)
--,(2018,'afx',8,99610,0.0890)
--,(2018,'afx',9,99610,0.0761)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2018,'asx',1,40449,0.0339)
--,(2018,'asx',2,40449,0.0038)
--,(2018,'asx',3,40449,0.0418)
--,(2018,'asx',4,40449,0.0864)
--,(2018,'asx',5,40449,0.0711)
--,(2018,'asx',6,40449,0.0961)
--,(2018,'asx',7,40449,0.0665)
--,(2018,'asx',8,40449,0.0908)
--,(2018,'asx',9,40449,0.0730)
--,(2018,'mlb',1,120699,0.0356)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2018,'mlb',2,120699,0.0044)
--,(2018,'mlb',3,120699,0.0465)
--,(2018,'mlb',4,120699,0.0841)
--,(2018,'mlb',5,120699,0.0749)
--,(2018,'mlb',6,120699,0.0946)
--,(2018,'mlb',7,120699,0.0743)
--,(2018,'mlb',8,120699,0.0984)
--,(2018,'mlb',9,120699,0.0782)
--,(2018,'rok',1,157459,0.0338)
--,(2018,'rok',2,157459,0.0035)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2018,'rok',3,157459,0.0365)
--,(2018,'rok',4,157459,0.0853)
--,(2018,'rok',5,157459,0.0735)
--,(2018,'rok',6,157459,0.0947)
--,(2018,'rok',7,157459,0.0627)
--,(2018,'rok',8,157459,0.0836)
--,(2018,'rok',9,157459,0.0661)
--,(2018,'win',1,29586,0.0337)
--,(2018,'win',2,29586,0.0029)
--,(2018,'win',3,29586,0.0381)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2018,'win',4,29586,0.0827)
--,(2018,'win',5,29586,0.0720)
--,(2018,'win',6,29586,0.0960)
--,(2018,'win',7,29586,0.0697)
--,(2018,'win',8,29586,0.0934)
--,(2018,'win',9,29586,0.0778)
--,(2019,'aaa',1,101220,0.0326)
--,(2019,'aaa',2,101220,0.0039)
--,(2019,'aaa',3,101220,0.0420)
--,(2019,'aaa',4,101220,0.0819)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2019,'aaa',5,101220,0.0718)
--,(2019,'aaa',6,101220,0.0932)
--,(2019,'aaa',7,101220,0.0651)
--,(2019,'aaa',8,101220,0.0917)
--,(2019,'aaa',9,101220,0.0797)
--,(2019,'aax',1,97872,0.0350)
--,(2019,'aax',2,97872,0.0037)
--,(2019,'aax',3,97872,0.0457)
--,(2019,'aax',4,97872,0.0869)
--,(2019,'aax',5,97872,0.0648)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2019,'aax',6,97872,0.0889)
--,(2019,'aax',7,97872,0.0738)
--,(2019,'aax',8,97872,0.0994)
--,(2019,'aax',9,97872,0.0788)
--,(2019,'afa',1,96054,0.0335)
--,(2019,'afa',2,96054,0.0036)
--,(2019,'afa',3,96054,0.0403)
--,(2019,'afa',4,96054,0.0812)
--,(2019,'afa',5,96054,0.0690)
--,(2019,'afa',6,96054,0.0927)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2019,'afa',7,96054,0.0712)
--,(2019,'afa',8,96054,0.0965)
--,(2019,'afa',9,96054,0.0770)
--,(2019,'afx',1,97771,0.0346)
--,(2019,'afx',2,97771,0.0039)
--,(2019,'afx',3,97771,0.0410)
--,(2019,'afx',4,97771,0.0848)
--,(2019,'afx',5,97771,0.0684)
--,(2019,'afx',6,97771,0.0921)
--,(2019,'afx',7,97771,0.0699)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2019,'afx',8,97771,0.0928)
--,(2019,'afx',9,97771,0.0752)
--,(2019,'asx',1,38986,0.0326)
--,(2019,'asx',2,38986,0.0034)
--,(2019,'asx',3,38986,0.0377)
--,(2019,'asx',4,38986,0.0826)
--,(2019,'asx',5,38986,0.0734)
--,(2019,'asx',6,38986,0.0937)
--,(2019,'asx',7,38986,0.0687)
--,(2019,'asx',8,38986,0.0904)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2019,'asx',9,38986,0.0757)
--,(2019,'mlb',1,118979,0.0335)
--,(2019,'mlb',2,118979,0.0040)
--,(2019,'mlb',3,118979,0.0480)
--,(2019,'mlb',4,118979,0.0832)
--,(2019,'mlb',5,118979,0.0758)
--,(2019,'mlb',6,118979,0.0958)
--,(2019,'mlb',7,118979,0.0717)
--,(2019,'mlb',8,118979,0.0957)
--,(2019,'mlb',9,118979,0.0799)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2019,'roa',1,30269,0.0308)
--,(2019,'roa',2,30269,0.0027)
--,(2019,'roa',3,30269,0.0404)
--,(2019,'roa',4,30269,0.0868)
--,(2019,'roa',5,30269,0.0683)
--,(2019,'roa',6,30269,0.0928)
--,(2019,'roa',7,30269,0.0668)
--,(2019,'roa',8,30269,0.0881)
--,(2019,'roa',9,30269,0.0682)
--,(2019,'rok',1,49858,0.0319)
--;
--INSERT INTO stats.seasonal_fielding_binomials_league (season,level_text,"position",ch,pm_rt) VALUES 
--(2019,'rok',2,49858,0.0025)
--,(2019,'rok',3,49858,0.0337)
--,(2019,'rok',4,49858,0.0823)
--,(2019,'rok',5,49858,0.0686)
--,(2019,'rok',6,49858,0.0939)
--,(2019,'rok',7,49858,0.0646)
--,(2019,'rok',8,49858,0.0896)
--,(2019,'rok',9,49858,0.0714)
--;
--
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1921,2,8.1314)
--,(1921,3,7.4495)
--,(1921,4,7.3553)
--,(1921,5,7.3255)
--,(1921,6,7.3274)
--,(1921,7,7.2674)
--,(1921,8,7.2596)
--,(1921,9,7.2065)
--,(1922,2,8.0550)
--,(1922,3,7.4235)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1922,4,7.2514)
--,(1922,5,7.4070)
--,(1922,6,7.4022)
--,(1922,7,7.3032)
--,(1922,8,7.2028)
--,(1922,9,7.2975)
--,(1923,2,7.8945)
--,(1923,3,7.4617)
--,(1923,4,7.3949)
--,(1923,5,7.4476)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1923,6,7.5275)
--,(1923,7,7.2773)
--,(1923,8,7.1242)
--,(1923,9,7.2212)
--,(1924,2,8.1710)
--,(1924,3,7.4648)
--,(1924,4,7.3814)
--,(1924,5,7.6069)
--,(1924,6,7.6652)
--,(1924,7,7.2511)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1924,8,7.1669)
--,(1924,9,7.2438)
--,(1925,2,8.1407)
--,(1925,3,7.5180)
--,(1925,4,7.3138)
--,(1925,5,7.4953)
--,(1925,6,7.7132)
--,(1925,7,7.2438)
--,(1925,8,7.2046)
--,(1925,9,7.3241)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1926,2,8.1769)
--,(1926,3,7.4084)
--,(1926,4,7.2781)
--,(1926,5,7.5949)
--,(1926,6,7.6661)
--,(1926,7,7.2525)
--,(1926,8,7.1304)
--,(1926,9,7.2592)
--,(1927,2,8.0939)
--,(1927,3,7.3748)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1927,4,7.3512)
--,(1927,5,7.4257)
--,(1927,6,7.6418)
--,(1927,7,7.2948)
--,(1927,8,7.1685)
--,(1927,9,7.2257)
--,(1928,2,8.0656)
--,(1928,3,7.3251)
--,(1928,4,7.1791)
--,(1928,5,7.4084)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1928,6,7.7027)
--,(1928,7,7.2618)
--,(1928,8,7.0489)
--,(1928,9,7.2508)
--,(1929,2,8.0906)
--,(1929,3,7.3220)
--,(1929,4,7.4002)
--,(1929,5,7.2831)
--,(1929,6,7.7135)
--,(1929,7,7.2088)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1929,8,7.0863)
--,(1929,9,7.2323)
--,(1930,2,7.9292)
--,(1930,3,7.2477)
--,(1930,4,7.2196)
--,(1930,5,7.3043)
--,(1930,6,7.6040)
--,(1930,7,7.1577)
--,(1930,8,7.0681)
--,(1930,9,7.1452)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1931,2,7.8784)
--,(1931,3,7.2029)
--,(1931,4,7.2658)
--,(1931,5,7.3597)
--,(1931,6,7.5527)
--,(1931,7,7.1447)
--,(1931,8,6.9999)
--,(1931,9,7.1262)
--,(1932,2,7.8176)
--,(1932,3,7.2687)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1932,4,7.1663)
--,(1932,5,7.3928)
--,(1932,6,7.5788)
--,(1932,7,7.1764)
--,(1932,8,6.9663)
--,(1932,9,7.1384)
--,(1933,2,7.9408)
--,(1933,3,7.3370)
--,(1933,4,7.3488)
--,(1933,5,7.2847)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1933,6,7.6544)
--,(1933,7,7.2103)
--,(1933,8,7.0456)
--,(1933,9,7.1609)
--,(1934,2,7.8676)
--,(1934,3,7.1214)
--,(1934,4,7.0883)
--,(1934,5,7.2204)
--,(1934,6,7.1745)
--,(1934,7,7.0441)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1934,8,6.9980)
--,(1934,9,7.0522)
--,(1935,2,7.7448)
--,(1935,3,7.1527)
--,(1935,4,7.3557)
--,(1935,5,7.2670)
--,(1935,6,7.3079)
--,(1935,7,6.9494)
--,(1935,8,7.0518)
--,(1935,9,7.1029)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1936,2,7.7038)
--,(1936,3,7.1199)
--,(1936,4,7.3241)
--,(1936,5,7.2583)
--,(1936,6,7.3443)
--,(1936,7,6.9819)
--,(1936,8,6.9142)
--,(1936,9,7.0159)
--,(1937,2,7.3994)
--,(1937,3,6.8573)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1937,4,7.1344)
--,(1937,5,6.9552)
--,(1937,6,7.0615)
--,(1937,7,6.7877)
--,(1937,8,6.6313)
--,(1937,9,6.8159)
--,(1938,2,7.4342)
--,(1938,3,6.9915)
--,(1938,4,7.0575)
--,(1938,5,6.9125)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1938,6,7.1559)
--,(1938,7,6.8407)
--,(1938,8,6.8558)
--,(1938,9,6.7819)
--,(1939,2,6.7939)
--,(1939,3,6.3457)
--,(1939,4,6.3406)
--,(1939,5,6.3526)
--,(1939,6,6.5519)
--,(1939,7,6.2822)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1939,8,6.1877)
--,(1939,9,6.2231)
--,(1940,2,6.9821)
--,(1940,3,6.4869)
--,(1940,4,6.5104)
--,(1940,5,6.3805)
--,(1940,6,6.7262)
--,(1940,7,6.4032)
--,(1940,8,6.2648)
--,(1940,9,6.2935)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1941,2,6.9323)
--,(1941,3,6.2592)
--,(1941,4,6.3285)
--,(1941,5,6.2627)
--,(1941,6,6.4815)
--,(1941,7,6.2704)
--,(1941,8,6.1606)
--,(1941,9,6.1959)
--,(1942,2,6.8875)
--,(1942,3,6.2496)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1942,4,6.3591)
--,(1942,5,6.1599)
--,(1942,6,6.3921)
--,(1942,7,6.2144)
--,(1942,8,6.0809)
--,(1942,9,6.1350)
--,(1943,2,6.7778)
--,(1943,3,6.2894)
--,(1943,4,6.2124)
--,(1943,5,6.2357)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1943,6,6.3199)
--,(1943,7,6.1428)
--,(1943,8,5.9992)
--,(1943,9,6.0517)
--,(1944,2,7.3994)
--,(1944,3,6.8905)
--,(1944,4,6.9076)
--,(1944,5,7.1257)
--,(1944,6,7.4480)
--,(1944,7,6.8662)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1944,8,6.7112)
--,(1944,9,6.7811)
--,(1945,2,7.5405)
--,(1945,3,6.8112)
--,(1945,4,6.7563)
--,(1945,5,6.9703)
--,(1945,6,7.1885)
--,(1945,7,6.7583)
--,(1945,8,6.7319)
--,(1945,9,6.6681)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1946,2,7.0667)
--,(1946,3,6.5011)
--,(1946,4,6.4209)
--,(1946,5,6.4979)
--,(1946,6,6.5984)
--,(1946,7,6.4313)
--,(1946,8,6.3667)
--,(1946,9,6.3632)
--,(1947,2,7.2508)
--,(1947,3,6.6546)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1947,4,6.7108)
--,(1947,5,6.6905)
--,(1947,6,6.7656)
--,(1947,7,6.6179)
--,(1947,8,6.5303)
--,(1947,9,6.5282)
--,(1948,2,7.3896)
--,(1948,3,6.8250)
--,(1948,4,6.6902)
--,(1948,5,6.6646)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1948,6,6.8540)
--,(1948,7,6.6428)
--,(1948,8,6.6085)
--,(1948,9,6.7049)
--,(1949,2,7.4580)
--,(1949,3,6.8542)
--,(1949,4,6.8572)
--,(1949,5,6.8028)
--,(1949,6,6.7817)
--,(1949,7,6.6950)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1949,8,6.6539)
--,(1949,9,6.8428)
--,(1950,2,7.3790)
--,(1950,3,6.7738)
--,(1950,4,6.8877)
--,(1950,5,6.7681)
--,(1950,6,6.8700)
--,(1950,7,6.6601)
--,(1950,8,6.6451)
--,(1950,9,6.7510)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1951,2,7.5440)
--,(1951,3,6.9373)
--,(1951,4,6.9136)
--,(1951,5,6.9225)
--,(1951,6,7.0865)
--,(1951,7,6.8492)
--,(1951,8,6.7864)
--,(1951,9,6.8984)
--,(1952,2,7.3343)
--,(1952,3,6.8434)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1952,4,6.8161)
--,(1952,5,6.8265)
--,(1952,6,6.9377)
--,(1952,7,6.8167)
--,(1952,8,6.6696)
--,(1952,9,6.8043)
--,(1953,2,7.4486)
--,(1953,3,6.7858)
--,(1953,4,6.7709)
--,(1953,5,6.8438)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1953,6,6.9777)
--,(1953,7,6.7891)
--,(1953,8,6.8126)
--,(1953,9,6.8812)
--,(1954,2,7.4000)
--,(1954,3,6.7943)
--,(1954,4,6.7965)
--,(1954,5,6.8348)
--,(1954,6,7.0303)
--,(1954,7,6.8164)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1954,8,6.7138)
--,(1954,9,6.9218)
--,(1955,2,7.1948)
--,(1955,3,6.7036)
--,(1955,4,6.6135)
--,(1955,5,6.7208)
--,(1955,6,7.0616)
--,(1955,7,6.6894)
--,(1955,8,6.5853)
--,(1955,9,6.5937)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1956,2,7.1868)
--,(1956,3,6.6452)
--,(1956,4,6.6793)
--,(1956,5,6.7706)
--,(1956,6,7.0128)
--,(1956,7,6.6499)
--,(1956,8,6.6626)
--,(1956,9,6.6928)
--,(1957,2,7.3202)
--,(1957,3,6.6686)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1957,4,6.6259)
--,(1957,5,6.8761)
--,(1957,6,7.0518)
--,(1957,7,6.6882)
--,(1957,8,6.7063)
--,(1957,9,6.7635)
--,(1958,2,7.2152)
--,(1958,3,6.7065)
--,(1958,4,6.6671)
--,(1958,5,6.7664)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1958,6,7.1186)
--,(1958,7,6.7054)
--,(1958,8,6.5988)
--,(1958,9,6.6894)
--,(1959,2,7.2031)
--,(1959,3,6.6570)
--,(1959,4,6.6890)
--,(1959,5,6.7056)
--,(1959,6,7.0950)
--,(1959,7,6.6825)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1959,8,6.5081)
--,(1959,9,6.6557)
--,(1960,2,7.2409)
--,(1960,3,6.7119)
--,(1960,4,6.7139)
--,(1960,5,6.7127)
--,(1960,6,7.0215)
--,(1960,7,6.6126)
--,(1960,8,6.5317)
--,(1960,9,6.6348)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1961,2,7.1352)
--,(1961,3,6.6836)
--,(1961,4,6.5228)
--,(1961,5,6.6871)
--,(1961,6,6.7634)
--,(1961,7,6.5643)
--,(1961,8,6.4318)
--,(1961,9,6.5376)
--,(1962,2,7.1209)
--,(1962,3,6.5920)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1962,4,6.5741)
--,(1962,5,6.6963)
--,(1962,6,6.8227)
--,(1962,7,6.5380)
--,(1962,8,6.3784)
--,(1962,9,6.5881)
--,(1963,2,7.0939)
--,(1963,3,6.6406)
--,(1963,4,6.4927)
--,(1963,5,6.6493)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1963,6,6.7576)
--,(1963,7,6.5130)
--,(1963,8,6.4475)
--,(1963,9,6.5264)
--,(1964,2,7.0530)
--,(1964,3,6.6208)
--,(1964,4,6.6237)
--,(1964,5,6.5709)
--,(1964,6,6.6306)
--,(1964,7,6.5040)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1964,8,6.4518)
--,(1964,9,6.5069)
--,(1965,2,7.1075)
--,(1965,3,6.5370)
--,(1965,4,6.5575)
--,(1965,5,6.5064)
--,(1965,6,6.6744)
--,(1965,7,6.4415)
--,(1965,8,6.4390)
--,(1965,9,6.4882)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1966,2,7.1292)
--,(1966,3,6.6312)
--,(1966,4,6.6691)
--,(1966,5,6.5976)
--,(1966,6,6.6337)
--,(1966,7,6.5976)
--,(1966,8,6.4534)
--,(1966,9,6.5334)
--,(1967,2,7.1216)
--,(1967,3,6.5477)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1967,4,6.6196)
--,(1967,5,6.5069)
--,(1967,6,6.8050)
--,(1967,7,6.4364)
--,(1967,8,6.4630)
--,(1967,9,6.4939)
--,(1968,2,7.0450)
--,(1968,3,6.5823)
--,(1968,4,6.6184)
--,(1968,5,6.6572)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1968,6,6.9010)
--,(1968,7,6.5217)
--,(1968,8,6.4476)
--,(1968,9,6.5409)
--,(1969,2,6.9840)
--,(1969,3,6.4424)
--,(1969,4,6.4312)
--,(1969,5,6.5153)
--,(1969,6,6.6971)
--,(1969,7,6.3447)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1969,8,6.3043)
--,(1969,9,6.3267)
--,(1970,2,6.9475)
--,(1970,3,6.5096)
--,(1970,4,6.4882)
--,(1970,5,6.5506)
--,(1970,6,6.6686)
--,(1970,7,6.3731)
--,(1970,8,6.3110)
--,(1970,9,6.3999)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1971,2,7.0831)
--,(1971,3,6.6538)
--,(1971,4,6.5967)
--,(1971,5,6.7226)
--,(1971,6,6.8561)
--,(1971,7,6.5311)
--,(1971,8,6.6034)
--,(1971,9,6.6058)
--,(1972,2,7.0687)
--,(1972,3,6.6123)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1972,4,6.5762)
--,(1972,5,6.7560)
--,(1972,6,6.8552)
--,(1972,7,6.5188)
--,(1972,8,6.5286)
--,(1972,9,6.5958)
--,(1973,2,7.2002)
--,(1973,3,6.7477)
--,(1973,4,6.7328)
--,(1973,5,6.8131)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1973,6,7.1268)
--,(1973,7,6.5960)
--,(1973,8,6.6419)
--,(1973,9,6.6624)
--,(1974,2,7.4158)
--,(1974,3,6.8679)
--,(1974,4,6.8391)
--,(1974,5,6.9329)
--,(1974,6,7.2893)
--,(1974,7,6.6479)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1974,8,6.6387)
--,(1974,9,6.7544)
--,(1975,2,7.3531)
--,(1975,3,6.7936)
--,(1975,4,6.7900)
--,(1975,5,6.9514)
--,(1975,6,7.2857)
--,(1975,7,6.6627)
--,(1975,8,6.6144)
--,(1975,9,6.7518)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1976,2,7.4904)
--,(1976,3,6.8633)
--,(1976,4,7.0468)
--,(1976,5,7.0188)
--,(1976,6,7.2485)
--,(1976,7,6.7357)
--,(1976,8,6.6847)
--,(1976,9,6.9199)
--,(1977,2,7.3340)
--,(1977,3,6.7241)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1977,4,6.8541)
--,(1977,5,6.8096)
--,(1977,6,7.0416)
--,(1977,7,6.6780)
--,(1977,8,6.6819)
--,(1977,9,6.7507)
--,(1978,2,7.3852)
--,(1978,3,6.8539)
--,(1978,4,6.9978)
--,(1978,5,6.9822)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1978,6,7.1029)
--,(1978,7,6.8069)
--,(1978,8,6.7390)
--,(1978,9,6.8343)
--,(1979,2,7.3966)
--,(1979,3,6.8072)
--,(1979,4,7.0032)
--,(1979,5,6.9653)
--,(1979,6,7.1208)
--,(1979,7,6.8084)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1979,8,6.6822)
--,(1979,9,6.8154)
--,(1980,2,7.4953)
--,(1980,3,6.8443)
--,(1980,4,7.0339)
--,(1980,5,7.0951)
--,(1980,6,7.2124)
--,(1980,7,6.8264)
--,(1980,8,6.7307)
--,(1980,9,6.9188)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1981,2,7.4364)
--,(1981,3,6.8867)
--,(1981,4,7.0132)
--,(1981,5,7.1134)
--,(1981,6,7.3670)
--,(1981,7,6.7617)
--,(1981,8,6.7240)
--,(1981,9,6.9224)
--,(1982,2,7.3326)
--,(1982,3,6.7935)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1982,4,6.8256)
--,(1982,5,6.8941)
--,(1982,6,7.4160)
--,(1982,7,6.6849)
--,(1982,8,6.6971)
--,(1982,9,6.8465)
--,(1983,2,7.4417)
--,(1983,3,6.7490)
--,(1983,4,6.8165)
--,(1983,5,6.8701)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1983,6,7.1642)
--,(1983,7,6.6454)
--,(1983,8,6.6597)
--,(1983,9,6.8206)
--,(1984,2,7.2926)
--,(1984,3,6.7407)
--,(1984,4,6.7295)
--,(1984,5,6.9650)
--,(1984,6,7.3711)
--,(1984,7,6.7178)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1984,8,6.5383)
--,(1984,9,6.7455)
--,(1985,2,7.3102)
--,(1985,3,6.6240)
--,(1985,4,6.7497)
--,(1985,5,6.8595)
--,(1985,6,7.1891)
--,(1985,7,6.6373)
--,(1985,8,6.5335)
--,(1985,9,6.6731)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1986,2,7.1858)
--,(1986,3,6.4771)
--,(1986,4,6.6338)
--,(1986,5,6.6323)
--,(1986,6,6.9628)
--,(1986,7,6.4950)
--,(1986,8,6.3482)
--,(1986,9,6.5086)
--,(1987,2,7.0836)
--,(1987,3,6.4618)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1987,4,6.5419)
--,(1987,5,6.6360)
--,(1987,6,6.8264)
--,(1987,7,6.3908)
--,(1987,8,6.3196)
--,(1987,9,6.5045)
--,(1988,2,7.2646)
--,(1988,3,6.6631)
--,(1988,4,6.7303)
--,(1988,5,6.8273)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1988,6,7.0758)
--,(1988,7,6.5677)
--,(1988,8,6.5004)
--,(1988,9,6.7044)
--,(1989,2,7.3257)
--,(1989,3,6.6408)
--,(1989,4,6.6301)
--,(1989,5,6.7824)
--,(1989,6,7.0351)
--,(1989,7,6.5637)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1989,8,6.4426)
--,(1989,9,6.7453)
--,(1990,2,7.1823)
--,(1990,3,6.6195)
--,(1990,4,6.6328)
--,(1990,5,6.6681)
--,(1990,6,7.0525)
--,(1990,7,6.5645)
--,(1990,8,6.4464)
--,(1990,9,6.7007)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1991,2,7.1530)
--,(1991,3,6.5419)
--,(1991,4,6.6248)
--,(1991,5,6.7305)
--,(1991,6,7.0947)
--,(1991,7,6.5098)
--,(1991,8,6.3910)
--,(1991,9,6.6385)
--,(1992,2,7.2441)
--,(1992,3,6.6834)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1992,4,6.7549)
--,(1992,5,6.7580)
--,(1992,6,7.0113)
--,(1992,7,6.5706)
--,(1992,8,6.4614)
--,(1992,9,6.6875)
--,(1993,2,7.1279)
--,(1993,3,6.5792)
--,(1993,4,6.5619)
--,(1993,5,6.6800)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1993,6,6.8516)
--,(1993,7,6.4968)
--,(1993,8,6.3350)
--,(1993,9,6.5969)
--,(1994,2,6.9123)
--,(1994,3,6.4271)
--,(1994,4,6.4828)
--,(1994,5,6.5151)
--,(1994,6,6.6824)
--,(1994,7,6.3729)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1994,8,6.1742)
--,(1994,9,6.4546)
--,(1995,2,6.9703)
--,(1995,3,6.3863)
--,(1995,4,6.3978)
--,(1995,5,6.5505)
--,(1995,6,6.6234)
--,(1995,7,6.3760)
--,(1995,8,6.0927)
--,(1995,9,6.4587)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1996,2,6.8298)
--,(1996,3,6.3299)
--,(1996,4,6.2778)
--,(1996,5,6.4950)
--,(1996,6,6.6644)
--,(1996,7,6.3043)
--,(1996,8,6.1246)
--,(1996,9,6.3943)
--,(1997,2,6.8212)
--,(1997,3,6.3023)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1997,4,6.2359)
--,(1997,5,6.3974)
--,(1997,6,6.5996)
--,(1997,7,6.3089)
--,(1997,8,6.1402)
--,(1997,9,6.3568)
--,(1998,2,6.9014)
--,(1998,3,6.3040)
--,(1998,4,6.2663)
--,(1998,5,6.4198)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1998,6,6.5830)
--,(1998,7,6.3160)
--,(1998,8,6.1337)
--,(1998,9,6.3195)
--,(1999,2,6.8268)
--,(1999,3,6.3006)
--,(1999,4,6.1539)
--,(1999,5,6.4492)
--,(1999,6,6.4689)
--,(1999,7,6.2280)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(1999,8,6.2278)
--,(1999,9,6.2663)
--,(2000,2,6.8000)
--,(2000,3,6.2816)
--,(2000,4,6.1444)
--,(2000,5,6.4566)
--,(2000,6,6.4172)
--,(2000,7,6.2078)
--,(2000,8,6.1616)
--,(2000,9,6.2564)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(2001,2,6.8609)
--,(2001,3,6.2975)
--,(2001,4,6.2229)
--,(2001,5,6.4226)
--,(2001,6,6.3303)
--,(2001,7,6.2391)
--,(2001,8,6.1765)
--,(2001,9,6.2546)
--,(2002,2,6.8899)
--,(2002,3,6.3616)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(2002,4,6.3014)
--,(2002,5,6.4087)
--,(2002,6,6.3562)
--,(2002,7,6.3112)
--,(2002,8,6.2020)
--,(2002,9,6.3376)
--,(2003,2,6.9066)
--,(2003,3,6.3935)
--,(2003,4,6.3061)
--,(2003,5,6.4927)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(2003,6,6.4852)
--,(2003,7,6.3326)
--,(2003,8,6.2384)
--,(2003,9,6.3692)
--,(2004,2,6.8195)
--,(2004,3,6.3222)
--,(2004,4,6.3008)
--,(2004,5,6.3575)
--,(2004,6,6.2920)
--,(2004,7,6.3108)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(2004,8,6.2262)
--,(2004,9,6.3429)
--,(2005,2,6.9313)
--,(2005,3,6.4211)
--,(2005,4,6.3945)
--,(2005,5,6.5196)
--,(2005,6,6.3910)
--,(2005,7,6.3711)
--,(2005,8,6.3279)
--,(2005,9,6.4629)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(2006,2,6.7523)
--,(2006,3,6.3746)
--,(2006,4,6.3295)
--,(2006,5,6.4045)
--,(2006,6,6.3668)
--,(2006,7,6.3016)
--,(2006,8,6.2362)
--,(2006,9,6.3735)
--,(2007,2,6.8171)
--,(2007,3,6.3637)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(2007,4,6.2898)
--,(2007,5,6.4271)
--,(2007,6,6.3699)
--,(2007,7,6.3515)
--,(2007,8,6.1936)
--,(2007,9,6.3471)
--,(2008,2,6.7269)
--,(2008,3,6.3283)
--,(2008,4,6.1931)
--,(2008,5,6.4125)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(2008,6,6.3412)
--,(2008,7,6.2446)
--,(2008,8,6.2046)
--,(2008,9,6.2573)
--,(2009,2,6.6751)
--,(2009,3,6.2130)
--,(2009,4,6.1842)
--,(2009,5,6.2586)
--,(2009,6,6.3234)
--,(2009,7,6.1780)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(2009,8,6.1174)
--,(2009,9,6.2532)
--,(2010,2,6.6835)
--,(2010,3,6.1980)
--,(2010,4,6.1628)
--,(2010,5,6.3010)
--,(2010,6,6.3492)
--,(2010,7,6.2481)
--,(2010,8,6.1503)
--,(2010,9,6.2186)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(2011,2,6.7705)
--,(2011,3,6.2568)
--,(2011,4,6.2199)
--,(2011,5,6.4048)
--,(2011,6,6.2564)
--,(2011,7,6.2370)
--,(2011,8,6.0986)
--,(2011,9,6.2352)
--,(2012,2,6.5971)
--,(2012,3,6.1853)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(2012,4,6.1539)
--,(2012,5,6.2458)
--,(2012,6,6.2149)
--,(2012,7,6.1214)
--,(2012,8,6.0053)
--,(2012,9,6.0960)
--,(2013,2,6.5567)
--,(2013,3,6.1836)
--,(2013,4,6.1664)
--,(2013,5,6.2320)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(2013,6,6.3265)
--,(2013,7,6.1117)
--,(2013,8,6.0513)
--,(2013,9,6.1265)
--,(2014,2,6.5290)
--,(2014,3,6.1601)
--,(2014,4,6.1845)
--,(2014,5,6.2332)
--,(2014,6,6.3350)
--,(2014,7,6.1767)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(2014,8,6.0398)
--,(2014,9,6.1244)
--,(2015,2,6.5724)
--,(2015,3,6.1102)
--,(2015,4,6.1535)
--,(2015,5,6.0899)
--,(2015,6,6.3005)
--,(2015,7,6.1933)
--,(2015,8,6.0140)
--,(2015,9,6.0693)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(2016,2,6.4106)
--,(2016,3,5.9699)
--,(2016,4,5.9073)
--,(2016,5,5.9556)
--,(2016,6,6.0636)
--,(2016,7,6.0314)
--,(2016,8,5.9206)
--,(2016,9,5.9420)
--,(2017,2,6.3004)
--,(2017,3,5.8358)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(2017,4,5.8125)
--,(2017,5,5.8963)
--,(2017,6,5.9638)
--,(2017,7,5.8709)
--,(2017,8,5.8406)
--,(2017,9,5.8071)
--,(2018,2,6.2784)
--,(2018,3,5.7896)
--,(2018,4,5.8027)
--,(2018,5,5.8178)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(2018,6,5.8917)
--,(2018,7,5.8063)
--,(2018,8,5.9177)
--,(2018,9,5.7745)
--,(2019,2,6.1437)
--,(2019,3,5.6739)
--,(2019,4,5.7901)
--,(2019,5,5.6869)
--,(2019,6,5.6983)
--,(2019,7,5.6867)
--;
--insert into stats.ch_per_pa_lg (year_id,pos,ch_per_pa) values 
--(2019,8,5.7999)
--,(2019,9,5.6139)
--;
  