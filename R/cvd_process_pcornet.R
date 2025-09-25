#' Categorical Variable Distribution - PCORnet Version
#'
#' @inheritParams cvd_process
#'
#' @returns a data frame with the distribution from the specified domain/concept which will be further summarized in `cvd_process`
#'
#' @importFrom purrr reduce
#' @importFrom rlang syms
#' @export
#'
cvd_process_pcornet<-function(cohort,
                              domain_tbl,
                              concept_set,
                              multi_or_single_site = 'single',
                              anomaly_or_exploratory='exploratory',
                              p_value = 0.9,
                              time = TRUE,
                              time_span = c('2012-01-01', '2020-01-01'),
                              time_period = 'year',
                              vocab_tbl=NULL){
  # Add site check
  site_filter <- check_site_type(cohort = cohort,
                                 multi_or_single_site = multi_or_single_site)
  cohort_filter <- site_filter$cohort
  grouped_list <- site_filter$grouped_list
  site_col <- site_filter$grouped_list
  site_list_adj <- site_filter$site_list_adj
  vs_col<-domain_tbl$vs_field[[1]]

  site_output <- list()

  # Prep cohort

  cohort_prep <- prepare_cohort(cohort_tbl = cohort_filter,
                                age_groups = NULL, codeset = NULL,
                                omop_or_pcornet = 'pcornet') %>%
    group_by(!!! syms(grouped_list))

  # Execute function
  if(!time){
    for(k in 1:length(site_list_adj)){

      site_list_thisrnd<-site_list_adj[[k]]

      # filters by site
      cohort_site<-cohort_prep%>%filter(!!sym(site_col)%in%c(site_list_thisrnd))
      ct_compute<-check_vs_dist(cohort=cohort_site,
                                concept_set=concept_set,
                                domain_tbl=domain_tbl,
                                time=time,
                                grp=grouped_list,
                                omop_or_pcornet='pcornet')

      site_output[[k]] <- ct_compute%>%mutate(site=site_list_thisrnd)
    }

    cvd_tbl<-reduce(.x=site_output,
                    .f=dplyr::union)

  } else {
    cvd_tbl <- compute_fot(cohort=cohort_prep,
                           site_list=site_list_adj,
                           site_col=site_col,
                           time_span=time_span,
                           time_period = time_period,
                           reduce_id=NULL,
                           check_func=function(dat){
                             check_vs_dist(cohort=dat,
                                           concept_set=concept_set,
                                           domain_tbl=domain_tbl,
                                           time=TRUE,
                                           grp=grouped_list,
                                           omop_or_pcornet='pcornet')
                           })%>%replace_site_col()
  }

  return(cvd_tbl)


}
