
library(purrr)
library(stringr)
source("scripts/blackadder_funcs.R")


##### Download year pages to extract episodes links --------------------------------------------------

# url of the blog hosting all episode transcripts
url_master <- "http://allblackadderscripts.blogspot.com/"

# Scripts where uploaded between 2011 and 2012, the quickest way 
# to get all transcript links is to parse the link in the year page
urls <- paste0(url_master, 2012, "/", 11:12, "/") 

# Define paths (including file names) for year html files 
raw_html_names <- paste("allblackadderscripts", 2012, 11:12, ".html", sep = "_")
raw_html_paths <- file.path("data/raw_html/year_pages", raw_html_names)

# Download the year html file
walk2(.x = urls, 
			.y = raw_html_paths,
			~ download.file(url = .x, destfile = .y))

# Read in the raw html files
raw_html_files <- map(raw_html_paths, readLines, warn = FALSE)

# Parse the links to each episode
episodes_url <- raw_html_files %>% 
	map(get_episode_links)%>%
	unlist()

# Extract only the name of the html files
episodes_html <- str_extract(episodes_url, "[^/]*(?!/).html$")


##### Download all episodes --------------------------------------------------------------------------

# Define paths (including file names) for year html files 
episodes_paths <- file.path("data/raw_html/episodes", episodes_html)

# Download each episode html files
walk2(.x = episodes_url, 
			.y = episodes_paths,
			~ download.file(url = .x, destfile = .y))
