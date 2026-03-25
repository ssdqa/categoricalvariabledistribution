# Single Site, Anomaly, Longitudinal Output for Categorical Variable Distribution Module

Single Site, Anomaly, Longitudinal Output for Categorical Variable
Distribution Module

## Usage

``` r
cvd_ss_anom_la(process_output, filt)
```

## Arguments

- process_output:

  *tabular output* \| The output from `cvd_process`

- filt:

  *numeric/string or vector* \| The specific code(s) that should be the
  focus of the analysis

## Value

if analysis was executed by year or greater, a P Prime control chart is
returned with outliers marked with orange dots

        if analysis was executed by month or smaller, an STL regression is
        conducted and outliers are marked with red dots. the graphs representing
        the data removed in the regression are also returned
