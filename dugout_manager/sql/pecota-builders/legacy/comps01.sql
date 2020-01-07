### uses career lines thru age and level


 
-- create database bp_pecota2020_ten;
USE bp_pecota2020_ten;
SET group_concat_max_len := @@max_allowed_packet;
SELECT @yearproj := 2020;
-- 
--  
-- drop TABLE  IF EXISTS tech_rmcquown.batting_2020 ;
--  
-- CREATE TABLE  tech_rmcquown.batting_2020 as 
-- SELECT BATTER,LVL,SUM(
-- COALESCE( IF(LVL in ('rok','win','int','asx'),ROUND(PA/2),PA) , 0 )
-- ) AS PA,MIN(YEAR) as YEAR_MIN,MAX(YEAR) as YEAR_MAX FROM warehouse.batting GROUP BY batter,LVL;



drop  table  bp_pecota2020.primpos_raw;

create table  bp_pecota2020.primpos_raw as 
SELECT YEAR_ID, BAT_ID, BAT_FLD_CD, COUNT(*) AS PA
FROM warehouse.events e
WHERE BAT_EVENT_FL = "T"
AND BAT_FLD_CD BETWEEN 2 AND 10
AND BAT_ID NOT IN (47934,46059,48070,48456)
GROUP BY YEAR_ID, BAT_ID, BAT_FLD_CD;

  CREATE INDEX primpos_raw_idx ON bp_pecota2020.primpos_raw (YEAR_ID, BAT_ID, PA); 


drop  table  bp_pecota2020.primpos;

create table bp_pecota2020.primpos as 
SELECT a1.*, a1.YEAR_ID+1 AS YEAR_PROJ
FROM 
(
	SELECT r1.*
	FROM bp_pecota2020.primpos_raw r1
	LEFT JOIN bp_pecota2020.primpos_raw r2
	ON r1.YEAR_ID = r2.YEAR_ID
	AND r1.BAT_ID = r2.BAT_ID
	AND r1.PA < r2.PA
	WHERE r2.PA IS NULL
) a1
LEFT JOIN 
(
	SELECT r1.*
	FROM bp_pecota2020.primpos_raw r1
	LEFT JOIN bp_pecota2020.primpos_raw r2
	ON r1.YEAR_ID = r2.YEAR_ID
	AND r1.BAT_ID = r2.BAT_ID
	AND r1.PA < r2.PA
	WHERE r2.PA IS NULL
) a2
ON a1.YEAR_ID = a2.YEAR_ID
AND a1.BAT_ID = a2.BAT_ID
AND a1.PA = a2.PA
AND a1.BAT_FLD_CD > a2.BAT_FLD_CD
WHERE a2.BAT_FLD_CD IS NULL;
 

INSERT IGNORE INTO bp_pecota2020.primpos 
SELECT 
yr as YEAR_ID
, PLAYERID as BAT_ID
, primpos as BAT_FLD_CD
, g_tot*4 as PA
, yr+1 as YEAR_PROJ
FROM tech_rmcquown.palmer_fielding_scratch0
where PLAYERID IS NOT NULL;


DROP TABLE IF EXISTS bp_pecota2020_ten.primpos;
CREATE TABLE IF NOT EXISTS bp_pecota2020_ten.primpos like bp_pecota2020.primpos;
TRUNCATE TABLE bp_pecota2020_ten.primpos;

INSERT INTO bp_pecota2020_ten.primpos 
SELECT p.* FROM bp_pecota2020.primpos p;  


drop  IF EXISTS TABLE bp_pecota2020_ten.sim_seed_batter_raw;

-- create TABLE bp_pecota2020_ten.sim_seed_batter_raw
-- as
-- SELECT l.`YEAR`, l.LVL,  l.BATTER, p.FULLNAME AS NAME
-- 	, l.PA AS PA
-- 	, l.SO/(l.SO+l.HBP+l.IBB+l.UBB  ) AS K_BB
-- 	, (l.PA-l.IBB-l.HBP-l.UBB-l.SO)/l.PA AS CON_RT
-- 	, l.B3/(l.B2+l.B3) AS 3B_XBH
-- 	, (l.B1+2*l.B2+3*l.B3+4*l.HR)/(l.PA-l.IBB-l.HBP-l.UBB-l.SO) AS SLGCON
-- 	, l.DRC_PLUS
-- 	, p.WEIGHT
-- 	, p.HEIGHT
-- 	, (CASE WHEN BATS = "L" THEN -1
-- 			WHEN BATS = "B" THEN 0
-- 			ELSE 1 END) AS THROWS_FL
-- 	, (CASE WHEN p.BIRTH_MONTH < 7
--                 THEN ( l.`YEAR` - p.BIRTH_YEAR )
--                 ELSE ( l.`YEAR` - p.BIRTH_YEAR - 1 ) END) AS Age
-- 	, o.BAT_FLD_CD
-- FROM bp_stats.dyna_batter_season l, bp_players.MasterPlayer_dd p, bp_pecota2019_ten.primpos o 
-- WHERE l.BATTER = p.PLAYERID
-- AND l.BATTER = o.BAT_ID
-- AND l.`YEAR` = o.YEAR_PROJ 
-- AND l.PA>=1
-- UNION 
-- SELECT l.`YEAR`, l.LVL,  l.BATTER, p.FULLNAME AS NAME
-- 	, l.PA AS PA
-- 	, l.SO/(l.SO+l.HBP+l.IBB+l.UBB  ) AS K_BB
-- 	, (l.PA-l.IBB-l.HBP-l.UBB-l.SO)/l.PA AS CON_RT
-- 	, l.B3/(l.B2+l.B3) AS 3B_XBH
-- 	, (l.B1+2*l.B2+3*l.B3+4*l.HR)/(l.PA-l.IBB-l.HBP-l.UBB-l.SO) AS SLGCON
-- 	, l.DRC_PLUS
-- 	, p.WEIGHT
-- 	, p.HEIGHT
-- 	, (CASE WHEN BATS = "L" THEN -1
-- 			WHEN BATS = "B" THEN 0
-- 			ELSE 1 END) AS THROWS_FL
-- 	, l.age
-- 	, l.PRIMARY_POS
-- FROM bp_stats.dyna_batter_career l, bp_players.MasterPlayer_dd p 
-- WHERE l.BATTER = p.PLAYERID 
-- AND l.PA>=1
;




