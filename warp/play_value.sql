-- bp_warp.roe_est_lg

DROP TABLE IF EXISTS legacy_models.play_value;
DROP VIEW IF EXISTS legacy_models.play_value;

CREATE VIEW legacy_models.play_value AS (
SELECT season, level_id, league
  , SUM(CASE event WHEN 'eO' THEN 0 ELSE lwts_aa*num END)/
    SUM(CASE event WHEN 'eO' THEN 0 ELSE num END) -
    SUM(CASE event WHEN 'eO' THEN lwts_aa ELSE 0 END) AS lwts
FROM legacy_models.bsr_lwts_expanded
WHERE event IN ('B1', 'B2', 'B3', 'ROE', 'eO')
GROUP BY season, level_id, league
);

GRANT SELECT ON legacy_models.play_value TO PUBLIC;
GRANT ALL PRIVILEGES ON legacy_models.play_value TO models;

