library(tidyverse)
library(stringr)
library(lubridate)
library(readxl)

# for signing file names
todays_date <- today() %>% as.character() %>% str_replace_all("-", "")

# this data is from previous periods no longer available at OFV website
ofv_hist_data <- read_csv("data-raw/input/ofv_data.csv", col_types = "cccccccccccccc")

# this data comes from ofv_scrape.R
ofv_curr_data <- list.files("data-raw/ofvdata/", full.names = TRUE) %>%
  map_dfr(read_csv, col_types = "cccccccccccccc")

# There may be some overlap(duplication) between historical and current values
ofv_data <- bind_rows(ofv_curr_data, ofv_hist_data)
rm(ofv_hist_data, ofv_curr_data)

# this data comes from img_resize_ocr.R and requires images downloaded to co2 and co2-merke
img_model <- read_csv("data-raw/input/co2_image_model_20190209.csv")
img_make <- read_csv("data-raw/input/co2_image_make_20190209.csv")
# manually updated
zoe_data <- read_excel("data-raw/input/Book2.xlsx", sheet = "summary")
# this comes from get_comments.R
comment_data <- read_csv("data-raw/input/ofvas_comments.csv")

nor_months <- c("januar", "februar", "mars", "april", "mai", "juni", "juli", "august",
                "september", "oktober", "november", "desember")

# clean up the data
ofv_data_raw <- ofv_data %>%
  select(-starts_with("pct"), -starts_with("chg")) %>%
  mutate_at(vars(-car_name), str_replace, ",", ".") %>% # replace decimal comma with decimal point
  mutate_at(vars(-car_name), str_replace, "[[:space:]]", "") %>% # remove thousands separator
  mutate_at(vars(-car_name), as.integer) %>% # coerce to numeric
  rename(year="yearsel", month="monthsel", series="velgfordelt") %>%
  separate(car_name, ". ", into=c("dummy", "car_name"), fill="right",extra="merge") %>%
  mutate(car_name=ifelse(dummy=="TOTALT", "TOTAL", car_name)) %>%
  select(-dummy) %>%
  distinct() %>% # removes duplicate values
  group_by(car_name, year, month, series) %>% # there's one problem with Lexus in 2015
  top_n(1, cum_YTD_CY) %>%
  ungroup() %>%        # found in 2015 for Lexus
  mutate(car_name=ifelse(car_name=="Rover.", "Rover", car_name)) %>%
  mutate(series=ifelse(car_name=="TOTAL", series+3L, series+1L)) %>% # separate totals
  mutate(series=factor(series, levels=seq.int(4L), labels=c("models", "makes", "total models", "total makes"))) %>%
  mutate(series=as.character(series)) %>%
  mutate(source="top") %>% # provide data provenance
  filter(!(year==2011L & month==10L)) %>% # remove incorrect data, see below
  gather(key, value, c("count_CM_CY", "cum_YTD_CY", "count_CM_LY", "cum_YTD_LY")) %>%
  mutate(key=str_replace(key, "count_|cum_", "")) %>%
  separate(key, into=c("metric", "period"), sep="_") %>%
  mutate(year=ifelse(period=="LY", year-1, year)) # correct year for estimates for last year


img_make_raw <- img_make %>%
  rename(car_name="name", value="count") %>%
  mutate(series="makes", source="ocr", metric="YTD", period="CY") %>%
  mutate(car_name = str_replace_all(car_name, "[iIlf][']?[Vv][']?[Il]", "M"),
         car_name = ifelse(car_name == "MlNl","MINI", car_name) ) %>%
  select(car_name, year, month, series, source, metric, period, value)

img_model_raw <- img_model %>%
  rename(car_name="name", value="count") %>%
  mutate(series="models", source="ocr", metric="YTD", period="CY") %>%
  mutate(car_name = str_replace_all(car_name, "[iIlf][']?[Vv][']?[Il]", "M"),
         car_name = str_replace_all(car_name, "MlNl ", "MINI "),
         car_name = str_replace_all(car_name, "Nl", "M")  ) %>%
  select(car_name, year, month, series, source, metric, period, value)

bilsalget_raw <- bind_rows(ofv_data_raw, img_make_raw, img_model_raw)

bilsalget_raw

comment_raw <- comment_data %>%
  filter(!str_detect(period, "\\d+")) %>%
  mutate(month=as.character(factor(period, levels=nor_months, labels=seq.int(12)))) %>%
  select(-period) %>%
  mutate_at(vars(year, month), funs(as.integer))



zoe_all <- zoe_data %>%
  select(Year, Month, Quantity, Import, Used, Avg_CO2,
                      Bensin_Co2, Diesel_Co2, Diesel_Share, Quantity_Hybrid, Quantity_Electric, Import_Electric) %>%
  set_names(c("year", "month", "total", "import_used", "turnover_used", "avg_co2",
            "bensin_co2", "diesel_co2", "diesel_share", "total_hybrid", "total_zoe", "import_used_zoe")) %>%
  mutate_at(vars(year, month), funs(as.integer))

zoe_raw <- full_join(zoe_all, comment_raw, by=c("year", "month"))

zoe_raw