drop table  IF EXISTS bp_pecota2020_ten.sim_seed_batter_avg;

-- create table bp_pecota2020_ten.sim_seed_batter_avg as 
-- SELECT `YEAR` , LVL
-- 	, AVG(PA) AS PA
-- 	, SUM(K_BB*PA)/SUM(PA) AS K_BB
-- 	, SUM(CON_RT*PA)/SUM(PA) AS CON_RT
-- 	, SUM(DRC_PLUS*PA)/SUM(PA) AS DRC_PLUS
-- 	, SUM(3B_XBH*PA)/SUM(PA) AS 3B_XBH
-- 	, SUM(SLGCON*PA)/SUM(PA) AS SLGCON
-- 	, SUM(WEIGHT*PA)/SUM(PA) AS WEIGHT
-- 	, SUM(HEIGHT*PA)/SUM(PA) AS HEIGHT
-- 	, SUM(Age*PA)/SUM(PA) AS Age
-- FROM bp_pecota2020_ten.sim_seed_batter_raw
-- GROUP BY `YEAR`,LVL ;
 

DROP TABLE  IF EXISTS bp_pecota2020_ten.sim_seed_batter_sd ;

-- create TABLE bp_pecota2020_ten.sim_seed_batter_sd as 
-- SELECT r.`YEAR` ,r.LVL
-- 	, SQRT(AVG(POWER(r.PA-a.PA,2))) AS PA_SD 
-- 	, SQRT(SUM(POWER(r.K_BB-a.K_BB,2)*r.PA)/SUM(r.PA)) AS K_BB_SD
-- 	, SQRT(SUM(POWER(r.CON_RT-a.CON_RT,2)*r.PA)/SUM(r.PA)) AS CON_RT_SD
-- 	, SQRT(SUM(POWER(r.DRC_PLUS-a.DRC_PLUS,2)*r.PA)/SUM(r.PA)) AS DRC_PLUS_SD
-- 	, SQRT(SUM(POWER(r.3B_XBH-a.3B_XBH,2)*r.PA)/SUM(r.PA)) AS 3B_XBH_SD
-- 	, SQRT(SUM(POWER(r.SLGCON-a.SLGCON,2)*r.PA)/SUM(r.PA)) AS SLGCON_SD  
-- 	, SQRT(SUM(POWER(r.WEIGHT-a.WEIGHT,2)*r.PA)/SUM(r.PA)) AS WEIGHT_SD
-- 	, SQRT(SUM(POWER(r.HEIGHT-a.HEIGHT,2)*r.PA)/SUM(r.PA)) AS HEIGHT_SD
-- 	, SQRT(SUM(POWER(r.Age-a.Age,2)*r.PA)/SUM(r.PA)) AS Age_SD
-- FROM bp_pecota2020_ten.sim_seed_batter_raw r, bp_pecota2020_ten.sim_seed_batter_avg a
-- WHERE r.`YEAR` = a.`YEAR`  and r.LVL = a.LVL
-- GROUP BY `YEAR`, LVL ;
--  

drop table  IF EXISTS bp_pecota2020_ten.sim_seed_batter_lg;

-- create table bp_pecota2020_ten.sim_seed_batter_lg as 
-- SELECT a.*, s.PA_SD,   s.K_BB_SD,  s.DRC_PLUS_SD, s.CON_RT_SD, s.3B_XBH_SD, s.SLGCON_SD,   s.WEIGHT_SD, s.HEIGHT_SD, s.Age_SD
-- FROM bp_pecota2020_ten.sim_seed_batter_avg a, bp_pecota2020_ten.sim_seed_batter_sd s
-- WHERE a.`YEAR` = s.`YEAR` and a.LVL=s.LVL;

drop table  IF EXISTS bp_pecota2020_ten.sim_seed_batter_z;

