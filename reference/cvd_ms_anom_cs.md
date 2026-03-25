# Multi Site, Anomaly, Cross-Sectional Output for Categorical Variable Distribution Module

Multi Site, Anomaly, Cross-Sectional Output for Categorical Variable
Distribution Module

## Usage

``` r
cvd_ms_anom_cs(process_output)
```

## Arguments

- process_output:

  *tabular output* \| The output from `cvd_process`

## Value

A dot plot, returned as a ggplot object, with site on x axis,
categorical valueset item on y axis, with dot size representing mean
proportion for the given valueset item across all sites, color
representing proportion of given site's values for the given valueset
item. Anomalies are distinguished with star shapes as opposed to the
normal circles.
