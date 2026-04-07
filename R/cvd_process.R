#' Categorical Variable Distribution Module Processing
#'
#' This is a module that takes a concept set and a field of interest as input
#' and creates a distribution of the categorical values in the field of interest.
#' For example, a user can input a drug concept set and get back a distribution
#' of units associated with the drug, or a user can input a lab test concept set
#' and get back a distribution of units associated with the lab results.
#'
#' @param cohort *tabular input* | A dataframe with the cohort of patients for your study. Should include the columns:
#' - `person_id` / `patid` | *integer* / *character*
#' - `start_date` | *date*
#' - `end_date` | *date*
#' - `site` | *character*
#' @param domain_tbl *tabular input* | A table with domain definitions. An example file is provided as `categoricalvariabledistribution::cvd_domain_file`. Should include the columns:
#' - `domain` | The name of the CDM table associated with the domain of interest
#' - `concept_field` | The name of the column in the domain table that contains the concepts of interest listed in the concept_set file
#' - `vs_field` | The name of the column in the domain table for which to show a distribution of categorical values.
#' `date_field` | The name of the column in the domain table that contains dates to be used for time-based filtering
#' @param concept_set *tabular input* | An annotated concept set with the following columns:
#' - `concept_id` | *integer* |  required for OMOP; the concept_id of interest
#' - `concept_name` | *character* | optional; the descriptive name of the concept
#' - `concept_code` | *character* | required for PCORnet; the code of interest
#' - `vocabulary_id` | *character* | required for PCORnet; the vocabulary of the code - should match what is listed in the domain table's vocabulary_field
#' @param omop_or_pcornet *string* | Option to run the function using the OMOP or PCORnet CDM as the default CDM
#' - `omop`: run the [cvd_process_omop()] function against an OMOP CDM instance
#' - `pcornet`: run the [cvd_process_pcornet()] function against a PCORnet CDM instance
#' @param multi_or_single_site *string* | Option to run the function on a single vs multiple sites
#' - `single`: run the function for a single site
#' - `multi`: run the function for multiple sites
#' @param anomaly_or_exploratory *string* | Option to conduct an exploratory or anomaly detection analysis.
#' Exploratory analyses give a high level summary of the data to examine
#' the fact representation within the cohort. Anomaly detection
#' analyses are specialized to identify outliers within the cohort.
#' @param p_value *numeric* | the p value to be used as a threshold in the multi-site anomaly detection analysis
#' @param time *boolean* | logical to determine whether to output the check across time
#' @param time_span *vector - length 2* | when time = TRUE, a vector of two dates for the observation period of the study
#' @param time_period *string* | when time = TRUE, this argument defines the distance
#' between dates within the specified time period.
#' Defaults to `year`, but other time periods such as `month` or `week` are also acceptable
#'
#' @returns a data frame with summary results that can be used for `cvd_output` to generate graphical or tabular output
#'
#' @import argos
#' @import cli
#' @import squba.gen
#' @import dplyr
#' @importFrom stats setNames
#'
#' @example inst/example-cvd_process_output.R
#'
#' @export
#'