-- create table  bp_pecota2020_ten.sim_seed_batter_z as 
-- SELECT r.`YEAR`,r.LVL, r.BATTER, r.NAME 
-- 	, r.Age, IF(r.BAT_FLD_CD>9,3,r.BAT_FLD_CD) AS BAT_FLD_CD
-- 	, r.PA 
-- 	, (r.PA-l.PA)/l.PA_SD AS PA_Z 
-- 	, (r.K_BB-l.K_BB)/l.K_BB_SD AS K_BB_Z
-- 	, (r.CON_RT-l.CON_RT)/l.CON_RT_SD AS CON_RT_Z
-- 	, (r.DRC_PLUS-l.DRC_PLUS)/l.DRC_PLUS_SD AS DRC_PLUS_Z
-- 	, (r.3B_XBH-l.3B_XBH)/l.3B_XBH_SD AS 3B_XBH_Z
-- 	, (r.SLGCON-l.SLGCON)/l.SLGCON_SD AS SLGCON_Z 
-- 	, (r.WEIGHT-l.WEIGHT)/l.WEIGHT_SD AS WEIGHT_Z
-- 	, (r.HEIGHT-l.HEIGHT)/l.HEIGHT_SD AS HEIGHT_Z
-- 	, (r.AGE-l.AGE)/l.Age_SD AS AGE_Z
-- 	, r.THROWS_FL AS THROWS_Z 
-- FROM bp_pecota2020_ten.sim_seed_batter_raw r, bp_pecota2020_ten.sim_seed_batter_lg l
-- WHERE r.`YEAR` = l.`YEAR` and r.LVL = l.LVL;

## this is the comparison set  that needs to be available on the new warehouse
drop table  IF EXISTS bp_pecota2020_ten.sim_seed_batter_z_old;
-- create table bp_pecota2020_ten.sim_seed_batter_z_old as 
-- SELECT z.* 
-- FROM bp_pecota2020_ten.sim_seed_batter_z z 
-- INNER JOIN bp_players.MasterPlayer_dd p ON z.BATTER=p.PLAYERID
-- INNER JOIN tech_rmcquown.batting_2020 b on z.BATTER=b.BATTER AND BINARY  z.LVL = BINARY  b.LVL
-- WHERE z.`YEAR` < 2020
-- and p.POS is not NULL
-- and p.POS not in ('',' ','?','P')
-- AND z.PA > 100
-- AND b.PA>=250 and b.YEAR_MAX > b.YEAR_MIN+1 and 2020 > b.YEAR_MIN+1;
-- ; 
 
## this is the current crop of projection target using five years
drop table  IF EXISTS bp_pecota2020_ten.sim_seed_batter_z_now; 
-- create table  bp_pecota2020_ten.sim_seed_batter_z_now as
-- SELECT z.*,GREATEST(18,z.Age) FROM bp_pecota2020_ten.sim_seed_batter_z z WHERE YEAR  >= 2015;

DROP TABLE IF EXISTS bp_pecota2020_ten.comps_batter_raw_extra;

-- CREATE TABLE   bp_pecota2020_ten.comps_batter_raw_extra as
-- SELECT n.YEAR , n.lvl, n.BATTER, n.NAME, o.YEAR  AS YEAR_ID_COMP, o.BATTER AS BAT_ID_COMP, o.NAME AS NAME_COMP
-- 	, n.Age, o.Age AS Age_COMP
-- 	, n.PA, o.PA AS PA_COMP 
-- 	, SQRT(
-- 		  0.397  * COALESCE(POWER(n.K_BB_Z-o.K_BB_Z,2),0) 
-- 		+ 0.202  * COALESCE(POWER(n.CON_RT_Z-o.CON_RT_Z,2),0) 
-- 		+ 0.838  * COALESCE(POWER(n.SLGCON_Z-o.SLGCON_Z,2),0)
-- 		+ 0.838  * COALESCE(POWER(n.DRC_PLUS_Z-o.DRC_PLUS_Z,2),0) 
-- 		+ 0.031  * COALESCE(POWER(n.WEIGHT_Z-o.WEIGHT_Z,2),0)
-- 		+ 0.012 * COALESCE(POWER(n.HEIGHT_Z-o.HEIGHT_Z,2),0) 
-- 		+ 0.001  * COALESCE(POWER(n.THROWS_Z-o.THROWS_Z,2),0)
-- 		+ 0.5 * COALESCE(POWER(n.AGE_Z-o.AGE_Z,2),0)
-- 		+ p.DIST_NORM 
-- 		) AS SIM_DIST 
-- FROM bp_pecota2020_ten.sim_seed_batter_z_now n                                                    ### projection targets
-- JOIN bp_pecota2020_ten.sim_seed_batter_z_old o ON  n.AGE=o.Age and   n.BATTER != o.BATTER  AND n.lvl=o.lvl      ### comp condidates
-- JOIN bp_pecota2019.pos_dist_norm p ON n.BAT_FLD_CD = p.POS1 AND o.BAT_FLD_CD = p.POS2             ### positional sim lookup table
-- where o.year >1950  
;

