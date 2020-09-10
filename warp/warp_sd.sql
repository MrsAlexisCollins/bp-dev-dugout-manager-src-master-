-- bp_warp.roe_est_lg

DROP TABLE IF EXISTS legacy_models.warp_sd_raw;
DROP MATERIALIZED VIEW IF EXISTS legacy_models.warp_sd_raw;

CREATE TABLE legacy_models.warp_sd_raw (
    season          int4,
    level_id        int4 REFERENCES mlbapi.levels (id),
    rep_pct         double precision,
    vs_reference    double precision,
    off_warp_pct    double precision
);

DROP TABLE IF EXISTS legacy_models.warp_sd;
DROP VIEW IF EXISTS legacy_models.warp_sd;

CREATE VIEW legacy_models.warp_sd AS (
  SELECT season, level_id
    , avg(rep_pct) OVER nine_season_window AS rep_pct
    , avg(vs_reference) OVER nine_season_window AS vs_reference
    , avg(off_warp_pct) OVER nine_season_window AS off_warp_pct
  FROM legacy_models.warp_sd_raw
  WINDOW nine_season_window AS (
    PARTITION BY level_id
    ORDER BY season
    RANGE BETWEEN 4 PRECEDING AND 4 FOLLOWING
  )
  ORDER BY season, level_id
);


GRANT SELECT ON legacy_models.warp_sd_raw TO PUBLIC;
GRANT ALL PRIVILEGES ON legacy_models.warp_sd_raw TO models;
GRANT SELECT ON legacy_models.warp_sd TO PUBLIC;
GRANT ALL PRIVILEGES ON legacy_models.warp_sd TO models;

