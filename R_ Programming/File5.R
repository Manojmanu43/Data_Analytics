view(diamonds)
colnames(diamonds)
tibble(diamonds)
head(diamonds)
str(diamonds)
glimpse(diamonds)



#Creating new column
new_df=mutate(diamonds, Carat_new = carat*2)
colnames(diamonds)
colnames(new_df)


#Creating new dataframe
names <- c("Manoj", "Kumar", "Venkata", "Thokala")
age <- c(20,21,22,23)
x=data.frame(names,age)
x
x$names
x$age
mutate(x, age_in_20 = age + 20)



new_df=read.csv("C:/Users/venka/Documents/R/R programmign Learning/data_R.csv")
colnames(new_df)
summary(new_df)


df2=select(new_df,'adr',adults)
tibble(df2)
