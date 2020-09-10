DROP VIEW IF EXISTS models.lwts_event_baseout_retrosheet;
DROP MATERIALIZED VIEW IF EXISTS models.lwts_event_baseout;
CREATE MATERIALIZED VIEW models.lwts_event_baseout AS (SELECT
    COUNT(*) AS num_events,
    e.season,
    e.level_id,
    e.event_type,
    e.outs_pre,
    e.onfirst_pre,
    e.onsecond_pre,
    e.onthird_pre,
    e.outs_post,
    e.onfirst_post,
    e.onsecond_post,
    e.onthird_post,
    AVG(CASE WHEN e.outs_post = 3 THEN 0 ELSE COALESCE(re_post.avg, 0) END - 
        re_pre.avg) AS re_diff,
    AVG(CASE WHEN e.outs_post = 3 THEN 0 ELSE COALESCE(re_post.avg, 0) END - 
        re_pre.avg + score_post - score_pre) AS lwts,
    AVG(re_pre.avg) AS re_pre,
    AVG(CASE WHEN e.outs_post = 3 THEN 0 ELSE COALESCE(re_post.avg, 0) END) AS re_post
FROM (
    SELECT 
        gs.season,
        gs.level_id,
        events.event_type,
        bo.outs_start AS outs_pre,
        bo.firstbase_start IS NOT NULL AS onfirst_pre,
        bo.secondbase_start IS NOT NULL AS onsecond_pre,
        bo.thirdbase_start IS NOT NULL AS onthird_pre,
        CASE plays.half_inning WHEN 'top' THEN bo.away_score_start
            ELSE bo.home_score_start END AS score_pre,
        bo.outs_end AS outs_post,
        bo.firstbase_end IS NOT NULL AS onfirst_post,
        bo.secondbase_end IS NOT NULL AS onsecond_post,
        bo.thirdbase_end IS NOT NULL AS onthird_post,
        CASE plays.half_inning WHEN 'top' THEN bo.away_score_end
            ELSE bo.home_score_end END AS score_post
    FROM mlbapi.play_events events
    LEFT JOIN mlbapi.plays plays USING (game_pk, at_bat_index)
    LEFT JOIN mlbapi.games_schedule_deduped gs USING (game_pk)
    LEFT JOIN mlbapi.baseout bo USING (game_pk, at_bat_index, event_index)
    WHERE gs.game_type = 'R' AND LEFT(gs.status_code, 1) = 'F' 
      AND gs.level_id = 1 AND gs.season >= 2019
      AND events.event_type IS NOT NULL
    UNION ALL
    (SELECT DISTINCT ON (plays.game_pk, plays.at_bat_index)
        gs.season,
        gs.level_id,
        plays.event_type,
        bo.outs_pre,
        bo.firstbase_pre IS NOT NULL AS onfirst_pre,
        bo.secondbase_pre IS NOT NULL AS onsecond_pre,
        bo.thirdbase_pre IS NOT NULL AS onthird_pre,
        CASE plays.half_inning WHEN 'top' THEN bo.away_score_pre
            ELSE bo.home_score_pre END AS score_pre,
        bo.outs_end AS outs_post,
        bo.firstbase_end IS NOT NULL AS onfirst_post,
        bo.secondbase_end IS NOT NULL AS onsecond_post,
        bo.thirdbase_end IS NOT NULL AS onthird_post,
        CASE plays.half_inning WHEN 'top' THEN bo.away_score_end
            ELSE bo.home_score_end END AS score_post
    FROM mlbapi.play_events events 
    LEFT JOIN mlbapi.plays plays USING (game_pk, at_bat_index)
    LEFT JOIN mlbapi.games_schedule_deduped gs USING (game_pk)
    LEFT JOIN mlbapi.baseout bo USING (game_pk, at_bat_index, event_index)
    WHERE gs.game_type = 'R' AND LEFT(gs.status_code, 1) = 'F'
      AND gs.level_id = 1 AND gs.season >= 2019
    ORDER BY plays.game_pk, plays.at_bat_index, events.event_index DESC)
) e
LEFT JOIN models.re re_pre ON
    e.season = re_pre.season AND
    e.level_id = re_pre.level_id AND
    e.outs_pre = re_pre.outs_pre AND
    e.onfirst_pre = re_pre.onfirst_pre AND
    e.onsecond_pre = re_pre.onsecond_pre AND
    e.onthird_pre = re_pre.onthird_pre
LEFT JOIN models.re re_post ON
    e.season = re_post.season AND
    e.level_id = re_post.level_id AND
    e.outs_post = re_post.outs_pre AND
    e.onfirst_post = re_post.onfirst_pre AND
    e.onsecond_post = re_post.onsecond_pre AND
    e.onthird_post = re_post.onthird_pre
GROUP BY e.season, e.level_id, e.event_type, 
    e.outs_pre, e.onfirst_pre, e.onsecond_pre, e.onthird_pre,
    e.outs_post, e.onfirst_post, e.onsecond_post, e.onthird_post
ORDER BY e.season, e.level_id, e.event_type, e.outs_pre,
    (CASE e.onfirst_pre   WHEN 't' THEN 2 ELSE 0 END +
     CASE e.onsecond_pre  WHEN 't' THEN 3 ELSE 0 END +
     CASE e.onthird_pre   WHEN 't' THEN 4 ELSE 0 END), e.outs_post,
    (CASE e.onfirst_post  WHEN 't' THEN 2 ELSE 0 END +
     CASE e.onsecond_post WHEN 't' THEN 3 ELSE 0 END +
     CASE e.onthird_post  WHEN 't' THEN 4 ELSE 0 END)
);

