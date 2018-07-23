#' New car registrations in Norway data for 1999-2018
#'
#' Selected monthly data about new car registrations in Norway for 1999-2018.
#' Raw data is presented in "long" format for several data series and from different sources.
#'
#' @source Opplysningsrådet for Veitrafikken AS (OFV AS), webiste
#'  <http:://www.ofvas.no>
#' @format Data frame with columns
#' \describe{
#' \item{car_name}{Name of the make or model (depending on the data `series``).}
#' \item{year, month}{Year and month of observation.}
#' \item{series}{Factor variable taking one of the following values: makes, models, total models or total makes.}
#' \item{source}{Source of the data. Top-20/40 tables from OFVAS website (top), images(ocr) or various other sources (web)}
#' \item{metric}{Current month observation (CM) or year-to-date (YTD).}
#' \item{period}{Recorded as current year data (CY) or last year data (LY).}
#' \item{value}{Quantity of the cars registered}
#' }
"bilsalget_raw"


#' @importFrom tibble tibble
NULL
