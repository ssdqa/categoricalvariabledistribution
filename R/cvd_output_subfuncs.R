#' Single Site, Exploratory, Cross-Sectional Output for Categorical Variable Distribution Module
#'
#' @inheritParams cvd_output
#'
#' @returns a bar plot as a ggplot object with categorical value set on y axis, proportion on y axis, filled by categorical value
#' @export
#'
cvd_ss_exp_cs<-function(process_output){
  # check to see if all of the values of concept_name are vocabulary table not found?
  concept_col<-ifelse('concept_name'%in%colnames(process_output), 'concept_name','concept_id')

  data_tbl<-process_output%>%
    mutate(text=paste0("Count: ", format(ct_concept,big.mark=","),
                       "\nProportion: ",round(prop_concept,2)))

  plt<-ggplot(data_tbl,
              aes(x=as.character(!!sym(concept_col)),
                  y=prop_concept,
                  fill=as.character(!!sym(concept_col)),
                  text=text))+
    geom_bar(stat='identity', show.legend=FALSE)+
    theme_minimal()+
    coord_flip()+
    scale_fill_squba()+
    labs(x="Value",
         y="Proportion",
         title="Distribution of Categorical Variable Values")

  plt[["metadata"]] <- tibble('pkg_backend' = 'plotly',
                              'tooltip' = TRUE)

  return(plt)
}

#' Single Site, Exploratory, Longitudinal Output for Categorical Variable Distribution Module
#'
#' @inheritParams cvd_output
#'
#' @returns A line plot as a ggplot object with time on x axis, proportion of category with value on y axis, colored by categorical value
#' @export
#'
cvd_ss_exp_la<-function(process_output){
  concept_col<-ifelse('concept_name'%in%colnames(process_output), 'concept_name','concept_id')

  data_tbl<-process_output%>%
    mutate(text=paste0("Time: ",time_start,
                       "\nCount: ",format(ct_concept,big.mark=","),
                       "\nProportion: ",round(prop_concept,2)))

  plt<-ggplot(data_tbl,
              aes(x=time_start,
                  y=prop_concept,
                  color=!!sym(concept_col),
                  group=!!sym(concept_col),
                  text=text))+
    geom_line()+
    scale_color_squba()+
    theme_minimal()+
    labs(x="Time",
         y="Proportion with Value")
  plt[["metadata"]] <- tibble('pkg_backend' = 'plotly',
                              'tooltip' = TRUE)

  return(plt)
}

#' Single Site, Anomaly, Longitudinal Output for Categorical Variable Distribution Module
#'
#' @inheritParams cvd_output
#'
#' @returns if analysis was executed by year or greater, a P Prime control chart
#'         is returned with outliers marked with orange dots
#'
#'         if analysis was executed by month or smaller, an STL regression is
#'         conducted and outliers are marked with red dots. the graphs representing
#'         the data removed in the regression are also returned
#' @export
#'
cvd_ss_anom_la<-function(process_output,
                         filt){
  concept_col<-ifelse('concept_name'%in%colnames(process_output), 'concept_name','concept_id')

  time_inc <- process_output %>% filter(!is.na(time_increment)) %>% distinct(time_increment) %>% pull()
  c_final <- process_output %>% filter(concept_id==filt)

  if(time_inc == 'year'){

    c_plot <- qicharts2::qic(data = c_final, x = time_start, y = ct_concept, chart = 'pp', n = ct_denom)
    op_dat <- c_plot$data

    new_pp <- ggplot(op_dat, aes(x,y))+
      geom_ribbon(aes(ymin=lcl,max=ucl), fill="lightgray",alpha=0.4) +
      geom_line(colour=squba_colors_standard[[12]], size=0.5) +
      geom_line(aes(x,cl)) +
      geom_point(colour=squba_colors_standard[[6]], fill = squba_colors_standard[[6]], size = 1) +
      geom_point(data=subset(op_dat, y>=ucl), color=squba_colors_standard[[3]], size=2) +
      geom_point(data=subset(op_dat, y<=lcl), color=squba_colors_standard[[3]], size=2) +
      ggtitle(label=paste0("Control Chart: Proportion of Valueset Item ", filt, " over Time")) +
      labs(x = "Time",
           y = "Proportion")+
      theme_minimal()


    new_pp[["metadata"]] <- tibble('pkg_backend' = 'plotly',
                                   'tooltip' = FALSE)
    output<-new_pp

  }else{
    anomalies<-timetk::plot_anomalies(.data=c_final,
                                      .date_var=time_start,
                                      .interactive=FALSE,
                                      .title=paste0("Anomalies for Valueset Item ", filt, " over Time"))
    decomp<-timetk::plot_anomalies_decomp(.data=c_final,
                                          .date_var=time_start,
                                          .interactive=FALSE,
                                          .title=paste0("Anomalies for Valueset Item ", filt, " over Time"))
    anomalies[["metadata"]] <- tibble('pkg_backend' = 'plotly',
                                      'tooltip' = FALSE)
    decomp[["metadata"]] <- tibble('pkg_backend' = 'plotly',
                                   'tooltip' = FALSE)
    output<-list(anomalies, decomp)
  }

}
#' Multi Site, Exploratory, Cross-Sectional Output for Categorical Variable Distribution Module
#'
#' @inheritParams cvd_output
#'
#'
#' @returns A heatmap, returned as a ggplot object, with site on x axis, valueset item on y axis, with proportion of the site's total for each valueset item displayed as tile color and a label on the tile
#' @export
#'
cvd_ms_exp_cs<-function(process_output){

  concept_col<-ifelse('concept_name'%in%colnames(process_output), 'concept_name','concept_id')
  dat_to_plot<-process_output%>%
    mutate(tooltip=paste0("Proportion: ",round(prop_concept,2),
                          "\nCount: ",format(ct_concept, big.mark=",")))
  plt <- ggplot(dat_to_plot, aes(x=site,
                                 y=!!sym(concept_col),
                                 fill=prop_concept))+
    ggiraph::geom_tile_interactive(aes(tooltip=tooltip))+
    geom_text(aes(label=round(prop_concept,2)),size=3,color='black')+
    scale_fill_squba(palette='diverging',discrete=FALSE)+
    theme_minimal()+
    theme(axis.text.x = element_text(angle=30, vjust=1, hjust=1))+
    labs(y=concept_col,
         title="Distribution of Categorical Variable Values across Sites",
         fill="Proportion")

  plt[["metadata"]] <- tibble('pkg_backend' = 'ggiraph',
                              'tooltip' = TRUE)
  return(plt)

}

