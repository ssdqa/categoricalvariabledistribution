# Multi Site, Anomaly, Longitudinal Output for Categorical Variable Distribution Module

Multi Site, Anomaly, Longitudinal Output for Categorical Variable
Distribution Module

## Usage

``` r
cvd_ms_anom_la(process_output, filt)
```

## Arguments

- process_output:

  *tabular output* \| The output from `cvd_process`

- filt:

  *numeric/string or vector* \| The specific code(s) that should be the
  focus of the analysis

## Value

three graphs:

1.  Loess smoothed line graph that shows the proportion of a code across
    time with the Euclidean Distance associated with each line

2.  same as (1) but displaying the raw, unsmoothed proportion

3.  a radial bar graph displaying the Euclidean Distance value for each
    site, where the color is the average proportion across time
