
#' CVD Sample Domain File
#'
#' A sample version of the table structure expected for the `domain_tbl`
#' parameter in the `cvd_process` function. The user should recreate
#' this table and include their own domain definitions.
#'
#' #' @format ## cvd_domain_file
#' \describe{
#' A data frame with 4 columns
#'   \item{domain}{The name of the CDM table associated with the domain of interest}
#'   \item{concept_field}{The name of the column in the domain table that contains the concepts of interest listed in the concept_set file.}
#'   \item{vs_field}{The name of the column in the domain table for which to show a distribution of categorical values.}
#'   \item{date_field}{The name of the column in the domain table that contains dates to be used for time-based filtering.}
#' }
#'
"cvd_domain_file"


#' CVD Sample Concept Set
#'
#' A sample version of the table structure expected for the `concept_set`
#' parameter in the `cvd_process` function. The user should recreate
#' this file and include their own clinical
#'
#'  @format ## cvd_concept_set
#' A data frame with 4 columns:
#' \describe{
#'   \item{concept_id}{The OMOP concept_id; if the PCORnet CDM is being used, default this column to a random integer like the row number}
#'   \item{concept_name}{(optional)The string name of the concept}
#'   \item{concept_code}{The original code associated with the concept_id}
#'   \item{vocabulary_id}{The vocabulary associated with the concept; if the PCORnet CDM is being used, ensure that the values of this field match the vocabulary abbreviations used in the CDM itself}
#' }
#'
"cvd_concept_set"
