##### Text Analyis: The Black Adder
#### Antoine Languillaume
#### Build Script

# Install required packages if necessary
required_packages <- c("tidyverse", "tidytext", "ggpubr", 
											 "magick", "here", "knitr", "rmarkdown")

for (package in required_packages) {
	if(package %in% rownames(installed.packages()) == FALSE){
		install.packages(package, dependencies = TRUE)
	}
}

# Run all scripts in the correct order
all_scripts <- list.files("scripts", full.names = TRUE) 

target_scripts <- all_scripts[grep("[1-9]", all_scripts)]

for(script in target_scripts) source(script, local = TRUE)

# Build the final report
rmarkdown::render("report/The_Cunning_Report.Rmd")
