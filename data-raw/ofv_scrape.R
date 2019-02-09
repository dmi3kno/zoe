library(rvest)
library(tidyverse)

Sys.setenv("HTTP_PROXY"="")
Sys.setenv("HTTPS_PROXY"="")

get_ofv_data <- function(yearsel, monthsel, velgfordelt){
  
  filename <- paste0("ofvdata/", paste("ofv", yearsel, monthsel, velgfordelt, sep = "_"), ".csv")
    
  if(file.exists(filename)){
    message(paste("File", filename, "exists"))
    return(NULL)
    }
  
  session <- html_session("http://statistikk.ofv.no/ofv_bilsalg_small.asp")      
  form <- html_form(session)[[1]]
  cat("Fetching the data for ", format(as.Date(paste(yearsel, monthsel, 1, sep="-")), "%B %Y"))
  filled_form <- set_values(form = form, 
                            `yearsel`= yearsel, 
                            `monthsel`=monthsel, 
                            `cartype`=0, 
                            `velgfordelt`=velgfordelt, 
                           `submit1`="Vis statistikk")
     
   session <- submit_form(session, filled_form)
   results <- session %>% html_node("#salesTable") %>% html_table() %>% 
     set_names(c("car_name", "count_CM_CY", "pct_CM_CY", "cum_YTD_CY", "pct_YTD_CY", 
                 "count_CM_LY", "pct_CM_LY", "cum_YTD_LY", "pct_YTD_LY", 
                 "chg_CM_YOY", "chg_YTD_YOY")) %>% 
     as_tibble() %>% slice(-1:-2) %>% 
     mutate(yearsel=yearsel, monthsel=monthsel, velgfordelt=velgfordelt)
   Sys.sleep(3+runif(1)*3)
   write_csv(results, filename)

   invisible()
    
}


expand.grid(yearsel=2018, monthsel=7:12, velgfordelt=0:1) %>% 
  pwalk(get_ofv_data)





