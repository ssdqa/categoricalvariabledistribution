# Categorical Variable Distribution Module Processing

This is a module that takes a concept set and a field of interest as
input and creates a distribution of the categorical values in the field
of interest. For example, a user can input a drug concept set and get
back a distribution of units associated with the drug, or a user can
input a lab test concept set and get back a distribution of units
associated with the lab results.

## Usage

``` r
cvd_process(
  cohort,
  domain_tbl = NULL,
  concept_set = NULL,
  omop_or_pcornet,
  multi_or_single_site = "single",
  anomaly_or_exploratory = "exploratory",
  p_value = 0.9,
  time = FALSE,
  time_span = c("2012-01-01", "2020-01-01"),
  time_period = "year"
)
```

## Arguments

- cohort:

  *tabular input* \| A dataframe with the cohort of patients for your
  study. Should include the columns:

  - `person_id` / `patid` \| *integer* / *character*

  - `start_date` \| *date*

  - `end_date` \| *date*

  - `site` \| *character*

- domain_tbl:

  *tabular input* \| A table with domain definitions. An example file is
  provided as `categoricalvariabledistribution::cvd_domain_file`. Should
  include the columns:

  - `domain` \| The name of the CDM table associated with the domain of
    interest

  - `concept_field` \| The name of the column in the domain table that
    contains the concepts of interest listed in the concept_set file

  - `vs_field` \| The name of the column in the domain table for which
    to show a distribution of categorical values. `date_field` \| The
    name of the column in the domain table that contains dates to be
    used for time-based filtering

- concept_set:

  *tabular input* \| An annotated concept set with the following
  columns:

  - `concept_id` \| *integer* \| required for OMOP; the concept_id of
    interest

  - `concept_name` \| *character* \| optional; the descriptive name of
    the concept

  - `concept_code` \| *character* \| required for PCORnet; the code of
    interest

  - `vocabulary_id` \| *character* \| required for PCORnet; the
    vocabulary of the code - should match what is listed in the domain
    table's vocabulary_field

- omop_or_pcornet:

  *string* \| Option to run the function using the OMOP or PCORnet CDM
  as the default CDM

  - `omop`: run the
    [`cvd_process_omop()`](https://ssdqa.github.io/categoricalvariabledistribution/reference/cvd_process_omop.md)
    function against an OMOP CDM instance

  - `pcornet`: run the
    [`cvd_process_pcornet()`](https://ssdqa.github.io/categoricalvariabledistribution/reference/cvd_process_pcornet.md)
    function against a PCORnet CDM instance

- multi_or_single_site:

  *string* \| Option to run the function on a single vs multiple sites

  - `single`: run the function for a single site

  - `multi`: run the function for multiple sites

- anomaly_or_exploratory:

  *string* \| Option to conduct an exploratory or anomaly detection
  analysis. Exploratory analyses give a high level summary of the data
  to examine the fact representation within the cohort. Anomaly
  detection analyses are specialized to identify outliers within the
  cohort.

- p_value:

  *numeric* \| the p value to be used as a threshold in the multi-site
  anomaly detection analysis

- time:

  *boolean* \| logical to determine whether to output the check across
  time

- time_span:

  *vector - length 2* \| when time = TRUE, a vector of two dates for the
  observation period of the study

- time_period:

  *string* \| when time = TRUE, this argument defines the distance
  between dates within the specified time period. Defaults to `year`,
  but other time periods such as `month` or `week` are also acceptable

## Value

a data frame with summary results that can be used for `cvd_output` to
generate graphical or tabular output

## Examples

``` r
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
#> Connected to: :memory:@NA

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
                                  domain_tbl=categoricalvariabledistribution::cvd_domain_tbl,
                                  concept_set=categoricalvariabledistribution::cvd_concept_set,
                                  omop_or_pcornet='omop',
                                  multi_or_single_site = 'single',
                                  anomaly_or_exploratory='exploratory',
                                  time = FALSE)
#> Rows: 85 Columns: 5
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (5): module, check, Always Required, Required for Check, Optional
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> Joining with `by = join_by(person_id, start_date, end_date, site, site_summ, fu_diff, fu)`
#> Error in db_query_fields.DBIConnection(con, ...): Can't query fields.
#> ℹ Using SQL: SELECT * FROM `measurement` AS `q01` WHERE (0 = 1)
#> Caused by error:
#> ! no such table: measurement

cvd_process_example
#> Error: object 'cvd_process_example' not found

#' Execute `cvd_output` function
#' The output was edited for a better indication of what the visualization will
#' look like.
#' The 0s are a limitation of the small sample data set used for this example
cvd_output_example <- cvd_output(process_output = cvd_process_example)
#> Error: object 'cvd_process_example' not found

cvd_output_example
#> Error: object 'cvd_output_example' not found

#' Easily convert the graph into an interactive ggiraph or plotly object with
#' `make_interactive_squba()`

make_interactive_squba(cvd_output_example)
#> Error: object 'cvd_output_example' not found
```
