library(tidyverse)
library(stringr)
library(lubridate)
# requires development version 
#remotes::install_github("ropensci/magick")
library(magick) 
library(tesseract)

library(furrr)

plan(multiprocess)

# for signing file names
todays_date <- today() %>% as.character() %>% str_replace_all("-", "")

whitelist <- "abcdefghijklmnopqrtsuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' +-/."
# tips here https://stackoverflow.com/questions/14364662/disable-dictionary-in-tesseract
opts <- list(user_words_suffix="user-words", 
             load_system_dawg =0,
             load_freq_dawg =0,
             load_punc_dawg =0,
             load_number_dawg =0,
             load_unambig_dawg=0,
             load_bigram_dawg=0,
             load_fixed_length_dawgs=0,
             load_system_dawg =0,
             language_model_penalty_non_dict_word=0.9,
             tessedit_char_whitelist = whitelist)

prepare_ocr_co2_image <- function(file_path){
  message(paste("reading", file_path, "\n"))
  
  image_read(file_path) %>% 
    image_convert(type="Grayscale") %>% 
    image_negate() %>% 
    image_lat("20x20+5%") %>% 
    image_negate() %>% 
    image_resize("100%x60%")
}

ocr_co2_image <- function(file_path){
  prepare_ocr_co2_image(file_path) %>% 
    ocr(engine = tesseract(options = opts)) 
  }

hocr_co2_image <- function(file_path){
  tesseract::ocr(file_path, engine = tesseract(options = opts), HOCR = TRUE) %>% 
    hocr::hocr_parse() %>% 
    hocr::tidy_tesseract()
}

postocr_co2_image <- function(file_path, date){
  ocr_co2_image(file_path) %>% 
    read_lines() %>% as_tibble() %>% 
    separate(value, "[-~—]+(?=[ 0-9]+$)", into=c("name","count"), extra="merge", fill="right") %>% 
    filter(!is.na(count)) %>% 
    mutate(name=na_if(trimws(name), ""),
           count=as.numeric(str_replace_all(count, "\\s", "")),
           year=year(as.Date(date, origin=as.Date("1970-01-01"))),
           month=month(as.Date(date, origin=as.Date("1970-01-01")))
           ) %>% filter(!is.na(name)) 
}

#postocrdata_co2_image <- function(file_path, date){
#  ocrdata_co2_image(file_path, date) %>% 
#    read_lines() %>% as_tibble() %>% 
#    separate(value, "[-~—]+(?=[ 0-9]+$)", into=c("name","count"), extra="merge", fill="right") %>% 
#    filter(!is.na(count)) %>% 
#    mutate(name=na_if(trimws(name), ""),
#           count=as.numeric(str_replace_all(count, "\\s", "")),
#           year=year(as.Date(date, origin=as.Date("1970-01-01"))),
#           month=month(as.Date(date, origin=as.Date("1970-01-01")))
#    ) %>% filter(!is.na(name)) 
#}

ocr_area <- function(geometry, img){
  image_crop(img, geometry = geometry) %>% 
    image_despeckle(5) %>% 
    image_scale("100%x167%") %>% 
    ocr()#engine = tesseract(options = opts)) 
}

library(hocr)

z <- prepare_ocr_co2_image("co2/CO2-Modell_8_2018.jpg")

z %>% hocr_co2_image() %>% select(contains("word"), contains("line")) %>% 
  group_by_at(vars(contains("line"))) %>% 
  mutate(ocrx_line_value=paste(ocrx_word_value, collapse = " ")) %>%
  group_by(ocrx_line_value, add = TRUE) %>% 
  nest() %>%
  mutate(ocr_line_geom=bbox_to_geometry(ocr_line_bbox)) %>% 
  mutate(ocr_retry_value=map_chr(ocr_line_geom, ~ocr_area(.x, z))) %>% View




############################ RUN SCRIPT ###########################
image_df <- dir("co2", full.names = TRUE) %>% as_tibble() %>% 
  mutate(file_path = value) %>% 
  separate(value, "_", into=c("header", "month", "year")) %>% select(-header) %>% 
  mutate(year=str_replace(year,".jpg",""),
         date=as.Date(paste(year, month, 1, sep="-"))) %>%
  select(file_path, date) %>% 
  future_pmap_dfr(postocr_co2_image)

write_csv(image_df, paste0("input/co2_image_model_", todays_date, ".csv"))



image_make_df <- dir("co2 merke", full.names = TRUE) %>% as_tibble() %>% 
  mutate(file_path = value) %>% 
  separate(value, "_", into=c("header", "month", "year")) %>% select(-header) %>% 
  mutate(year=str_replace(year,".jpg",""),
         date=as.Date(paste("20", year,"-", month,"-", 1, sep=""))) %>%
  select(file_path, date) %>%
  future_pmap_dfr(postocr_co2_image)

write_csv(image_make_df, paste0("input/co2_image_make_", todays_date, ".csv"))
