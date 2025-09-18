check_vs_dist<-function(cohort,
                        concept_set,
                        domain_tbl,
                        time,
                        grp,
                        omop_or_pcornet){

  i<-1
  # expect only one row in domain input file
  domain_tbl_name<-domain_tbl$domain[[i]]
  final_col<-domain_tbl$concept_field[[i]]
  vs_col<-domain_tbl$vs_field[[i]]
  date_col<-domain_tbl$date_field[[i]]
  domain_tbl_cdm<-cdm_tbl(domain_tbl_name)%>%
    inner_join(cohort)%>%
    filter(!!sym(date_col)>=start_date,
           !!sym(date_col)<=end_date)


  if(time){
    facts_inwindow<-domain_tbl_cdm%>%
      filter(!!sym(date_col)>=time_start,
             !!sym(date_col)<=time_end)%>%
      group_by(!!!syms(grp))%>%
      group_by(time_start, time_increment,.add=TRUE)
  }else{
    facts_inwindow<-domain_tbl_cdm
  }
  # group and count facts per valueset item
  if(omop_or_pcornet=='pcornet'){
    concept_counts<-facts_inwindow%>%
      inner_join(load_codeset(concept_set),
                 by=setNames('concept_code',final_col))%>%
      group_by(!!sym(vs_col), .add=TRUE)%>%
      summarise(ct_concept=n())%>%
      rename('concept_id'=vs_col)
  }else{
    concept_counts<-facts_inwindow%>%
      inner_join(load_codeset(concept_set),
                 by=setNames('concept_id',final_col))%>%
      group_by(!!sym(vs_col), .add=TRUE)%>%
      summarise(ct_concept=n())%>%
      rename('concept_id'=vs_col)
  }
  return(concept_counts)
}
