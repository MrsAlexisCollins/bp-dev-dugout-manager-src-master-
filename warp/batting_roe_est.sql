-- bp_warp.roe_est_lg
DROP TABLE IF EXISTS legacy_models.batting_roe_est;
DROP MATERIALIZED VIEW IF EXISTS legacy_models.batting_roe_est;

CREATE MATERIALIZED VIEW legacy_models.batting_roe_est AS (
SELECT b.season, b.level_id, b.league
    , b.batter
    , b.r
    , b.h
    , b.hr
    , b.bb
    , b.b1
    , b.b2
    , b.b3
    , b.sb
    , b.pa
    , b.ab
    , b.so
    , lat1.roe
    , b.pa - b.h - b.bb - lat1.roe AS eo
    , lat2.sb_rt_est
    , CASE WHEN b.cs IS NOT NULL THEN b.cs
      WHEN lat2.sb_rt_est = 0 THEN NULL 
      ELSE -b.sb*(lat2.sb_rt_est - 1)/lat2.sb_rt_est 
      END AS cs
FROM (
  SELECT gs.season, gs.level_id, ht.league
    -- omitting as unused: division, name, age, primary_pos_label,
    -- a whole bunch of stat columns
    , s.batter_id AS batter
    , sum(s.runs) AS r
    , sum(s.hits) AS h
    , sum(s.homeruns) AS hr
    , sum(s.base_on_balls + s.intentional_walks) AS bb
    , sum(s.caught_stealing) AS cs
    , sum(s.hits - s.doubles - s.triples - s.homeruns) AS b1
    , sum(s.doubles) AS b2
    , sum(s.triples) AS b3
    , sum(s.stolen_bases) AS sb
    , sum(s.plate_appearances) AS pa
    , sum(s.atbats) AS ab
    , sum(s.strikeouts) AS so
  FROM mlbapi.stats_batting s
  LEFT JOIN mlbapi.games_schedule_deduped gs USING (game_pk)
  LEFT JOIN mlbapi.teams ht ON gs.home_team = ht.id
  WHERE gs.level_id = 1 AND gs.game_type = 'R' 
    AND left(gs.status_code, 1) = 'F'
  GROUP BY gs.season, gs.level_id, ht.league, s.batter_id) b 
LEFT JOIN legacy_models.roe_est_lg r USING (season, level_id, league),
LATERAL (SELECT 
  .59*r.e_bip*(b.ab - CASE WHEN b.so IS NULL THEN r.so_rt * (b.ab - b.h)
    ELSE b.so END) AS roe
) lat1,
LATERAL (SELECT
  CASE WHEN (b.b1 + b.bb + lat1.roe) = 0 THEN NULL
    ELSE 1.0017*power(b.sb/(b.b1 + b.bb + lat1.roe)::double precision, 0.2005)
  END AS sb_rt_est
) lat2
);


GRANT SELECT ON legacy_models.batting_roe_est TO PUBLIC;
GRANT ALL PRIVILEGES ON legacy_models.batting_roe_est TO models;

