
library(stringr)
library(purrr)
library(dplyr)
source("scripts/blackadder_funcs.R")


# Read in episodes raw html files 
html_paths <- list.files("data/raw_html/episodes", full.names = TRUE)
html_files <- map(html_paths, readLines, warn = FALSE)

# Create a tibble holding the episode raw texts as a list-column
episodes <- tibble(raw_text = map(html_files, get_raw_text_episode))

# Based on the number of line in raw text deduce the layout format of each episode
# episodes with only two lines are formatted using html syntax
# all others episodes are just plain text
nb_lines_raw_text <- map_dbl(episodes$raw_text, length)
episodes$format <- ifelse(nb_lines_raw_text == 2,
													"html_formatted",
													"plain_text")

# Make a functions containing specific cleaning functions for each format
cleaning_funcs <- list(clean_html_formatted_episodes, 
											 clean_plain_text_episodes)

# Split episodes according to format (output is a list)
episodes_by_format <- episodes %>% split(.$format)

# Apply the adequte cleaning function to each format
episodes_by_format <- modify2(episodes_by_format, 
															 cleaning_funcs, 
															 function(format_df, cleaning_fun){
															 format_df$text <- map(format_df$raw_text, cleaning_fun) 
															 return(format_df)
															 })

# Reduce episode list back into a tibble
episodes <- bind_rows(episodes_by_format)

# Extract headers from each episodes
headers <- map(episodes$text, head)

# From headers create uniform .txt file names
episodes$file_name <- map_chr(headers, create_file_name)

# Write episode texts to .txt files
walk2(.x = episodes$text,
			.y = file.path("data/text", episodes$file_name),
			.f = ~ readr::write_lines(x = .x, path = .y))
			