DROP TABLE IF EXISTS bp_pecota2020_ten.comps_batter_matched;
-- CREATE TABLE   bp_pecota2020_ten.comps_batter_matched as
-- Select 
-- batter,bat_id_comp, count(*) as matches, count(distinct lvl) as levels,
-- sum(PA+PA_COMP) as PA_PAIRED, 
-- sum((PA+PA_COMP)*SIM_DIST)/sum(PA+PA_COMP) as SIM_DIST
-- ,NAME,NAME_COMP
-- from  bp_pecota2020_ten.comps_batter_raw_extra  
-- group by batter,bat_id_comp  
-- ;
-- 
-- select * from bp_pecota2020_ten.comps_batter_matched
-- where name = 'Jo Adell'
-- order by    sim_dist/(matches-.75 )  limit 1000


##### end seasonal
 
#### career thru age/level
drop table bp_pecota2020_ten.sim_seed_batter_career_raw;

create table bp_pecota2020_ten.sim_seed_batter_career_raw as 
select a.batter, a.lvl, a.age, b.PRIMARY_POS
, count(b.batter) as years , min(b.year) as first_season, max(b.year) as last_season
, sum(b.PA) as PA  
, sum(b.SO) / sum( b.SO + b.HBP + b.IBB + b.UBB  ) AS K_BB
, sum( b.PA - b.IBB - b.HBP - b.UBB - b.SO) / sum(b.PA) AS CON_RT
, sum(b.B3) / sum( b.B2 + b.B3) AS 3B_XBH
, sum( b.B1 + 2* b.B2 + 3* b.B3 + 4* b.HR) / sum( b.PA - b.IBB - b.HBP -  b.UBB - b.SO) AS SLGCON
, sum( b.PA * b.DRC_PLUS   ) / sum( b.PA  )  as drc_plus
, p.WEIGHT
, p.HEIGHT
	, (CASE WHEN BATS = "L" THEN -1
			WHEN BATS = "B" THEN 0
			ELSE 1 END) AS THROWS_FL
from 
(
	select 
	batter, lvl, age 
	from 
	bp_stats.dyna_batter_season where year>1950 and DRC_PLUS is not null group by batter,lvl, age 
) a , 
bp_stats.dyna_batter_season b join bp_players.MasterPlayer_dd p on (b.BATTER = p.PLAYERID) 
where a.batter = b.batter and a.age >= b.age and a.lvl = b.lvl 
group by a.batter, a.lvl, a.age ;


drop table bp_pecota2020_ten.sim_seed_batter_career_avg;

create table bp_pecota2020_ten.sim_seed_batter_career_avg as 
SELECT age , LVL
	, AVG(PA) AS PA
	, SUM(K_BB*PA)/SUM(PA) AS K_BB
	, SUM(CON_RT*PA)/SUM(PA) AS CON_RT
	, SUM(DRC_PLUS*PA)/SUM(PA) AS DRC_PLUS
	, SUM(3B_XBH*PA)/SUM(PA) AS 3B_XBH
	, SUM(SLGCON*PA)/SUM(PA) AS SLGCON
	, SUM(WEIGHT*PA)/SUM(PA) AS WEIGHT
	, SUM(HEIGHT*PA)/SUM(PA) AS HEIGHT
FROM bp_pecota2020_ten.sim_seed_batter_career_raw
GROUP BY age,LVL ;
 


DROP TABLE bp_pecota2020_ten.sim_seed_batter_career_sd ;

create TABLE bp_pecota2020_ten.sim_seed_batter_career_sd as 
SELECT r.age ,r.LVL
	, SQRT(AVG(POWER(r.PA-a.PA,2))) AS PA_SD 
	, SQRT(SUM(POWER(r.K_BB-a.K_BB,2)*r.PA)/SUM(r.PA)) AS K_BB_SD
	, SQRT(SUM(POWER(r.CON_RT-a.CON_RT,2)*r.PA)/SUM(r.PA)) AS CON_RT_SD
	, SQRT(SUM(POWER(r.DRC_PLUS-a.DRC_PLUS,2)*r.PA)/SUM(r.PA)) AS DRC_PLUS_SD
	, SQRT(SUM(POWER(r.3B_XBH-a.3B_XBH,2)*r.PA)/SUM(r.PA)) AS 3B_XBH_SD
	, SQRT(SUM(POWER(r.SLGCON-a.SLGCON,2)*r.PA)/SUM(r.PA)) AS SLGCON_SD  
	, SQRT(SUM(POWER(r.WEIGHT-a.WEIGHT,2)*r.PA)/SUM(r.PA)) AS WEIGHT_SD
	, SQRT(SUM(POWER(r.HEIGHT-a.HEIGHT,2)*r.PA)/SUM(r.PA)) AS HEIGHT_SD
FROM bp_pecota2020_ten.sim_seed_batter_career_raw r, bp_pecota2020_ten.sim_seed_batter_career_avg a
WHERE r.`age` = a.`age`  and r.LVL = a.LVL
GROUP BY `age`, LVL ;



drop table  bp_pecota2020_ten.sim_seed_batter_career_lg;

create table bp_pecota2020_ten.sim_seed_batter_career_lg as 
SELECT a.*, s.PA_SD,   s.K_BB_SD,  s.DRC_PLUS_SD, s.CON_RT_SD, s.3B_XBH_SD, s.SLGCON_SD,   s.WEIGHT_SD, s.HEIGHT_SD 
FROM bp_pecota2020_ten.sim_seed_batter_career_avg a, bp_pecota2020_ten.sim_seed_batter_career_sd s
WHERE a.`age` = s.`age` and a.LVL=s.LVL;