cvd_process<-function(cohort,
                      domain_tbl=NULL,
                      concept_set=NULL,
                      omop_or_pcornet,
                      multi_or_single_site = 'single',
                      anomaly_or_exploratory='exploratory',
                      p_value = 0.9,
                      time = FALSE,
                      time_span = c('2012-01-01', '2020-01-01'),
                      time_period = 'year'){
  ## Check proper arguments
  cli::cli_div(theme = list(span.code = list(color = 'blue')))

  if(!multi_or_single_site %in% c('single', 'multi')){cli::cli_abort('Invalid argument for {.code multi_or_single_site}: please enter either {.code multi} or {.code single}')}
  if(!anomaly_or_exploratory %in% c('anomaly', 'exploratory')){cli::cli_abort('Invalid argument for {.code anomaly_or_exploratory}: please enter either {.code anomaly} or {.code exploratory}')}
  if(multi_or_single_site=='single'&anomaly_or_exploratory=='anomaly'&!time){cli::cli_abort('Check not relevant for cross-sectional single site anomaly detection : please enter a different value for {.code multi_or_single_site}, {.code anomaly_or_exploratory}, or {.code time}')}
  if(is.null(domain_tbl)){cli::cli_abort('You must provide a table as input to {.code domain_tbl}. See {.code categoricalvariabledistribution::cvd_domain_tbl} for an example')}
  if(is.null(concept_set)){cli::cli_abort('You must provide a table as input to {.code concept_set}. See {.code categoricalvariabledistribution::cvd_concept_set} for an example')}

  ## parameter summary output
  output_type <- suppressWarnings(param_summ(check_string='cvd',
                                             as.list(environment())))

  # set output grouping based on input parameters
  if(time){
    output_group_list<-c('site','time_start','time_increment')
  }else{
    output_group_list<-c('site')
  }

  if(tolower(omop_or_pcornet) == 'omop'){
    cvd_tbl<-cvd_process_omop(cohort = cohort,
                              domain_tbl = domain_tbl,
                              concept_set = concept_set,
                              multi_or_single_site = multi_or_single_site,
                              anomaly_or_exploratory=anomaly_or_exploratory,
                              p_value = p_value,
                              time = time,
                              time_span = time_span,
                              time_period = time_period)
  }else if(tolower(omop_or_pcornet) == 'pcornet'){
    cvd_tbl<-cvd_process_pcornet(cohort = cohort,
                                 domain_tbl = domain_tbl,
                                 concept_set = concept_set,
                                 multi_or_single_site = multi_or_single_site,
                                 anomaly_or_exploratory=anomaly_or_exploratory,
                                 p_value = p_value,
                                 time = time,
                                 time_span = time_span,
                                 time_period = time_period)
  }else{cli::cli_abort('Invalid argument for {.code omop_or_pcornet}: this function is only compatible with {.code omop} or {.code pcornet}')}

  message('Finding valueset item proportions')
  # compute proportions based on input parameters
  cvd_tbl_prop<-cvd_tbl%>%
    ungroup()%>%
    group_by(!!!syms(output_group_list))%>%
    mutate(ct_denom=sum(ct_concept,na.rm=TRUE))%>%
    ungroup()%>%
    mutate(prop_concept=ct_concept/ct_denom)%>%
    collect()%>%
    mutate(concept_id=as.character(concept_id))

  # apply anomaly detection, if requested
  if(anomaly_or_exploratory=='anomaly'){
    message('Applying anomaly detection')
    if(multi_or_single_site=='single'){
      cvd_tbl_fn<-anomalize_ss_anom_la(fot_input_tbl=cvd_tbl_prop,
                                       grp_vars='concept_id',
                                       time_var='time_start',
                                       var_col='prop_concept')
    }else if(multi_or_single_site=='multi'&!time){
      # add in a line here to condense NA and concept_id=0
      cvd_tbl_an<-compute_dist_anomalies(df_tbl = cvd_tbl_prop,
                                         grp_vars='concept_id',
                                         var_col='prop_concept',
                                         denom_cols=c('concept_id','ct_denom'))
      cvd_tbl_fn <- detect_outliers(df_tbl = cvd_tbl_an,
                                    tail_input = 'both',
                                    p_input = p_value,
                                    column_analysis = 'prop_concept',
                                    column_variable = 'concept_id')
    }else if(multi_or_single_site=='multi'&time){
      lookup <- cvd_tbl_prop %>% ungroup() %>% distinct(concept_id)
      cvd_tbl_an <- ms_anom_euclidean(fot_input_tbl = cvd_tbl_prop,
                                      grp_vars = c('site','concept_id'),
                                      var_col = 'prop_concept')
      cvd_tbl_fn <- cvd_tbl_an %>% left_join(lookup)
    }
  }else{
    cvd_tbl_fn<-cvd_tbl_prop
  }




  if('list' %in% class(cvd_tbl_fn)){
    if(omop_or_pcornet=='omop'){
    cvd_tbl_fn[[1]] <- cvd_tbl_fn[[1]] %>% mutate(output_function = output_type$string,
                                                  concept_id=as.integer(concept_id))
    }else{
      cvd_tbl_fn[[1]] <- cvd_tbl_fn[[1]] %>% mutate(output_function = output_type$string)
    }
  }else{
    if(omop_or_pcornet=='omop'){
    cvd_tbl_fn <- cvd_tbl_fn %>% mutate(output_function = output_type$string,
                                        concept_id=as.integer(concept_id))
    }else{
      cvd_tbl_fn<-cvd_tbl_fn%>% mutate(output_function = output_type$string)
    }
  }

  print(cli::boxx(c('You can optionally use this dataframe in the accompanying',
                    '`cvd_output` function. Here are the parameters you will need:', '', output_type$vector, '',
                    'See ?cvd_output for more details.'), padding = c(0,1,0,1),
                  header = cli::col_cyan('Output Function Details')))

  return(cvd_tbl_fn)

}
