-- bp_warp.roe_est_lg

DROP TABLE IF EXISTS legacy_models.bsr_lwts;
DROP MATERIALIZED VIEW IF EXISTS legacy_models.bsr_lwts;

CREATE MATERIALIZED VIEW legacy_models.bsr_lwts AS (
SELECT season, level_id, league
  , avg(r_pa) AS r_pa, avg(r_o) AS r_o
  , sum(CASE event WHEN 'B1'  THEN lwts_aa ELSE 0 END) AS b1
  , sum(CASE event WHEN 'B2'  THEN lwts_aa ELSE 0 END) AS b2
  , sum(CASE event WHEN 'B3'  THEN lwts_aa ELSE 0 END) AS b3
  , sum(CASE event WHEN 'HR'  THEN lwts_aa ELSE 0 END) AS hr
  , sum(CASE event WHEN 'ROE' THEN lwts_aa ELSE 0 END) AS roe
  , sum(CASE event WHEN 'BB'  THEN lwts_aa ELSE 0 END) AS bb
  , sum(CASE event WHEN 'eO'  THEN lwts_aa ELSE 0 END) AS eo
  , sum(CASE event WHEN 'SB'  THEN lwts_aa ELSE 0 END) AS sb
  , sum(CASE event WHEN 'CS'  THEN lwts_aa ELSE 0 END) AS cs
FROM legacy_models.bsr_lwts_expanded
GROUP BY season, level_id, league
);

GRANT SELECT ON legacy_models.bsr_lwts TO PUBLIC;
GRANT ALL PRIVILEGES ON legacy_models.bsr_lwts TO models;