drop table  bp_pecota2020_ten.sim_seed_batter_career_z;

create table  bp_pecota2020_ten.sim_seed_batter_career_z as 
SELECT r.`age`,r.LVL, r.BATTER 
	 ,IF(r.PRIMARY_POS>9,3,r.PRIMARY_POS) AS BAT_FLD_CD
	, r.PA 
	, (r.PA-l.PA)/l.PA_SD AS PA_Z 
	, (r.K_BB-l.K_BB)/l.K_BB_SD AS K_BB_Z
	, (r.CON_RT-l.CON_RT)/l.CON_RT_SD AS CON_RT_Z
	, (r.DRC_PLUS-l.DRC_PLUS)/l.DRC_PLUS_SD AS DRC_PLUS_Z
	, (r.3B_XBH-l.3B_XBH)/l.3B_XBH_SD AS 3B_XBH_Z
	, (r.SLGCON-l.SLGCON)/l.SLGCON_SD AS SLGCON_Z 
	, (r.WEIGHT-l.WEIGHT)/l.WEIGHT_SD AS WEIGHT_Z
	, (r.HEIGHT-l.HEIGHT)/l.HEIGHT_SD AS HEIGHT_Z 
	, r.THROWS_FL AS THROWS_Z 
FROM bp_pecota2020_ten.sim_seed_batter_career_raw r, bp_pecota2020_ten.sim_seed_batter_career_lg l
WHERE r.`age` = l.`age` and r.LVL = l.LVL;

drop table bp_pecota2020_ten.sim_seed_batter_z_career_old;
create table bp_pecota2020_ten.sim_seed_batter_z_career_old as 
SELECT z.* 
FROM bp_pecota2020_ten.sim_seed_batter_career_z z 
INNER JOIN bp_players.MasterPlayer_dd p ON z.BATTER=p.PLAYERID 
WHERE   p.POS is not NULL
and p.POS not in ('',' ','?','P')
AND z.PA > 100 
 
; 
 

drop table  bp_pecota2020_ten.sim_seed_batter_z_career_now; 
create table  bp_pecota2020_ten.sim_seed_batter_z_career_now as
SELECT z.*,GREATEST(18,z.Age) FROM bp_pecota2020_ten.sim_seed_batter_career_z z join bp_pecota2020_ten.sim_seed_batter_z_now a using (batter) where a.year=2019 ;



DROP TABLE IF EXISTS bp_pecota2020_ten.comps_batter_raw_career_extra;

CREATE TABLE   bp_pecota2020_ten.comps_batter_raw_career_extra as
SELECT   n.lvl, n.BATTER,     o.BATTER AS BAT_ID_COMP 
	, n.Age, o.Age AS Age_COMP
	, n.PA, o.PA AS PA_COMP 
	, SQRT(
		  0.397  * COALESCE(POWER(n.K_BB_Z-o.K_BB_Z,2),0) 
		+ 0.202  * COALESCE(POWER(n.CON_RT_Z-o.CON_RT_Z,2),0) 
		+ 0.838  * COALESCE(POWER(n.SLGCON_Z-o.SLGCON_Z,2),0)
		+ 0.838  * COALESCE(POWER(n.DRC_PLUS_Z-o.DRC_PLUS_Z,2),0) 
		+ 0.031  * COALESCE(POWER(n.WEIGHT_Z-o.WEIGHT_Z,2),0)
		+ 0.012 * COALESCE(POWER(n.HEIGHT_Z-o.HEIGHT_Z,2),0) 
		+ 0.001  * COALESCE(POWER(n.THROWS_Z-o.THROWS_Z,2),0) 
		+ p.DIST_NORM 
		) AS SIM_DIST 
FROM bp_pecota2020_ten.sim_seed_batter_z_career_now n                                                    ### projection targets
JOIN bp_pecota2020_ten.sim_seed_batter_z_career_old o ON  n.AGE=o.Age and   n.BATTER != o.BATTER  AND n.lvl=o.lvl      ### comp condidates
JOIN bp_pecota2019.pos_dist_norm p ON n.BAT_FLD_CD = p.POS1 AND o.BAT_FLD_CD = p.POS2             ### positional sim lookup table 
;



DROP TABLE IF EXISTS bp_pecota2020_ten.comps_batter_career_matched;

CREATE TABLE   bp_pecota2020_ten.comps_batter_career_matched as
Select 
batter,bat_id_comp, count(*) as matches, count(distinct lvl) as levels,
sum(PA+PA_COMP) as PA_PAIRED, 
sum((PA+PA_COMP)*SIM_DIST)/sum(PA+PA_COMP) as SIM_DIST
,a.fullname as NAME,b.fullname as NAME_COMP
from  bp_pecota2020_ten.comps_batter_raw_career_extra  
join bp_players.MasterPlayer_dd a on (batter=a.playerid) join bp_players.MasterPlayer_dd b on (bat_id_comp=b.playerid)
group by batter,bat_id_comp  
;

 

DROP TABLE IF EXISTS bp_pecota2020_ten.player_top_comps_raw_hitters;

SET @num = 0;
SET @fld = '';

