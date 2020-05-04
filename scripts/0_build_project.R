

year_html <- list.files("data/raw_html/year_pages/")

if(length(year_html) == 0){
	source("scripts/1_download_raw_html.R")
}

episodes_html <- list.files("data/raw_html/episodes/")


source("scripts/2_clean_html.R")
file.mtime(list.files("data/raw_html/year_pages/"))
list.files("data/raw_html/year_pages/", full.names = TRUE) %>% file.mtime()
