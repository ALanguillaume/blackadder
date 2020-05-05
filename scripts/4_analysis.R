
library(stringr)
library(purrr)
library(dplyr)
library(ggplot2)
library(tidytext)
source("scripts/blackadder_funcs.R")

# Read words
words_paths <- list.files("data/words/", full.names = TRUE)
words_episodes <- words_paths %>%
	map(~ read_csv(file = .x, col_types = "cc"))

# Construct tibble with list column of word tibbles,
# including also season and episode number
nb_season_and_episode <- str_extract_all(words_paths, "\\d")
episodes <-  tibble(words = words_episodes,
										season = map_chr(nb_season_and_episode, 1),
										episode = map_chr(nb_season_and_episode, 2))

# Remove "stop words" .i.e highly recurring words in the English lenaguage
# not useful for text analysis.
episodes$curated_words <- episodes$words %>%
	map(~ anti_join(.x, tidytext::stop_words, by = "word"))

# Make a data.frame of all words by season
words_by_season <- episodes$curated_words %>%
	split(episodes$season) %>%
	map(bind_rows) %>%
	bind_rows(.id = "season") 


top_10_words_by_season <- 
	words_by_season %>% 
	group_by(season) %>%
	count(word, sort = TRUE) %>%
	slice(1:10)

color_seasons <- RColorBrewer::brewer.pal(n = 4, name = "Set1")


list_top_10_words_by_season <- top_10_words_by_season %>% split(.$season)
	
season_plots <- map2(.x = list_top_10_words_by_season, 
										 .y = color_seasons,
										 .f = ~ plot_nb_words_season(df = .x, color = .y))

plot_all_season <- ggpubr::ggarrange(plotlist = season_plots)

ggsave(filename = "results/figures/top-10-words-season.png", 
			 plot =  plot_all_season, 
			 width = 9,
			 height = 7)
