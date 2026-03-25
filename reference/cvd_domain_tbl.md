# CVD Sample Domain Table

A sample version of the table structure expected for the `domain_tbl`
parameter in the `cvd_process` function. The user should recreate this
table and include their own domain definitions.

## Usage

``` r
cvd_domain_tbl
```

## Format

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with 1
rows and 4 columns.

## Details

\#' @format \## cvd_domain_tbl

- domain:

  The name of the CDM table associated with the domain of interest

- concept_field:

  The name of the column in the domain table that contains the concepts
  of interest listed in the concept_set file.

- vs_field:

  The name of the column in the domain table for which to show a
  distribution of categorical values.

- date_field:

  The name of the column in the domain table that contains dates to be
  used for time-based filtering.