#' Multi Site, Exploratory, Longitudinal Output for Categorical Variable Distribution Module
#'
#' @inheritParams cvd_output
#'
#' @returns A line plot, returned as a ggplot object, faceted by categorical valueset item, with lines and line color representing site.
#' @export
#'
cvd_ms_exp_la<-function(process_output){
  concept_col<-ifelse('concept_name'%in%colnames(process_output), 'concept_name','concept_id')

  dat_toplot<-process_output%>%
    mutate(text=paste0("Site: ",site,
                       "\nProportion: ",round(prop_concept,2),
                       "\nCount: ",ct_concept))
  plt<-ggplot(dat_toplot,
              aes(x=time_start,
                  y=prop_concept,
                  color=site,
                  group=site,
                  text=text))+
    geom_line()+
    facet_wrap((concept_col))+
    scale_color_squba()+
    theme_minimal()+
    labs(x='Time',
         y='Proportion',
         color='Site')

  plt[['metadata']] <- tibble('pkg_backend' = 'plotly',
                              'tooltip' = TRUE)

  return(plt)

}
#' Multi Site, Anomaly, Cross-Sectional Output for Categorical Variable Distribution Module
#'
#' @inheritParams cvd_output
#'
#' @returns A dot plot, returned as a ggplot object, with site on x axis, categorical valueset item on y axis, with dot size representing mean proportion for the given valueset item across all sites, color representing proportion of given site's values for the given valueset item. Anomalies are distinguished with star shapes as opposed to the normal circles.
cvd_ms_anom_cs<-function(process_output){

  concept_col<-ifelse('concept_name'%in%colnames(process_output), 'concept_name','concept_id')

  dat_to_plot <- process_output%>%
    mutate(text=paste0("Valueset Item: ",!!sym(concept_col),
                       "\nSite: ",site,
                       "\nProportion: ",round(prop_concept,2),
                       "\nMean proportion: ",round(mean_val,2),
                       "\nSD: ",round(sd_val,2),
                       "\nMedian proportion: ",round(median_val,2),
                       "\nMAD: ",round(mad_val, 2)),
           anomaly_yn = ifelse(anomaly_yn == 'no outlier in group', 'not outlier', anomaly_yn))

  plt<-ggplot(dat_to_plot,
              aes(x=site,
                  y=!!sym(concept_col),
                  text=text,
                  color=prop_concept))+
    ggiraph::geom_point_interactive(aes(size=mean_val,shape=anomaly_yn, tooltip=text))+
    ggiraph::geom_point_interactive(data = dat_to_plot %>% filter(anomaly_yn == 'not outlier'),
                                    aes(size=mean_val,shape=anomaly_yn, tooltip = text), shape = 1, color = 'black')+
    scale_color_squba(palette = 'diverging', discrete = FALSE) +
    scale_shape_manual(values=c(19,8))+
    scale_y_discrete(labels = function(x) str_wrap(x, width = 60)) +
    theme_minimal()+
    theme(axis.text.x = element_text(angle=30, vjust=1, hjust=1))+
    labs(size="",
         title="Anomalous Proportion of Valueset Item",
         subtitle='Dot size is the mean proportion of the given valueset item across sites')+
    guides(color=guide_colorbar(title="Proportion"),
           shape=guide_legend(title="Anomaly"),
           size="none")

  plt[["metadata"]]<-tibble('pkg_backend' = 'ggiraph',
                            'tooltip'=TRUE)

  return(plt)
}

