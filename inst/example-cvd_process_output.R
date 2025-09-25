
#' Source setup file
source(system.file('setup.R', package = 'categoricalvariabledistribution'))

#' Create in-memory RSQLite database using data in extdata directory
conn <- mk_testdb_omop()

#' Establish connection to database and generate internal configurations
initialize_dq_session(session_name = 'cvd_process_test',
                      working_directory = getwd(),
                      db_conn = conn,
                      is_json = FALSE,
                      file_subdirectory = 'extdata',
                      cdm_schema = NA)

#' Build mock study cohort
cohort_tbl <- cdm_tbl('person') %>% dplyr::distinct(person_id) %>%
  dplyr::mutate(start_date = as.Date(-5000), # RSQLite does not store date objects,
                # hence the numerics
                end_date = as.Date(15000),
                site = ifelse(person_id %in% c(1:6), 'synth1', 'synth2'))

#' Execute `cvd_process` function
#' This example will use the single site, exploratory, cross sectional
#' configuration
cvd_process_example <- cvd_process(cohort=cohort_tbl,
                                  domain_tbl=categoricalvariabledistribution::cvd_domain_file,
                                  concept_set=categoricalvariabledistribution::cvd_concept_set,
                                  omop_or_pcornet='omop',
                                  multi_or_single_site = 'single',
                                  anomaly_or_exploratory='exploratory',
                                  time = FALSE)

cvd_process_example

#' Execute `cvd_output` function
#' The output was edited for a better indication of what the visualization will
#' look like.
#' The 0s are a limitation of the small sample data set used for this example
cvd_output_example <- cvd_output(process_output = cvd_process_example)

cvd_output_example

#' Easily convert the graph into an interactive ggiraph or plotly object with
#' `make_interactive_squba()`

make_interactive_squba(cvd_output_example)
