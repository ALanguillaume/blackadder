
##### Functions for the Black Adder demo project


##### 1 - Download raw html ------------------------------------------------------------------------

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
