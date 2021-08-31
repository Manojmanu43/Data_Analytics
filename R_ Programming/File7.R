library(tidyverse)
library(tidyr)
library(skimr)
library(janitor)


hotel_df=read.csv("C:/Users/venka/Documents/R/R programmign Learning/data_R.csv")
tibble(new_df)

skim_without_charts(new_df)
colnames(new_df)

trimmed_df <- new_df %>% 
  select(1 ,2 ,3 )
trimmed_df


trimmed_df <- new_df %>% 
  select(1 ,2 ,3 ) %>% 
  group_by(hotel) %>% 
  count()
#  summarize("count" = count(hotel))
trimmed_df

trimmed_df <- new_df %>% 
  select(hotel, is_canceled, lead_time) %>% 
  rename('Hotel Type' = hotel)
tibble(trimmed_df)

example_df <-new_df %>%
  select(arrival_date_year, arrival_date_month) %>% 
  unite(arrival_month_year, c("arrival_date_month", "arrival_date_year"), sep = " ")

tibble(example_df)


colnames(new_df)
example_df <- new_df%>%
  mutate(guests =  adults + children +  babies) %>% 
  select(guests)

tibble(example_df)
view(new_df)
cacelled_bookings <- new_df %>% 
  select(is_canceled) %>% 
  filter(is_canceled ==1) %>% 
  count()
tibble(cacelled_bookings)




id <- c(1:10)
name <- c("John Mendes", "Rob Stewart", "Rachel Abrahamson", "Christy Hickman", "Johnson Harper", "Candace Miller", "Carlson Landy", "Pansy Jordan", "Darius Berry", "Claudia Garcia")
job_title <- c("Professional", "Programmer", "Management", "Clerical", "Developer", "Programmer", "Management", "Clerical", "Developer", "Programmer")
employee <- data.frame(id, name, job_title)

tibble(employee)

data <- employee %>% 
  select(job_title) %>% 
  group_by(job_title) %>% 
  count()
data

new_emp_df=separate(employee,name, into=c('first_name','last_name'),sep=' ')
tibble(new_emp_df)

unite(new_emp_df,first_name,last_name,sep=',',col='full_Name')




library(palmerpenguins)
penguins %>%
  arrange(bill_length_mm)


install.packages("Tmisc")
library("Tmisc")
View(quartet)


head(hotel_df)
tibble(hotel_df)
str(hotel_df)

max(hotel_df$lead_time)



hotel_summary <- hotel_df %>%
#  group_by(hotel) %>%
  summarize(average_lead_time=mean(lead_time),
            min_lead_time=min(lead_time),
            max_lead_time=max(lead_time))
tibble(hotel_summary)
