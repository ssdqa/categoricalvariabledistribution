# make sure errors are raised for insufficient inputs
test_that('cohort table must be provided', {

  cht <- data.frame('person_id' = c(1000, 1001),
                    'site' = c('a', 'b'),
                    'start_date' = c('2007-01-01','2007-01-01'),
                    'end_date' = c('2024-01-01','2024-01-01'))

  expect_error(cvd_process(domain_tbl=categoricalvariabledistribution::cvd_domain_tbl,
                           concept_set=categoricalvariabledistribution::cvd_concept_set,
                           omop_or_pcornet='omop',
                           multi_or_single_site = 'single_site',
                           anomaly_or_exploratory='exploratory',
                           time = FALSE))
})
test_that('cohort table must have correct columns', {

  cht <- data.frame('person_id' = c(1000, 1001),
                    'site' = c('a', 'b'),
                    'end_date' = c('2011-01-01','2009-01-01'))

  expect_error(cvd_process(cohort_tbl=cht,
                           domain_tbl=categoricalvariabledistribution::cvd_domain_tbl,
                           concept_set=categoricalvariabledistribution::cvd_concept_set,
                           omop_or_pcornet='omop',
                           multi_or_single_site = 'single_site',
                           anomaly_or_exploratory='exploratory',
                           time = FALSE))
})
test_that('only single & multi are allowed inputs', {

  cht <- data.frame('person_id' = c(1, 2),
                    'site' = c('a', 'b'),
                    'start_date' = c('2007-01-01','2008-01-01'),
                    'end_date' = c('2011-01-01','2009-01-01'))

  expect_error(cvd_process(cohort=cohort_tbl,
                           domain_tbl=categoricalvariabledistribution::cvd_domain_tbl,
                           concept_set=categoricalvariabledistribution::cvd_concept_set,
                           omop_or_pcornet='omop',
                           multi_or_single_site = 'single_site',
                           anomaly_or_exploratory='exploratory',
                           time = FALSE))
})
test_that('concept set must be provided', {

  cht <- data.frame('person_id' = c(1000, 1001),
                    'site' = c('a', 'b'),
                    'start_date' = c('2007-01-01','2008-01-01'),
                    'end_date' = c('2011-01-01','2009-01-01'))

  expect_error(cvd_process(cohort=cohort_tbl,
                           domain_tbl=categoricalvariabledistribution::cvd_domain_tbl,
                           omop_or_pcornet='omop',
                           multi_or_single_site = 'single',
                           anomaly_or_exploratory='exploratory',
                           time = FALSE))
})

## test process function

test_that('cvd ss/ms exp nt -- omop', {

  rlang::is_installed("DBI")
  rlang::is_installed("readr")
  rlang::is_installed('RSQLite')

  conn <- mk_testdb_omop()

  initialize_dq_session(session_name = 'cvd_process_test',
                        working_directory = getwd(),
                        db_conn = conn,
                        is_json = FALSE,
                        file_subdirectory = 'testdata',
                        cdm_schema = NA)

  cht <- cdm_tbl('person') %>% distinct(person_id) %>%
    mutate(start_date = as.Date(-5000),
           end_date = as.Date(15000),
           site = ifelse(person_id %in% c(1:6), 'synth1', 'synth2'))

  expect_no_error(cvd_process(cohort=cht,
                              domain_tbl=categoricalvariabledistribution::cvd_domain_tbl,
                              concept_set=categoricalvariabledistribution::cvd_concept_set,
                              omop_or_pcornet='omop',
                              multi_or_single_site = 'single',
                              anomaly_or_exploratory='exploratory',
                              time = FALSE))
})
test_that('cvd ss/ms exp nt -- pcornet', {

  rlang::is_installed("DBI")
  rlang::is_installed("readr")
  rlang::is_installed('RSQLite')

  conn <- mk_testdb_omop()

  initialize_dq_session(session_name = 'cvd_process_test',
                        working_directory = getwd(),
                        db_conn = conn,
                        is_json = FALSE,
                        file_subdirectory = 'testdata',
                        cdm_schema = NA)

  cht <- cdm_tbl('person') %>% distinct(person_id) %>%
    mutate(start_date = as.Date(-5000),
           end_date = as.Date(20000),
           site = ifelse(person_id %in% c(1:6), 'synth1', 'synth2'))

  expect_no_error(cvd_process(cohort=cht,
                              domain_tbl=categoricalvariabledistribution::cvd_domain_tbl,
                              concept_set=categoricalvariabledistribution::cvd_concept_set,
                              omop_or_pcornet='pcornet',
                              multi_or_single_site = 'single',
                              anomaly_or_exploratory='exploratory',
                              time = FALSE))
})
test_that('cvd ms exp la yearly-- omop', {

  rlang::is_installed("DBI")
  rlang::is_installed("readr")
  rlang::is_installed('RSQLite')

  conn <- mk_testdb_omop()

  initialize_dq_session(session_name = 'cvd_process_test',
                        working_directory = getwd(),
                        db_conn = conn,
                        is_json = FALSE,
                        file_subdirectory = 'testdata',
                        cdm_schema = NA)

  cht <- cdm_tbl('person') %>% distinct(person_id) %>%
    mutate(start_date = as.Date(-5000),
           end_date = as.Date(20000),
           site = ifelse(person_id %in% c(1:6), 'synth1', 'synth2'))

  expect_no_error(cvd_process(cohort=cht,
                              domain_tbl=categoricalvariabledistribution::cvd_domain_tbl,
                              concept_set=categoricalvariabledistribution::cvd_concept_set,
                              omop_or_pcornet='omop',
                              multi_or_single_site = 'multi',
                              anomaly_or_exploratory='exploratory',
                              time = TRUE))
})
test_that('cvd ms exp la monthly-- omop', {

  rlang::is_installed("DBI")
  rlang::is_installed("readr")
  rlang::is_installed('RSQLite')

  conn <- mk_testdb_omop()

  initialize_dq_session(session_name = 'cvd_process_test',
                        working_directory = getwd(),
                        db_conn = conn,
                        is_json = FALSE,
                        file_subdirectory = 'testdata',
                        cdm_schema = NA)

  cht <- cdm_tbl('person') %>% distinct(person_id) %>%
    mutate(start_date = as.Date(-5000),
           end_date = as.Date(20000),
           site = ifelse(person_id %in% c(1:6), 'synth1', 'synth2'))

  expect_no_error(cvd_process(cohort=cht,
                              domain_tbl=categoricalvariabledistribution::cvd_domain_tbl,
                              concept_set=categoricalvariabledistribution::cvd_concept_set,
                              omop_or_pcornet='omop',
                              multi_or_single_site = 'multi',
                              anomaly_or_exploratory='exploratory',
                              time = TRUE,
                              time_period='month'))
})



