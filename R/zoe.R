#' Zero-emission vehicle registrations in Norway data for 2005-2018
#'
#' Selected monthly data about car registrations in Norway for 2005-2018, including sales and import of zero-emission vehicles.
#' Raw data is presented in "wide" format.
#'
#' @source Opplysningsrådet for Veitrafikken AS (OFV AS), webiste
#'  <http:://www.ofvas.no>
#' @format Data frame with columns
#' \describe{
#' \item{year, month}{Year and month of observation.}
#' \item{total}{Total new car registrations.}
#' \item{import_used}{Total number of used vehicles imported to Norway.}
#' \item{turnover_used}{Total number of change-of-owner registrations in Norway.}
#' \item{avg_co2}{Average of manufacturer-stated CO2 emissions from cars registred during the period (in g/km).}
#' \item{bensin_co2}{Average of manufacturer-stated CO2 emissions from gasoline cars registred during the period (in g/km).}
#' \item{diesel_co2}{Average of manufacturer-stated CO2 emissions from diesel cars registred during the period (in g/km).}
#' \item{diesel_share}{Percentage share of diesel vehicles in new car registrations.}
#' \item{total_hybrid}{Total number of hybrid vehicle registrations (including plug-in-hybrids).}
#' \item{total_zoe}{Total number of zero-emission vehicle registrations (including electric and hydrogen-powered cars).}
#' \item{import_used_zoe}{Total number of used zero-emission vehicles imported to Norway.}
#' \item{href}{URL to the data and commentary on OFVAS website.}
#' \item{comment}{Commentary to monthly numbers (in Norwegian).}
#' }
"zoe_raw"


#' @importFrom tibble tibble
NULL
