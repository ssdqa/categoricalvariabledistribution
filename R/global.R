output_cols <- c("start_date", "end_date", "time_start", "time_end", "time_increment",
                 "site", "prop_concept", "mean_val", "sd_val", "median_val", "mad_val",
                 "anomaly_yn", "ct_concept", "ct_denom", "concept_id",
                 "mean_allsiteprop", "dist_eucl_mean", "text_raw", "cl", "lcl",
                 "mean_site_loess", "site_loess", "str_wrap",
                 "text_smooth", "tooltip", "ucl", "x", "y")

utils::globalVariables(output_cols)
