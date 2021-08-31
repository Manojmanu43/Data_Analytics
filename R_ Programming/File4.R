# Tidyverse main packages. 
#  1. ggplot2   --> Visualizations
#  2. dypr  -- > data manipulation 
#  3. tidyr  --> Data Cleaning
#  4. readr   --> read files

install.packages("tidyverse")
library(tidyverse) 
browseVignettes('ggplot2')

installed.packages()

install.packages("dyplr")

data("ToothGrowth")

func=filter(ToothGrowth,dose == 0.5)
view(func)

arrange(func,len)

#Nested Operatiors
arrange(filter(ToothGrowth,dose==0.5),len)

#Pipe %>% 

filtered_toothgrow = ToothGrowth %>% 
  filter(dose==0.5) %>% 
  group_by (supp) %>% 
  arrange(len)

view(filtered_toothgrow)

