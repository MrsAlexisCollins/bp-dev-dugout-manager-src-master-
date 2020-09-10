-- bp_warp.roe_est_lg

DROP TABLE IF EXISTS legacy_models.bsr_b_est;
DROP MATERIALIZED VIEW IF EXISTS legacy_models.bsr_b_est;

CREATE MATERIALIZED VIEW legacy_models.bsr_b_est AS (
SELECT season, level_id, league
  , r, a, b, c, d
  , lat1.actb
  , lat1.actb/b::double precision as bmult
  , (lat1.actb - b)/pa::double precision as badj
  , pa, ab, pa - bb - h - roe AS eo, h, b1, b2, b3, hr, so, bb, roe
FROM (SELECT season, level_id, league
  , SUM(r) AS r
  , SUM(h - hr + bb + roe - coalesce(cs, 0))::double precision AS a
  , SUM(.78*(b1 + roe) + 2.34*b2 + 3.9*b3 + 2.34*hr + .039*bb + 
        1.14*coalesce(sb, 0))::double precision AS b
  , SUM(pa - bb - h - roe + coalesce(cs, 0))::double precision AS c
  , SUM(hr) AS d
  , SUM(pa) AS pa
  , SUM(ab) AS ab
  , SUM(h) AS h
  , SUM(b1) AS b1
  , SUM(b2) AS b2
  , SUM(b3) AS b3
  , SUM(hr) AS hr
  , SUM(so) AS so
  , SUM(bb) AS bb
  , SUM(roe) AS roe
  , SUM(coalesce(sb, 0)) AS sb
  , SUM(coalesce(cs, 0)) AS cs
  FROM legacy_models.batting_roe_est b
  GROUP BY season, level_id, league) a
, LATERAL (SELECT
  (r - d)*c/(a - r + d)::double precision AS actb
) lat1
WHERE level_id = 1
);

GRANT SELECT ON legacy_models.bsr_b_est TO PUBLIC;
GRANT ALL PRIVILEGES ON legacy_models.bsr_b_est TO models;

