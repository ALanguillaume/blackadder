
library(stringr)
library(purrr)
library(tibble)
library(dplyr)

source("funcs.R")


html_paths <- list.files("episodes", full.names = TRUE)

html_files <- map(html_paths, readLines, warn = FALSE)


episodes <- tibble(raw_text = map(html_files, get_raw_text_episode))

nb_lines_raw_text <- map_dbl(episodes$raw_text, length)

episodes$format <- ifelse(nb_lines_raw_text == 2,
													"html_formatted",
													"plain_text")

episodes_by_format <- episodes %>% split(.$format)


cleaning_funcs <- list(clean_html_formatted_episodes, 
											 clean_plain_text_episodes)


episodes_by_format <- modify2(episodes_by_format, 
															 cleaning_funcs, 
															 function(format_df, cleaning_fun){
															 format_df$text <- map(format_df$raw_text, cleaning_fun) 
															 return(format_df)
															 })

episodes <- bind_rows(episodes_by_format)

headers <- map(episodes$text, head)

episodes$file_name <- map_chr(headers, create_file_name)

