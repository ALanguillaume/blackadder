
##### Functions for the Black Adder demo project


##### 1_download_raw_html.R ------------------------------------------------------------------------

#' Parse raw html year page and get the episode links
#'
#' @param html_file character vector of which each element is a line 
#' from the html file of a given year.

get_episode_links <- function(html_file){
	
	# Get html tag containing episode page links in the blog side bar
	link_tags <- str_subset(html_file, "<li>")
	
	# Extract exact link to episode
	links <- str_extract(link_tags, "http://.*\\.html")
	
	return(links)
}


##### 2_clean_html_to_text.R -----------------------------------------------------------------------

#' Get raw text of each episode
#' 
#' Each episode text is included in the following html section:
#' <div dir="ltr" style="text-align: left;" trbidi="on"> raw_text </div> 
#' This function spot the corresponfing html tags and returns the raw text.
#' 
#' @param html_file character vector of which each element is a line 
#' from the html file of a given episode.

get_raw_text_episode <- function(html_file){
	
	# Get index of first tag
	start <- str_which(html_file, '<div dir="ltr" style="text-align: left;" trbidi="on">')
	# Get index of all </div> tags
	div_ends <- str_which(html_file, '</div>')
	# Get index of the </div> tag coming right after start tag
	end <- div_ends[start < div_ends][1]
	
	text_raw <- html_file[start:end]
	
	return(text_raw)
}


#' Clean raw text
#'
#' The raw html texts come in two different flavour either
#' formatted with html code or as plain text.
#' The following two functions remove all useless formatting from 
#' the raw text.
#'
#' @param raw_text character vector of which each element is a line 
#' from the raw text of a given episode.

clean_html_formatted_episodes <- function(raw_text){
	
	raw_text %>% 
		str_split("<br />") %>%
		`[[`(2) %>%
		str_remove_all("&nbsp;") %>%
		str_remove("</div>")
	
}

clean_plain_text_episodes <- function(raw_text){
	
	raw_text %>%
		str_remove_all("<.*>|&nbsp;") %>%
		str_remove("\\.mwsb\\{.*\\}|\\.mwst, \\.mwst a\\{.*\\}")
	
}


#' Create .txt file name for each episode
#'
#' From the information found in the text header, create consistent
#' .txt file name for each episode.
#'
#' @header character vector of which each element is a line 
#' from the header of a given episode.

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


###### 4_analysis.R --------------------------------------------------------------------------------

#' Draw barplot of most frequent word for one season
#'
#' @param df A data.frame containing the columns:
#' - word : words in a given season.
#' - season: the number of the given season.
#' - n: the number of occurences of each word in that season.
#' 
#' @color A character string defining a hex (RGB) color code.

plot_nb_words_season <- function(df, color){
	df %>%
		arrange(n) %>%
		mutate(word = forcats::as_factor(word)) %>%
		ggplot() +
		aes(x = word, y = n) +
		geom_col(fill = color) +
		xlab(NULL) +
		coord_flip() +
		ylim(0, 450) +
		ylab("Number of occurences") +
		ggtitle(paste("Season", unique(df$season), sep = " ")) +
		theme(legend.position = "none")
}
