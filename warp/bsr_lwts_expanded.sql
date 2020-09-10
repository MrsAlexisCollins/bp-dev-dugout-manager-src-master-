-- bp_warp.roe_est_lg

DROP TABLE IF EXISTS legacy_models.bsr_lwts_expanded;
DROP MATERIALIZED VIEW IF EXISTS legacy_models.bsr_lwts_expanded;

CREATE MATERIALIZED VIEW legacy_models.bsr_lwts_expanded AS (
SELECT season, level_id, league, event
  , CASE event 
      WHEN 'B1'  THEN b1
      WHEN 'B2'  THEN b2
      WHEN 'B3'  THEN b3
      WHEN 'HR'  THEN hr
      WHEN 'BB'  THEN bb
      WHEN 'ROE' THEN roe
      WHEN 'eO'  THEN eo
      WHEN 'SB'  THEN eo
      WHEN 'CS'  THEN eo
      ELSE NULL
    END AS num
  , ((b.actb + b.c)*(b.a*(w.b + CASE event WHEN 'SB' THEN 0 
       WHEN 'CS' THEN 0 ELSE b.badj END) + b.actb*w.a) - 
     b.a*b.actb*((w.b + CASE event WHEN 'SB' THEN 0 
       WHEN 'CS' THEN 0 ELSE b.badj END) + w.c)) / 
     POWER(b.actb + b.c,2) + w.d AS lwts_out
  , (((b.actb + b.c)*(b.a*(w.b + CASE event WHEN 'SB' THEN 0 
       WHEN 'CS' THEN 0 ELSE b.badj END) + b.actb*w.a) - 
     b.a*b.actb*((w.b + CASE event WHEN 'SB' THEN 0 
       WHEN 'CS' THEN 0 ELSE b.badj END) + w.c)) / 
     POWER(b.actb + b.c,2) + w.d) - w.c*b.r/b.eo AS lwts_aa
  , (((b.actb + b.c)*(b.a*(w.b + CASE event WHEN 'SB' THEN 0 
       WHEN 'CS' THEN 0 ELSE b.badj END) + b.actb*w.a) - 
     b.a*b.actb*((w.b + CASE event WHEN 'SB' THEN 0 
       WHEN 'CS' THEN 0 ELSE b.badj END) + w.c)) / 
     POWER(b.actb + b.c,2) + w.d) - w.c*b.r/b.eo + b.r/b.pa AS lwts_pa
  , b.r/b.pa AS r_pa
  , b.r/b.eo AS r_o
FROM legacy_models.bsr_b_est b, legacy_models.bsr_event_weights w
);

GRANT SELECT ON legacy_models.bsr_lwts_expanded TO PUBLIC;
GRANT ALL PRIVILEGES ON legacy_models.bsr_lwts_expanded TO models;

