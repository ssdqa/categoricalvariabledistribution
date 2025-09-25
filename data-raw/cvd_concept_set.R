## code to prepare `cvd_concept_set` dataset goes here

cvd_concept_set <- dplyr::tibble('concept_id' = c(3025315,
                                                  3013762),
                                 'concept_name' = c('Body weight',
                                                    'Body weight Measured'),
                                 'concept_code' = c('29463-7',
                                                    '3141-9'),
                                 'vocabulary_id' = c('LOINC',
                                                     'LOINC'))

usethis::use_data(cvd_concept_set, overwrite = TRUE)
