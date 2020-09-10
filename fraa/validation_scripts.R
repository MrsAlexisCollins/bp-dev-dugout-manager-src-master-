
re_diff.test <- full_join(re_diff_data_ms, re_diff_data, 
                  by = c("year_id" = "season", 
                         "start_bases_cd" = "startbases_cd", 
                         "outs_ct", "event_outs_ct", 
                         "end_bases_cd" = "endbases_cd")) %>% 
  dplyr::select(year_id, lvl, level_id, 
                start_bases_cd, outs_ct, end_bases_cd, 
                event_outs_ct, Num, num_events, RE_DIFF, re_diff)

re_diff.test.summary <-
  re_diff.test %>% mutate(events_diff = Num - num_events) %>% filter(events_diff != 0) %>% dplyr::select(-c(re_diff, RE_DIFF)) %>% arrange(events_diff)

play_value_raw.test <- full_join(play_value_raw_R_ms, play_value_raw_R, 
                          by = c("year_id" = "season", "PM", "BAT_TYPE" = "bat_type"),
                          suffix = c(".MS", ".PG"))
