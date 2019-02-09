Sys.setenv("HTTP_PROXY"="")
Sys.setenv("HTTPS_PROXY"="")
library(rvest)

todays_date <- today() %>% as.character() %>% str_replace_all("-", "")

seed_url <- "http://www.ofvas.no/bilsalget-2005/category433.html"


get_links <- function(year, href){
  
Sys.sleep(runif(1)*2)  
message("fetching links ", year)

links_page <- read_html(href) %>% 
  html_nodes(".placeholder-start+ .small-articlelist .tile-content") %>% 
  html_nodes("a")

tibble(year=year,
       period=html_text(links_page),
       href=html_attr(links_page, "href"))
}


year_links <- get_links(2005, seed_url) %>% 
  filter(str_detect(period, "Bilsalget \\d+")) %>% 
  mutate(year=as.numeric(str_replace(period, "Bilsalget ", "")))

all_links <- year_links %>% 
  select(year, href) %>% 
  pmap_dfr(get_links)


get_comment_text <- function(year, period, href){
  
  Sys.sleep(runif(1)*2)  
  message("fetching comment for ", year, " ", period)
  
  txt <- read_html(href) %>% 
    html_nodes("#placeholder-content div > p") %>% 
    html_text() %>% paste0(collapse = "\n")

  tibble(year=year,
         period=period,
         href=href,
         comment=txt)
}

all_comments <- all_links %>% 
  filter(!str_detect(period, "Bilsalget \\d+")) %>% 
  mutate(period = str_replace(period, "Bilsalget\\s[i]?\\s?", "")) %>% 
  pmap_dfr(get_comment_text)

write_csv(all_comments, paste0("input/ofvas_comments_", todays_date, ".csv"))
write_rds(all_comments, paste0("input/ofvas_comments_", todays_date, ".rds"))
