
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
	+ a.out_pa*1.06* c.bip_out 
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
	+ a.out_pa*1.06* c.bip_out 
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
select *,  ip*(3/(so_pa+out_pa*1.06)) as expected_pa from stats.pecota_pitching_raw a left join stats.pecota_pitcher_extended_lines b using (bpid);
 


CREATE MATERIALIZED VIEW stats.pecota_pitching_lines_park_adj as  
select *,  ip*(3/(so_pa+out_pa*1.06)) as expected_pa from stats.pecota_pitching_park_adj a left join stats.pecota_pitcher_extended_lines_park_adj b using (bpid);
 

drop   MATERIALIZED VIEW stats.bp_pecota2020__projected_fielder_position  ;

CREATE MATERIALIZED VIEW stats.bp_pecota2020__projected_fielder_position
as 
with total_def as (
select bpid , (pt_c+pt_1b+pt_2b+pt_3b+pt_ss+pt_lf+pt_cf+pt_rf+pt_dh + pt_ph/5 )::numeric as total_defense_time from  entitas.depth_chart_batters
),
 fake_lines as (
	with total_def_fake as (
		with non_dc_pt as (
			with all_pos as (select bpid, case when "position">9 then 3 else "position" end as pos, ch as pt from stats.pecota_fielder_binomials where "position" > 1 )
		select a.bpid
		,sum(case when pos=2 then pt else 0 end) as pt_c
		,sum(case when pos=3 then pt else 0 end) as pt_1b
		,sum(case when pos=4 then pt else 0 end) as pt_2b
		,sum(case when pos=5 then pt else 0 end) as pt_3b
		,sum(case when pos=6 then pt else 0 end) as pt_ss
		,sum(case when pos=7 then pt else 0 end) as pt_lf
		,sum(case when pos=8 then pt else 0 end) as pt_cf
		,sum(case when pos=9 then pt else 0 end) as pt_rf
		from all_pos a
		left join entitas.depth_chart_batters b on (a.bpid = b.bpid) where b.bpid is null
		group by a.bpid
	)
	select  
	(pt_c+pt_1b+pt_2b+pt_3b+pt_ss+pt_lf+pt_cf+pt_rf ) as total_defense_time, *
	from non_dc_pt
)
select 
bpid,total_defense_time
, pt_c/total_defense_time as pt_c
, pt_1b/total_defense_time as pt_1b
, pt_2b/total_defense_time as pt_2b
, pt_3b/total_defense_time as pt_3b
, pt_ss/total_defense_time as pt_ss
, pt_lf/total_defense_time as pt_lf
, pt_cf/total_defense_time as pt_cf
, pt_rf/total_defense_time as pt_rf
from total_def_fake
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
UNION 
select bpid as flid_id, 2020 as year_proj, pt_c as pa_rt, 2 as pos from fake_lines where pt_c > 0 
union
select bpid as flid_id, 2020 as year_proj, pt_1b as pa_rt, 3 as pos from fake_lines where pt_1b > 0 
union
select bpid as flid_id, 2020 as year_proj, pt_2b as pa_rt, 4 as pos from fake_lines where pt_2b > 0 
union
select bpid as flid_id, 2020 as year_proj, pt_3b as pa_rt, 5 as pos from fake_lines where pt_3b > 0 
union
select bpid as flid_id, 2020 as year_proj, pt_ss as pa_rt, 6 as pos from fake_lines where pt_ss > 0 
union
select bpid as flid_id, 2020 as year_proj, pt_lf as pa_rt, 7 as pos from fake_lines where pt_lf > 0 
union
select bpid as flid_id, 2020 as year_proj, pt_cf as pa_rt, 8 as pos from fake_lines where pt_cf > 0 
union
select bpid as flid_id, 2020 as year_proj, pt_rf as pa_rt, 9 as pos from fake_lines where pt_rf > 0 
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
, coalesce(c.pa_expected,251) as pa_tot2
, p.pa_rt as pa_rt2
, coalesce(c.pa_expected,251) * p.pa_rt as pa_c2
, coalesce(c.pa_expected,251) * p.pa_rt * 17 * csaa_rpc *h.csaa_proj as csaa_runs  
, coalesce(c.pa_expected,251) * p.pa_rt * 11 * epaa_rpc * h.epaa_proj as epaa_runs  
, greatest(0,coalesce(c.pa_expected,251) * p.pa_rt * -3 * ((sb_runs_rpc * (sbrate )) + (cs_runs_rpc * (1-(sbrate ))))  * h.traa_proj) as traa_runs   
, coalesce(c.pa_expected,251) * p.pa_rt * -(.17+h.traa_proj) *  (sb_runs_rpc - cs_runs_rpc) *h.sraa_proj as sraa_runs   
from cda_runs  
, stats.bp_pecota2020__projected_fielder_position p
join stats.pecota_batting_lines_park_adj c on (p.fld_id = c.bpid  )
  join  stats.pecota_catcher_fraa  h using (bpid) 
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
 

drop materialized view  if exists stats.bp_pecota2020__fraa_text_pecota;

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


 

drop materialized view if exists stats.bp_pecota2020__pecota_bat_raw;

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
 
drop  MATERIALIZED VIEW if exists stats.bp_pecota2020__pecota_pit_dc;

CREATE MATERIALIZED VIEW stats.bp_pecota2020__pecota_pit_dc
TABLESPACE pg_default
AS 
WITH defaulted AS (
         SELECT pecota_pitching_lines.bpid,
                CASE COALESCE(pecota_pitching_lines.expected_pa, 0::double precision)
                    WHEN 0 THEN 3::double precision *
                    CASE COALESCE(pecota_pitching_lines.ip, 0::double precision)
                        WHEN 0 THEN 35::double precision
                        ELSE pecota_pitching_lines.ip
                    END / (pecota_pitching_lines.so_pa + pecota_pitching_lines.out_pa)
                    ELSE pecota_pitching_lines.expected_pa
                END AS expected_pa,
                CASE COALESCE(pecota_pitching_lines.ip, 0::double precision)
                    WHEN 0 THEN 35::double precision
                    ELSE pecota_pitching_lines.ip
                END AS ip
           FROM stats.pecota_pitching_lines
        )
        , fip_const AS (
         SELECT (9 * sum(stats_pitching.earned_runs) - (13 * sum(stats_pitching.home_runs) + 3 * (sum(stats_pitching.base_on_balls) + sum(COALESCE(stats_pitching.hit_batsmen, 0))) - 2 * sum(stats_pitching.strike_outs)))::double precision / sum(stats_pitching.innings_pitched) AS fip_const
           FROM stats.stats_pitching
             JOIN entitas.teams t_1 USING (team_id)
             JOIN entitas.levels l_1 USING (level_id)
          WHERE stats_pitching.season = 2019 AND t_1.level_id = 1
        )
        , league_era AS (
         SELECT 2 AS league_id,
            4.93574953 AS league_ra
        UNION ALL
         SELECT 1 AS league_id,
            4.72551441 AS league_ra
        )
        , start_warp_pecota AS (
         SELECT a_1.bpid,
            COALESCE(a_1.ip_sp, 35::double precision) * ((r.league_ra * 1.186)::double precision - a_1.dra) / (9.0::double precision * w_1.rpw) AS warp
           FROM stats.ref_runs_per_win w_1,
            stats.pecota_pitching_lines a_1
             JOIN entitas.people_search p_1 USING (bpid)
             JOIN entitas.teams t_1 USING (team_id)
             JOIN entitas.leagues l_1 USING (league_id)
             JOIN league_era r USING (league_id)
          WHERE w_1.season = 2019 AND w_1.lvl = 'mlb'::text
        )
        , relief_warp_pecota AS (
         SELECT a_1.bpid,
            COALESCE(a_1.ip_rp, 35::double precision) * ((r.league_ra * 1.10)::double precision - a_1.dra) / (9.0::double precision * w_1.rpw) AS warp
           FROM stats.ref_runs_per_win w_1,
            stats.pecota_pitching_lines a_1
             JOIN entitas.people_search p_1 USING (bpid)
             JOIN entitas.teams t_1 USING (team_id)
             JOIN entitas.leagues l_1 USING (league_id)
             JOIN league_era r USING (league_id)
          WHERE w_1.season = 2019 AND w_1.lvl = 'mlb'::text
        ), pitcher_warp AS (
         SELECT q.bpid,
            sum(q.warp) AS warp
           FROM ( SELECT start_warp_pecota.bpid,
                    max(start_warp_pecota.warp) AS warp
                   FROM start_warp_pecota
                  GROUP BY start_warp_pecota.bpid
                UNION ALL
                 SELECT relief_warp_pecota.bpid,
                    max(relief_warp_pecota.warp) AS warp
                   FROM relief_warp_pecota
                  GROUP BY relief_warp_pecota.bpid) q
          GROUP BY q.bpid
        )
 SELECT b.full_name,
    a.bpid,
    b.birth_date AS bornstring,
    date_part('year'::text, age('2020-07-01 02:00:00-05'::timestamp with time zone, b.birth_date::timestamp with time zone)) AS age04,
    b.bats,
    b.throws,
    b.height,
    b.weight,
    2020 AS year,
    x.xref_id as team_name,
    'mlb' as level_name,
    date_part('year'::text, age('2020-07-01 02:00:00-05'::timestamp with time zone, b.birth_date::timestamp with time zone)) AS age,
    round(a.w) AS w,
    round(a.l) AS l,
    round(a.sv) AS sv,
    round(a.g) AS g,
    round(a.gs) AS gs,
    round(d.ip) AS ip,
    round((a.hits_pa * a.expected_pa)::numeric, 0) AS h,
    round((a.hr_pa * a.expected_pa)::numeric, 0) AS hr,
    round((a.bb_pa * a.expected_pa)::numeric, 0) AS bb,
    round((a.so_pa * a.expected_pa)::numeric, 0) AS so,
    round((9*(a.bb_pa * a.expected_pa)/d.ip)::numeric, 1) AS eqbb9,
    round((9*(a.so_pa * a.expected_pa)/d.ip)::numeric, 1) AS eqso9,
    COALESCE(a.gb_pa, 0.46972874899059569::real) AS gb_percent,
    round(((a.b1_pa + a.b2_pa + a.b3_pa) / (1::double precision - a.bb_pa - a.hbp_pa - a.so_pa - a.hr_pa))::numeric, 3) AS babip,
    round(((a.bb_pa + a.hits_pa) * d.expected_pa / d.ip)::numeric, 3) AS whip,
    round(p.ra::numeric, 2) AS era,
    round((f.fip_const + d.expected_pa * (13::double precision * a.hr_pa + 3::double precision * (a.hbp_pa + a.bb_pa) - 2::double precision * a.so_pa) / d.ip)::numeric, 2) AS fip,
    round(a.cfip::double precision) AS cfip,
    round(a.dra::numeric, 2) AS dra,
    w.warp,
    w.warp * rpw.rpg::double precision AS vorp,
    NULL::text AS breakout,
    NULL::text AS improve,
    NULL::text AS collapse,
    NULL::text AS attrition,
    NULL::text AS comparables,
    NULL::text AS ml_pct,
    round(a.qs) AS qs,
    round(a.expected_pa) AS pa
   FROM fip_const f,
    stats.ref_runs_per_win rpw,
    stats.pecota_pitching_lines a
     join entitas.book_list bl using (bpid)
     JOIN stats.pecota_pitcher_ra p USING (bpid)
     JOIN defaulted d USING (bpid)
     JOIN pitcher_warp w USING (bpid)
     JOIN entitas.people_search b USING (bpid) 
     join xrefs.org_refs x on ( bl.org_id =x.org_id)
  WHERE rpw.season = 2019 AND rpw.lvl = 'mlb'::text and b.death_date is null and  x.xref_id not in ('ANA','MON')
  ORDER BY a.dra
 WITH DATA;

DROP MATERIALIZED VIEW IF EXISTS stats.bp_pecota2020__pecota_bat_dc CASCADE;


CREATE MATERIALIZED VIEW stats.bp_pecota2020__pecota_bat_dc TABLESPACE pg_default AS
WITH defaulted AS
  (SELECT bpid
        , CASE
              WHEN coalesce(pa_expected, 0) = 0 THEN 251
              ELSE pa_expected
          END AS pa_expected
   FROM stats.pecota_batting_lines)
SELECT b.bpid AS ID
     , p.full_name AS NAME
     , r.position AS POS
     , p.birth_date AS BORNSTRING
     , extract(YEAR
               FROM age('July 1, 2020', p.birth_date)) AS AGE04
     , p.bats AS BATS
     , p.throws AS THROWS
     , p.height AS HEIGHT
     , p.weight AS WEIGHT
     , b.season AS "YEAR"
     , t.team_name AS TEAM
     , l.level_name AS LVL
     , extract(YEAR
               FROM age('July 1, 2020', p.birth_date)) AS AGE
     , b.pa_expected AS PA
     , ROUND(d.pa_expected * b.runs_pa) AS R
     , ROUND(d.pa_expected * b.b2_pa) AS "2b"
     , ROUND(d.pa_expected * b.b3_pa) AS "3b"
     , ROUND(d.pa_expected * b.hr_pa) AS HR
     , ROUND(d.pa_expected * b.rbi_pa) AS RBI
     , ROUND(d.pa_expected * b.bb_pa) AS BB
     , ROUND(d.pa_expected * b.so_pa) AS SO
     , ROUND(d.pa_expected * b.sb_pa) AS SB
     , ROUND(d.pa_expected * b.cs_pa) AS CS
     , REPLACE(CONCAT(ROUND(b.hits_pa::numeric / b.ab_pa::numeric, 3), '/', ROUND(b.on_base_pa::numeric, 3), '/', ROUND(b.total_base_pa::numeric / b.ab_pa::numeric, 3)), '0.', '.') AS AVG_OBP_SLG
     , NULL AS TAv -- TRIM(LEADING '0' FROM v.TAv) AS TAv

     , round((((b1_pa * d.pa_expected) + (b2_pa * d.pa_expected) + (b3_pa * d.pa_expected)) / ((1 - bb_pa - hbp_pa - so_pa - hr_pa) * d.pa_expected))::numeric, 3) AS babip
     , round(d.pa_expected * b.brr_pa::numeric, 1) AS BRR
     , coalesce(field, '') AS FRAA
     , round(((coalesce(fraa, 0) + coalesce(pos_adj, 0) + .028 * d.pa_expected + draa_pa * d.pa_expected + coalesce((brr_pa * d.pa_expected) ,0)) / ((9.1 + w.rpw) / 2))::numeric, 1) AS WARP
     , NULL AS BREAKOUT
     , NULL AS IMPROVE
     , NULL AS COLLAPSE
     , NULL AS ATTRITION
     , NULL AS COMPARABLES
     , NULL AS ML_PCT
     , round(((coalesce(pos_adj, 0) + .028 * d.pa_expected + draa_pa * d.pa_expected + (brr_pa * d.pa_expected)))::numeric, 1) AS VORP
     , round(drc_plus::numeric, 0) AS DRC_PLUS
     , round(coalesce(fraa, 0)::numeric, 0) AS fraa_val
FROM stats.ref_runs_per_win w
   , stats.pecota_batting_lines b
JOIN defaulted d USING (bpid)
JOIN entitas.people_roster_entries r USING (bpid)
JOIN entitas.people_search p USING (bpid)
JOIN entitas.teams t USING (team_id)
JOIN entitas.levels l USING (level_id)
JOIN xrefs.org_refs xx ON xx.org_id = t.org_id
LEFT JOIN stats.bp_pecota2020__projected_fraa x ON (bpid = bat_id)
LEFT JOIN stats.bp_pecota2020__fraa_text_pecota y USING (bat_id)
LEFT JOIN stats.bp_pecota2020__projected_pos_value z USING (bat_id)
WHERE xx.xref_id NOT IN ('ANA'
                       , 'MON')
  AND w.LVL = 'mlb'
  AND w.season = 2019;




grant select on all tables in schema stats to pgexport;
grant select on all tables in schema stats to basecoach;
 

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
REFRESH MATERIALIZED VIEW stats.bp_pecota2020__pecota_bat_raw WITH DATA;  
REFRESH MATERIALIZED VIEW stats.bp_pecota2020__pecota_pit_dc WITH DATA;	
REFRESH MATERIALIZED VIEW stats.bp_pecota2020__pecota_bat_dc WITH DATA;

 
grant select on all tables in schema stats to pgexport;
grant select on all tables in schema stats to basecoach;

 