CREATE VIEW models.lwts_event_baseout_retrosheet AS (
  SELECT 
    SUM(lebo.num_events) AS num_events,
    lebo.season,
    lebo.level_id,
    etr.event_cd,
    lebo.outs_pre,
    lebo.onfirst_pre,
    lebo.onsecond_pre,
    lebo.onthird_pre,
    lebo.outs_post,
    lebo.onfirst_post,
    lebo.onsecond_post,
    lebo.onthird_post,
    SUM(lebo.re_diff * lebo.num_events)/SUM(lebo.num_events)::NUMERIC AS re_diff,
    SUM(lebo.lwts * lebo.num_events)/SUM(lebo.num_events)::NUMERIC AS lwts,
    SUM(lebo.re_pre * lebo.num_events)/SUM(lebo.num_events)::NUMERIC AS re_pre,
    SUM(lebo.re_post * lebo.num_events)/SUM(lebo.num_events)::NUMERIC AS re_post
  FROM models.lwts_event_baseout lebo
  LEFT JOIN mlbapi.event_types_retrosheet etr USING (event_type)
  GROUP BY lebo.season, lebo.level_id, etr.event_cd, 
    lebo.outs_pre, lebo.onfirst_pre, lebo.onsecond_pre, lebo.onthird_pre,
    lebo.outs_post, lebo.onfirst_post, lebo.onsecond_post, lebo.onthird_post
  ORDER BY lebo.season, lebo.level_id, etr.event_cd, lebo.outs_pre,
    (CASE lebo.onfirst_pre   WHEN 't' THEN 2 ELSE 0 END +
     CASE lebo.onsecond_pre  WHEN 't' THEN 3 ELSE 0 END +
     CASE lebo.onthird_pre   WHEN 't' THEN 4 ELSE 0 END), lebo.outs_post,
    (CASE lebo.onfirst_post  WHEN 't' THEN 2 ELSE 0 END +
     CASE lebo.onsecond_post WHEN 't' THEN 3 ELSE 0 END +
     CASE lebo.onthird_post  WHEN 't' THEN 4 ELSE 0 END)
);