create table bp_pecota2020_ten.player_top_comps_raw_hitters  
SELECT c.Batter, NAME,   BAT_ID_COMP, NAME_COMP, SIM_DIST, SIM_DIST/(matches-.15 ) as SIM_DIST_ADJ, matches,PA_PAIRED
	, @num := IF(c.Batter = @fld,@num+1,1) AS Rank
	, @fld := c.Batter AS dummy
FROM bp_pecota2020_ten.comps_batter_career_matched c 
join (select distinct batter from bp_stats.dyna_batter_career where lvl='mlb') a on (bat_id_comp=a.batter) #this is a filter to keep all comps as MLBers
ORDER BY  c.Batter, SIM_DIST/(matches-.15 ) ASC;




DROP TABLE IF EXISTS bp_pecota2020_ten.comp_line_mlb_hitters;

create table bp_pecota2020_ten.comp_line_mlb_hitters as
SELECT   b.BATTER,  b.NAME, 
REPLACE(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT NAME_COMP ORDER BY RANK),",",3),',',', ') AS COMPARABLES
, GROUP_CONCAT(if(rank=1,bat_id_comp,null)) as COMP_1 
, GROUP_CONCAT(if(rank=1,NAME_COMP,null)) as COMP_1_NAME 
, GROUP_CONCAT(if(rank=2,bat_id_comp,null)) as COMP_2 
, GROUP_CONCAT(if(rank=2,NAME_COMP,null)) as COMP_2_NAME 
, GROUP_CONCAT(if(rank=3,bat_id_comp,null)) as COMP_3
, GROUP_CONCAT(if(rank=3,NAME_COMP,null)) as COMP_3_NAME 
FROM bp_pecota2020_ten.player_top_comps_raw_hitters b
join bp_book20.bp20playerlist a on (batter=playerid) 
WHERE Rank <= 3 and a.team !=''
GROUP BY BATTER;


select * from bp_pecota2020_ten.comp_line_mlb_hitters order by name



DROP TABLE IF EXISTS bp_pecota2020_ten.sim_dist_minmax;

create table bp_pecota2020_ten.sim_dist_minmax as
SELECT MIN(SIM_DIST) AS MIN_DIST
, MAX(SIM_DIST) AS MAX_DIST 
, MIN(SIM_DIST_ADJ) AS MIN_DIST_ADJ
, MAX(SIM_DIST_ADJ) AS MAX_DIST_ADJ
	FROM bp_pecota2020_ten.player_top_comps_raw
	WHERE Rank <= 100;

DROP TABLE IF EXISTS bp_pecota2020_ten.bio_lines_raw;

create table bp_pecota2020_ten.bio_lines_raw as
SELECT g.BATTER
	, IF(p.TAv/g.TAv >= 1.2,1,0) AS BREAKOUT
	, IF(p.TAv>g.TAv,1,0) AS IMPROVE
	, IF(p.TAv/g.TAv <= .8,1,0) AS COLLAPSE
	, IF(p.PA/g.PA <= .5,1,0) AS ATTRITION
	, IF(p.TAv IS NOT NULL,1,0) AS MLB
	, g.MLB_PCT
FROM projected_tav_noage g
LEFT JOIN lwts.player_season_tav p
ON g.YEAR_PROJ = p.YEAR_ID
AND g.BAT_ID = p.BAT_ID
AND p.LVL = "mlb"
;

 
drop table bp_pecota2020_ten.sim_seed_pitcher_career_raw;

create table bp_pecota2020_ten.sim_seed_pitcher_career_raw as 
select a.PITCHER, a.lvl, a.age, p.POS
, count(b.PITCHER) as years , min(b.year) as first_season, max(b.year) as last_season
, sum(b.PA) as PA  
, sum(b.SO) / sum( b.SO + b.HBP + b.IBB + b.UBB  ) AS K_BB
, sum( b.PA - b.IBB - b.HBP - b.UBB - b.SO) / sum(b.PA) AS CON_RT
, sum(b.B3) / sum( b.B2 + b.B3) AS 3B_XBH
, sum( b.B1 + 2* b.B2 + 3* b.B3 + 4* b.HR) / sum( b.PA - b.IBB - b.HBP -  b.UBB - b.SO) AS SLGCON
, sum( b.PA * b.DRA_MINUS   ) / sum( b.PA  )  as DRA_MINUS
, sum( b.GS/b.G) as start_perc
, p.WEIGHT
, p.HEIGHT
	, (CASE WHEN THROWS = "L" THEN -1
			WHEN THROWS = "B" THEN 0
			ELSE 1 END) AS THROWS_FL
from 
(
	select 
	PITCHER, lvl, age 
	from 
	bp_stats.dyna_pitcher_season where year>1950 and DRA_MINUS is not null group by PITCHER,lvl, age 
) a , 
bp_stats.dyna_pitcher_season b join bp_players.MasterPlayer_dd p on (b.PITCHER = p.PLAYERID) 
where a.PITCHER = b.PITCHER and a.age >= b.age and a.lvl = b.lvl 
group by a.PITCHER, a.lvl, a.age ;


drop table bp_pecota2020_ten.sim_seed_pitcher_career_avg;

