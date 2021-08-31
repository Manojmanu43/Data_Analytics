install.packages("here")
install.packages("skimr")
install.packages("janitor")
install.packages("dplyr")
library("tidyverse")
library("here")
library("skimr")
library("janitor")
library("tidyr")
install.packages("palmerpenguins")

library(palmerpenguins)
view(penguins)
tibble(penguins)



skim_without_charts(penguins)

penguins %>% 
  select(-species)

penguins %>% 
  rename(bill_len=bill_length_mm)

rename_with(toupper,penguins)
rename_with(penguins, toupper)

penguins %>% 
  rename_with(toupper)

colnames(penguins)

clean_names(penguins)              


df=penguins %>% 
  arrange(-bill_length_mm)

view(df)

df %>% 
  select(species) %>% 
  group_by(species) %>% 
  count()


df %>% 
#  select(species) %>% 
  group_by(species) %>% 
  drop_na() %>% 
  summarize(mean_length=mean(bill_length_mm))

colnames(df)



  
