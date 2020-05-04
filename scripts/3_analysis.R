
library(tidyverse)
library(tidytext)


text_files <- list.files("data/text/")

text_episodes <- text_files %>%
	file.path("data/text", .) %>%
	map(read_file) %>%
	map(str_split, "\n\n") %>%
	map(unlist, recursive = FALSE)

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


words_episodes <- dialog_episodes %>%
	map(function(episode){ 
	episode %>%
		tibble(line = seq_along(.), text = .) %>%
		unnest_tokens(output = word, 
									input = text)
	
}) 

nb_season_and_episode <- str_extract_all(text_files, "\\d")

episodes <-  tibble(words = words_episodes,
										season = map_chr(nb_season_and_episode, 1),
										episode = map_chr(nb_season_and_episode, 2))

episodes$curated_words <- episodes$words %>%
	map(~ anti_join(.x, stop_words, by = "word"))


episodes$top_10_words <- episodes$curated_words %>%
	map(~ count(.x, word, sort = TRUE) %>% slice(1:10)) 


words_by_season <- episodes$curated_words %>%
	split(episodes$season) %>%
	map(bind_rows) %>%
	bind_rows(.id = "season") 
	

words_by_season %>% 
	group_by(season) %>%
	count(word, sort = TRUE) %>%
	filter(n > 50) %>%
	mutate(word = reorder(word, n)) %>%
	ggplot(aes(word, n)) +
	geom_col() +
	xlab(NULL) +
	coord_flip() +
	facet_wrap(season ~ ., scales = "free")
	