#' Multi Site, Anomaly, Longitudinal Output for Categorical Variable Distribution Module
#'
#' @inheritParams cvd_output
#' @param filt *numeric/string or vector* | The specific code(s) that should be the focus of the analysis
#'
#' @returns three graphs:
#'    1) Loess smoothed line graph that shows the proportion of a code across time
#'    with the Euclidean Distance associated with each line
#'    2) same as (1) but displaying the raw, unsmoothed proportion
#'    3) a radial bar graph displaying the Euclidean Distance value for each
#'    site, where the color is the average proportion across time
#' @export
#'
cvd_ms_anom_la<-function(process_output,
                         filt){
  filt_op<-process_output%>%
    filter(concept_id==filt)

  allsites<-
    filt_op %>%
    select(time_start, concept_id, mean_allsiteprop) %>%
    distinct()%>%
    rename(prop_concept=mean_allsiteprop)%>%
    mutate(site= 'all site average',
           text_smooth=paste0("Site: ", site,
                              "\nProportion: ",round(prop_concept,2)),

           text_raw=paste0("Site: ", site,
                           "\n","Proportion: ",round(prop_concept,2)))

  dat_to_plot<-filt_op%>%
    mutate(text_smooth=paste0("Site: ", site,
                              "\n","Euclidean Distance from All-Site Mean: ",dist_eucl_mean),
           text_raw=paste0("Site: ", site,
                           "\n","Site Proportion: ",round(prop_concept,2),
                           "\n","Site Smoothed Proportion: ",site_loess,
                           "\n","Euclidean Distance from All-Site Mean: ",dist_eucl_mean))

  p<-dat_to_plot %>%
    ggplot(aes(y = prop_concept,
               x = time_start,
               color = site,
               group = site,
               text = text_smooth)) +
    geom_line(data=allsites, linewidth=1.1) +
    geom_smooth(se=TRUE,alpha=0.1,linewidth=0.5, formula = y ~ x) +
    scale_color_squba() +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 30, vjust = 1, hjust=1)) +
    labs(y = 'Proportion (Loess)',
         x = 'Time',
         title = paste0('Smoothed Proportion of Valueset Item ', filt, ' Across Time'))

  q <- dat_to_plot %>%
    ggplot(aes(y = prop_concept, x = time_start, color = site,
               group=site, text=text_raw)) +
    geom_line(data=allsites,linewidth=1.1) +
    geom_line(linewidth=0.2) +
    scale_color_squba() +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 30, vjust = 1, hjust=1)) +
    labs(x = 'Time',
         y = 'Proportion',
         title = paste0('Proportion of Valueset Item', filt, ' Across Time'))

  t <- dat_to_plot %>%
    distinct(site, dist_eucl_mean, site_loess) %>%
    group_by(site, dist_eucl_mean) %>%
    summarise(mean_site_loess = mean(site_loess)) %>%
    mutate(tooltip = paste0('Site: ', site,
                            '\nEuclidean Distance: ', dist_eucl_mean,
                            '\nAverage Loess Proportion: ', mean_site_loess)) %>%
    ggplot(aes(x = site, y = dist_eucl_mean, fill = mean_site_loess, tooltip = tooltip)) +
    ggiraph::geom_col_interactive() +
    coord_radial(r.axis.inside = FALSE, rotate.angle = TRUE) +
    guides(theta = guide_axis_theta(angle = 0)) +
    theme_minimal() +
    scale_fill_squba(palette = 'diverging', discrete = FALSE) +
    labs(fill = 'Avg. Proportion \n(Loess)',
         y ='Euclidean Distance',
         x = '',
         title = paste0('Euclidean Distance for Valueset Item ', filt))

  p[['metadata']] <- tibble('pkg_backend' = 'plotly',
                            'tooltip' = TRUE)

  q[['metadata']] <- tibble('pkg_backend' = 'plotly',
                            'tooltip' = TRUE)

  t[['metadata']] <- tibble('pkg_backend' = 'ggiraph',
                            'tooltip' = TRUE)

  output <- list(p, q, t)

  return(output)
}