create table bp_pecota2020_ten.sim_seed_pitcher_career_avg as 
SELECT age , LVL
	, AVG(PA) AS PA
	, SUM(K_BB*PA)/SUM(PA) AS K_BB
	, SUM(CON_RT*PA)/SUM(PA) AS CON_RT
	, SUM(DRA_MINUS*PA)/SUM(PA) AS DRA_MINUS
	, SUM(3B_XBH*PA)/SUM(PA) AS 3B_XBH
	, SUM(SLGCON*PA)/SUM(PA) AS SLGCON
	, SUM(WEIGHT*PA)/SUM(PA) AS WEIGHT
	, SUM(HEIGHT*PA)/SUM(PA) AS HEIGHT
	, SUM(start_perc*PA)/SUM(PA) AS start_perc
FROM bp_pecota2020_ten.sim_seed_pitcher_career_raw
GROUP BY age,LVL ;
 


DROP TABLE bp_pecota2020_ten.sim_seed_pitcher_career_sd ;

create TABLE bp_pecota2020_ten.sim_seed_pitcher_career_sd as 
SELECT r.age ,r.LVL
	, SQRT(AVG(POWER(r.PA-a.PA,2))) AS PA_SD 
	, SQRT(SUM(POWER(r.K_BB-a.K_BB,2)*r.PA)/SUM(r.PA)) AS K_BB_SD
	, SQRT(SUM(POWER(r.CON_RT-a.CON_RT,2)*r.PA)/SUM(r.PA)) AS CON_RT_SD
	, SQRT(SUM(POWER(r.DRA_MINUS-a.DRA_MINUS,2)*r.PA)/SUM(r.PA)) AS DRA_MINUS_SD
	, SQRT(SUM(POWER(r.3B_XBH-a.3B_XBH,2)*r.PA)/SUM(r.PA)) AS 3B_XBH_SD
	, SQRT(SUM(POWER(r.SLGCON-a.SLGCON,2)*r.PA)/SUM(r.PA)) AS SLGCON_SD  
	, SQRT(SUM(POWER(r.WEIGHT-a.WEIGHT,2)*r.PA)/SUM(r.PA)) AS WEIGHT_SD
	, SQRT(SUM(POWER(r.HEIGHT-a.HEIGHT,2)*r.PA)/SUM(r.PA)) AS HEIGHT_SD
	, SQRT(SUM(POWER(r.start_perc-a.start_perc,2)*r.PA)/SUM(r.PA)) AS start_perc_SD
FROM bp_pecota2020_ten.sim_seed_pitcher_career_raw r, bp_pecota2020_ten.sim_seed_pitcher_career_avg a
WHERE r.`age` = a.`age`  and r.LVL = a.LVL
GROUP BY `age`, LVL ;



drop table  bp_pecota2020_ten.sim_seed_pitcher_career_lg;

create table bp_pecota2020_ten.sim_seed_pitcher_career_lg as 
SELECT a.*, s.PA_SD,   s.K_BB_SD,  s.DRA_MINUS_SD, s.CON_RT_SD, s.3B_XBH_SD, s.SLGCON_SD,   s.WEIGHT_SD, s.HEIGHT_SD , s.start_perc_SD 
FROM bp_pecota2020_ten.sim_seed_pitcher_career_avg a, bp_pecota2020_ten.sim_seed_pitcher_career_sd s
WHERE a.`age` = s.`age` and a.LVL=s.LVL;


drop table  bp_pecota2020_ten.sim_seed_pitcher_career_z;

create table  bp_pecota2020_ten.sim_seed_pitcher_career_z as 
SELECT r.`age`,r.LVL, r.PITCHER 
	 ,r.POS
	, r.PA 
	, (r.PA-l.PA)/l.PA_SD AS PA_Z 
	, (r.K_BB-l.K_BB)/l.K_BB_SD AS K_BB_Z
	, (r.CON_RT-l.CON_RT)/l.CON_RT_SD AS CON_RT_Z
	, (r.DRA_MINUS-l.DRA_MINUS)/l.DRA_MINUS_SD AS DRA_MINUS_Z
	, (r.3B_XBH-l.3B_XBH)/l.3B_XBH_SD AS 3B_XBH_Z
	, (r.SLGCON-l.SLGCON)/l.SLGCON_SD AS SLGCON_Z 
	, (r.WEIGHT-l.WEIGHT)/l.WEIGHT_SD AS WEIGHT_Z
	, (r.HEIGHT-l.HEIGHT)/l.HEIGHT_SD AS HEIGHT_Z 
	, (r.start_perc-l.start_perc)/l.start_perc_SD AS start_perc_Z 
	, r.THROWS_FL AS THROWS_Z 
FROM bp_pecota2020_ten.sim_seed_pitcher_career_raw r, bp_pecota2020_ten.sim_seed_pitcher_career_lg l
WHERE r.`age` = l.`age` and r.LVL = l.LVL;

drop table bp_pecota2020_ten.sim_seed_pitcher_z_career_old;
create table bp_pecota2020_ten.sim_seed_pitcher_z_career_old as 
SELECT z.* 
FROM bp_pecota2020_ten.sim_seed_pitcher_career_z z 
INNER JOIN bp_players.MasterPlayer_dd p ON z.PITCHER=p.PLAYERID 
WHERE   p.POS ='P'
AND z.PA > 100 
 
