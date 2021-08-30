head(diamonds)
summary(diamonds)
view(diamonds)
str(diamonds)
glimpse(diamonds)
colnames(diamonds)


#Cleaning
rename(diamonds, carat_new = carat)
rename(diamonds, carat_new = carat, cut_new = cut)

colnames(diamonds)
         


summarize(diamonds, mean_carat = mean(carat))


ggplot(data = diamonds, aes(x = carat, y = price, color=cut)) +
  geom_point()


ggplot(data = diamonds, aes(x = carat, y = price)) +
  geom_point()


ggplot(data = diamonds, aes(x = carat, y = price, color = cut)) +
  geom_point() +
  facet_wrap(~cut)

