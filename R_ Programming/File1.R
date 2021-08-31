library(tidyverse)

#install.packages("palmerpenguins")

library(palmerpenguins)

data(package = 'palmerpenguins')

head(penguins)

summary(penguins)

head(penguins_raw)

summary(penguins_raw)

str(penguins)

penguins$species

penguins %>%
  count(species)

penguins %>%
group_by(species) %>%
summarize(across(where(is.numeric), mean, na.rm = TRUE))

citation("palmerpenguins")

library(palmerpenguins)

summary(penguins)
summary(penguins_raw)
library(tidyverse)
penguins %>%
count(species)
penguins %>%
group_by(species) %>%
summarize(across(where(is.numeric), mean, na.rm = TRUE))
View(penguins)

penguins$species

View(penguins)
library(tidyverse)
print("Starting R Language")
?print()
a= " new variable"
a
a <- "New Variable"
a
#Atomic Vectors  --> Stores single data type
a=c(1,2,3,54,5,6,45,4)
a
a=c(1,2,3,54,5,6,45,4.1)
a
a=c(1,2,3,54,5,6,45,4.1,'Manoj')
a
a=c(1,2,3,54,5,6,45,4.1,'Manoj',TRUE)
a
a=c(TRUE, FALSE)
a
typeof(a)
a=c(1,2,3,54,5,6,45,4.1,'Manoj',TRUE)
typeof(a)
length(a)
is.character(a)
is.integer(a)
names(a)=c('x','y','z')
print(a)

#List  -- Stores multiple data types
b=list("a", 1L, 1.5, TRUE)
print(b)

c=list(list(list(1 , 3, 5)))
print(c)

str(b)
str(c)

#list("Chicago" <- 1,"New York" <- 2,"Los Angeles" <- 3)
#print(d)

# Lubridate package
library(lubridate)
today()
now()
ymd("2021-01-20")
mdy("January 20th, 2021")
dmy("20-Jan-2021")
ymd(20210120)
ymd_hms("2021-01-20 20:11:59")
mdy_hm("01/20/2021 08:01")


as_date(now())   # Converts datetime to date function




#Dataframes

z=data.frame(x = c(1, 2, 3) , y = c(1.5, 5.5, 7.5))
z
z$x
z$y


#Files
dir()
setwd("~/R Folder")
dir.create("R Folder")
file.create('abc.txt')
dir.exists("R Folder")
file.exists("C:/Users/venka/Documents/source.txt")
setwd("C:/Users/venka/Documents/R Folder")
file.copy("C:/Users/venka/Documents/source.txt","destination.txt")

