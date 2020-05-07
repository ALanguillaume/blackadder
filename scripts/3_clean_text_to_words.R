
library(readr)
library(stringr)
library(purrr)
library(dplyr)
library(tidytext)

# Read in text data
text_paths <- list.files("data/text/", full.names = TRUE)
text_episodes <- text_paths %>%
	map(read_file) %>%
	map(str_split, "\n\n") %>% # Distinguish between lines
	map(unlist, recursive = FALSE)

# Make sure, in episode 22, that a character line is introduce by their name
# followd y ":", like in all other episodes (and not an arbitrary number of spaces).
text_episodes[[22]] <- text_episodes[[22]] %>%
	str_replace_all("\\n[:blank:]{1,}", " ") %>%
	str_replace_all("(?<=[:alpha:])[:blank:]{5,}", ": ")

# Remove...
text_episodes <- text_episodes %>%
	map(function(episode){
		episode %>%
			str_remove_all("(\\([^\\)]*\\))|(\\[[^]]*\\])") %>% # ...stage directions
			str_remove_all("\n") %>% # ...escaped lines
			str_remove_all("\\*") # ...italic 
	}) 

# Keep only dialogs
dialog_episodes <- text_episodes %>%
	map(function(episode){ 
		episode %>%
			str_subset("^[:alpha:]+:") %>%
			str_remove("^[:alpha:]+:[:space:]+")# remove character names
	}) 

# Tokenize words
words_episodes <- dialog_episodes %>%
	map(function(episode){ 
		episode %>%
			tibble(line = seq_along(.), text = .) %>%
			tidytext::unnest_tokens(output = word, 
			                        input = text)
	}) 

# Save (on .csv file per episode)
words_paths <- str_replace(text_paths, "\\.txt$", "\\.csv")
walk2(.x = words_episodes, 
      .y = words_paths,
      .f = ~ write_csv(x = .x, path = .y))