; 

drop table  bp_pecota2020_ten.sim_seed_pitcher_z_career_now; 
create table  bp_pecota2020_ten.sim_seed_pitcher_z_career_now as
SELECT z.*,GREATEST(18,z.Age) FROM bp_pecota2020_ten.sim_seed_pitcher_career_z z join bp_pecota2020_ten.sim_seed_pitcher_career_raw a using (PITCHER) where a.last_season=2019 ;



DROP TABLE IF EXISTS bp_pecota2020_ten.comps_pitcher_raw_career_extra;

CREATE TABLE   bp_pecota2020_ten.comps_pitcher_raw_career_extra as
SELECT   n.lvl, n.PITCHER,     o.PITCHER AS pit_id_comp 
	, n.Age, o.Age AS Age_COMP
	, n.PA, o.PA AS PA_COMP 
	, SQRT(
		  0.25  * COALESCE(POWER(n.K_BB_Z-o.K_BB_Z,2),0) 
		+ 0.55  * COALESCE(POWER(n.CON_RT_Z-o.CON_RT_Z,2),0) 
		+ 0.25  * COALESCE(POWER(n.SLGCON_Z-o.SLGCON_Z,2),0)
		+ 0.85  * COALESCE(POWER(n.DRA_MINUS_Z-o.DRA_MINUS_Z,2),0) 
		+ 0.02  * COALESCE(POWER(n.WEIGHT_Z-o.WEIGHT_Z,2),0)
		+ 0.02 * COALESCE(POWER(n.HEIGHT_Z-o.HEIGHT_Z,2),0) 
		+ 0.1 * COALESCE(POWER(n.THROWS_Z-o.THROWS_Z,2),0)  
		+ 0.7 * COALESCE(POWER(n.start_perc_Z-o.start_perc_Z,2),0)  
		) AS SIM_DIST 
FROM bp_pecota2020_ten.sim_seed_pitcher_z_career_now n                                                    ### projection targets
JOIN bp_pecota2020_ten.sim_seed_pitcher_z_career_old o ON  n.AGE=o.Age and   n.PITCHER != o.PITCHER  AND n.lvl=o.lvl      ### comp condidates 
;



DROP TABLE IF EXISTS bp_pecota2020_ten.comps_pitcher_career_matched;

CREATE TABLE   bp_pecota2020_ten.comps_pitcher_career_matched as
Select 
PITCHER,pit_id_comp, count(*) as matches, count(distinct lvl) as levels,
sum(PA+PA_COMP) as PA_PAIRED, 
sum((PA+PA_COMP)*SIM_DIST)/sum(PA+PA_COMP) as SIM_DIST
,a.fullname as NAME,b.fullname as NAME_COMP
from  bp_pecota2020_ten.comps_pitcher_raw_career_extra  
join bp_players.MasterPlayer_dd a on (PITCHER=a.playerid) join bp_players.MasterPlayer_dd b on (pit_id_comp=b.playerid)
group by PITCHER,pit_id_comp  
;

 

DROP TABLE IF EXISTS bp_pecota2020_ten.player_top_comps_raw_pitchers;

SET @num = 0;
SET @fld = '';

create table bp_pecota2020_ten.player_top_comps_raw_pitchers  
SELECT c.PITCHER, NAME,   pit_id_comp, NAME_COMP, SIM_DIST, SIM_DIST/(matches-.15 ) as SIM_DIST_ADJ, matches,PA_PAIRED
	, @num := IF(c.PITCHER = @fld,@num+1,1) AS Rank
	, @fld := c.PITCHER AS dummy
FROM bp_pecota2020_ten.comps_pitcher_career_matched c 
join (select distinct PITCHER from bp_stats.dyna_pitcher_career where lvl='mlb') a on (pit_id_comp=a.PITCHER) #this is a filter to keep all comps as MLBers
ORDER BY  c.PITCHER, SIM_DIST/(matches-.15 ) ASC;




DROP TABLE IF EXISTS bp_pecota2020_ten.comp_line_mlb_pitchers;

create table bp_pecota2020_ten.comp_line_mlb_pitchers as
SELECT   b.PITCHER,  b.NAME, 
REPLACE(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT NAME_COMP ORDER BY RANK),",",3),',',', ') AS COMPARABLES
, GROUP_CONCAT(if(rank=1,pit_id_comp,null)) as COMP_1 
, GROUP_CONCAT(if(rank=1,NAME_COMP,null)) as COMP_1_NAME 
, GROUP_CONCAT(if(rank=2,pit_id_comp,null)) as COMP_2 
, GROUP_CONCAT(if(rank=2,NAME_COMP,null)) as COMP_2_NAME 
, GROUP_CONCAT(if(rank=3,pit_id_comp,null)) as COMP_3
, GROUP_CONCAT(if(rank=3,NAME_COMP,null)) as COMP_3_NAME 
FROM bp_pecota2020_ten.player_top_comps_raw_pitchers b
join bp_book20.bp20playerlist a on (PITCHER=playerid) 
WHERE Rank <= 3 and a.team !=''
GROUP BY PITCHER;

 




