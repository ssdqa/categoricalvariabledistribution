# Categorical Variable Distribution - PCORnet Version

Categorical Variable Distribution - PCORnet Version

## Usage

``` r
cvd_process_pcornet(
  cohort,
  domain_tbl,
  concept_set,
  multi_or_single_site = "single",
  anomaly_or_exploratory = "exploratory",
  p_value = 0.9,
  time = TRUE,
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

a data frame with the distribution from the specified domain/concept
which will be further summarized in `cvd_process`
