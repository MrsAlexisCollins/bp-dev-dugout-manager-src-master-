-- bp_warp.roe_est_lg

DROP TABLE IF EXISTS legacy_models.roe_est_lg;
DROP MATERIALIZED VIEW IF EXISTS legacy_models.roe_est_lg;

CREATE MATERIALIZED VIEW legacy_models.roe_est_lg AS (
SELECT b.*, p.ipouts, p.p_so, f.dp2, f.e, f.c_po, f.c_a
  , b.ab - b.h + b.sh + b.sf - f.dp2 - b.cs AS estouts
  , b.ab - b.h + b.sh + b.sf - f.dp2 - b.cs - p.ipouts AS diff
  , f.e/(p.ipouts - p.p_so - f.dp2 - b.cs - b.hr)::double precision AS e_bip
  , f.c_po/b.ab::double precision AS so_ab_est
  , p.p_so/b.ab::double precision AS so_ab_act
  , p.p_so/(b.ab - b.h)::double precision AS so_rt
FROM (
  SELECT gs.season, gs.level_id, ht.league
    , SUM(s.atbats) AS ab
    , SUM(s.sac_bunts) AS sh
    , SUM(s.sac_flies) AS sf
    , SUM(s.hits) AS h
    , SUM(s.homeruns) AS hr
    , SUM(s.ground_into_double_play) AS dp
    , SUM(s.strikeouts) AS so
    , SUM(s.caught_stealing) AS cs
  FROM mlbapi.stats_batting s
  LEFT JOIN mlbapi.games_schedule_deduped gs USING (game_pk)
  LEFT JOIN mlbapi.teams ht ON gs.home_team = ht.id
  WHERE gs.level_id = 1 AND gs.game_type = 'R' 
    AND left(gs.status_code, 1) = 'F'
  GROUP BY gs.season, gs.level_id, ht.league) b 
LEFT JOIN (
  SELECT gs.season, gs.level_id, ht.league
    , SUM(s.outs) AS ipouts 
    , SUM(s.strikeouts) AS p_so
  FROM mlbapi.stats_pitching s
  LEFT JOIN mlbapi.games_schedule_deduped gs USING (game_pk)
  LEFT JOIN mlbapi.teams ht ON gs.home_team = ht.id
  WHERE gs.level_id = 1 AND gs.game_type = 'R' 
    AND left(gs.status_code, 1) = 'F'
  GROUP BY gs.season, gs.level_id, ht.league) p 
USING (season, level_id, league)
LEFT JOIN (
  SELECT sd.season, t.level AS level_id, t.league
    , SUM(sd.double_plays) AS dp2 
    , SUM(sd.errors) AS e 
    , SUM(CASE sd.position WHEN 'C' THEN sd.put_outs ELSE 0 END) AS c_po 
    , SUM(CASE sd.position WHEN 'C' THEN sd.assists ELSE 0 END) AS c_a
  FROM (
    SELECT DISTINCT ON (id, season, team, position)
      season, team, id, position, assists, put_outs, errors, double_plays
    FROM mlbapi.stats_ytd_fielding 
    ORDER BY id, season, team, position, timestamp DESC
  ) sd -- latest stats line for a season/team/player/position
  LEFT JOIN mlbapi.teams t ON sd.team = t.id
  WHERE t.level = 1 -- mlb
  GROUP BY sd.season, t.level, t.league) f
USING (season, level_id, league)
);

GRANT SELECT ON legacy_models.roe_est_lg TO PUBLIC;
GRANT ALL PRIVILEGES ON legacy_models.roe_est_lg TO models;
