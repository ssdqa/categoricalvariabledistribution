## code to prepare `cvd_domain_file` dataset goes here

cvd_domain_file <- dplyr::tibble('domain' = c('drug_exposure'),
                                 'concept_field' = c('drug_concept_id'),
                                 'vs_field' = c('dose_unit_concept_id'),
                                 'date_field' = c('drug_exposure_start_date'))

usethis::use_data(cvd_domain_file, overwrite = TRUE)
