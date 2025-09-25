## code to prepare `cvd_domain_tbl` dataset goes here

cvd_domain_tbl <- dplyr::tibble('domain' = c('measurement'),
                                 'concept_field' = c('measurement_concept_id'),
                                 'vs_field' = c('unit_concept_id'),
                                 'date_field' = c('measurement_date'))

usethis::use_data(cvd_domain_tbl, overwrite = TRUE)
