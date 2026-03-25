# CVD Sample Concept Set

A sample version of the table structure expected for the `concept_set`
parameter in the `cvd_process` function. The user should recreate this
file and include their own clinical concepts of interest.

## Usage

``` r
cvd_concept_set
```

## Format

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with 2
rows and 4 columns.

## Details

@format \## cvd_concept_set A data frame with 4 columns:

- concept_id:

  The OMOP concept_id; if the PCORnet CDM is being used, default this
  column to a random integer like the row number

- concept_name:

  (optional)The string name of the concept

- concept_code:

  The original code associated with the concept_id

- vocabulary_id:

  The vocabulary associated with the concept; if the PCORnet CDM is
  being used, ensure that the values of this field match the vocabulary
  abbreviations used in the CDM itself
