
##### Functions for the Black Adder demo project


##### 1_download_raw_html.R ------------------------------------------------------------------------

#' Parse raw html year page and get the episode links
#'
#' @param html_file character vector of which each element is a line 
#' from html file of a given year.

get_episode_links <- function(html_file){
	
	# Get html tag containing episode page links in the blog side bar
	link_tags <- str_subset(html_file, "<li>")
	
	# Extract exact link to episode
	links <- str_extract(link_tags, "http://.*\\.html")
	
	return(links)
}


##### 2_clean_html.R -------------------------------------------------------------------------------

get_raw_text_episode <- function(html_file){
	start <- str_which(html_file, '<div dir="ltr" style="text-align: left;" trbidi="on"')
	div_ends <- str_which(html_file, '</div>')
	end <- div_ends[start < div_ends][1]
	text_raw <- html_file[start:end]
	return(text_raw)
}

clean_html_formatted_episodes <- function(raw_text){
	raw_text %>% 
		str_split("<br />") %>%
		`[[`(2) %>%
		str_remove_all("&nbsp;") %>%
		str_remove("</div>")
}

# clean_plain_text_episodes <- function(raw_text){
# 	id_pre <- str_which(raw_text, "<pre>|</pre>")
# 	text <- raw_text[seq(id_pre[1], id_pre[2])]
# 	text <- str_remove_all(text,"<.*>")
# 	return(text)
# }

clean_plain_text_episodes <- function(raw_text){
	raw_text %>%
		str_remove_all("<.*>|&nbsp;") %>%
		str_remove("\\.mwsb\\{.*\\}|\\.mwst, \\.mwst a\\{.*\\}")
}

create_file_name <- function(header){
	
	h <- header %>% 
		stringi::stri_remove_empty()
	
	season <- h %>% 
		str_subset("Black Adder") %>%
		str_extract("(I|V)+") %>%
		as.roman() %>%
		as.numeric()
	
	episode <-  h %>% 
		str_subset("Black Adder") %>%
		str_extract("\\d")
	
	title <- h %>% 
		str_subset("Black Adder|-+", negate = TRUE) %>%
		str_replace_all(" ", "_")
	
	if(length(season) == 0){
		season <- 1
		episode <- 1
		title <- "The_Fortelling"
	}
	
	file_name <- paste0("S", season, "E", episode, "_", title, ".txt")
	
	return(file_name)
	
}

