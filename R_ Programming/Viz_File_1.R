library("tidyverse")
library(palmerpenguins)
library(dplyr)
tibble(penguins)
new_df=penguins %>% 
  drop_na(flipper_length_mm,body_mass_g)
ggplot(data = new_df) + 
  geom_point(mapping = aes(x = flipper_length_mm, y = body_mass_g,col=species))



ggplot(data = new_df) + 
  geom_point(mapping = aes(x = flipper_length_mm, y = body_mass_g,col=species,color=species,shape=species,size=species,alpha=species))


ggplot(data = new_df) + 
  geom_point(mapping = aes(x = flipper_length_mm, y = body_mass_g),color="purple")


#hotel_bookings <- read.csv("data_R.csv")
#view(hotel_bookings)
#colnames(hotel_bookings)
##ggplot(data = hotel_bookings) +
#  geom_point(mapping = aes(x = stays_in_weekend_nights, y = children))

#ggplot(data = hotel_bookings) +
#  geom_bar(mapping = aes(x = children,color=children))


ggplot(data=new_df) +
  geom_smooth(mapping = aes(x = flipper_length_mm, y = body_mass_g),color="purple") +
  geom_point(mapping = aes(x = flipper_length_mm, y = body_mass_g))


ggplot(data=new_df) +
  geom_smooth(mapping = aes(x = flipper_length_mm, y = body_mass_g,linetype=species),color="purple")


ggplot(data=new_df) +
  geom_jitter(mapping = aes(x = flipper_length_mm, y = body_mass_g))




#Bar Graphs
ggplot(data=diamonds) +
  geom_bar(mapping = aes(x=cut,color=cut))

ggplot(data=diamonds) +
  geom_bar(mapping = aes(x=cut,fill=cut))


ggplot(data=diamonds) +
  geom_bar(mapping = aes(x=cut,fill=clarity))


#Facets


ggplot(data=new_df) +
  geom_point(mapping = aes(x = flipper_length_mm, y = body_mass_g,color=species)) +
  facet_wrap(~species) 


ggplot(data=diamonds) +
  geom_bar(mapping = aes(x=color,fill=cut)) +
  facet_wrap(~cut)
  

ggplot(data=new_df) +
  geom_point(mapping = aes(x = flipper_length_mm, y = body_mass_g,color=species)) +
  facet_grid(~sex)


hotel_bookings <- read.csv("data_R.csv")
ggplot(data = hotel_bookings) +
  geom_bar(mapping = aes(x = distribution_channel))
ggplot(data = hotel_bookings) +
  geom_bar(mapping = aes(x = distribution_channel, fill=deposit_type))

ggplot(data = hotel_bookings) +
  geom_bar(mapping = aes(x = distribution_channel, fill=market_segment))


ggplot(data = hotel_bookings) +
  geom_bar(mapping = aes(x = distribution_channel)) +
  facet_wrap(~deposit_type )


ggplot(data = hotel_bookings) +
  geom_bar(mapping = aes(x = distribution_channel)) +
  facet_wrap(~deposit_type) +
  theme(axis.text.x = element_text(angle = 45))


ggplot(data = hotel_bookings) +
  geom_bar(mapping = aes(x = distribution_channel)) +
  facet_wrap(~market_segment) +
  theme(axis.text.x = element_text(angle = 45))

ggplot(data = hotel_bookings) +
  geom_bar(mapping = aes(x = distribution_channel)) +
  facet_grid(~deposit_type) +
  theme(axis.text.x = element_text(angle = 45))



ggplot(data = hotel_bookings) +
  geom_bar(mapping = aes(x = distribution_channel)) +
  facet_wrap(~deposit_type~market_segment) +
  theme(axis.text.x = element_text(angle = 45))



ggplot(data = hotel_bookings) +
  geom_point(mapping = aes(x = lead_time, y = children))

ggplot(data = hotel_bookings) +
  geom_bar(mapping = aes(x = hotel, fill = market_segment))

ggplot(data = hotel_bookings) +
  geom_bar(mapping = aes(x = hotel)) +
  facet_wrap(~market_segment)




onlineta_city_hotels_v2 <- hotel_bookings %>%
  filter(hotel=="City Hotel") %>%
  filter(market_segment=="Online TA")


ggplot(data = onlineta_city_hotels_v2) +
  geom_point(mapping = aes(x = lead_time, y = children))

tibble(onlineta_city_hotels_v2)


#Labels

ggplot(data=new_df) +
  geom_point(mapping = aes(x = flipper_length_mm, y = body_mass_g,color=species)) +
  labs(title="My first Plot",subtitle = "flipper_length vs body_mass_g",caption = "Data collected from Google Data Analytics course")
  

#Annotations

ggplot(data=new_df) +
  geom_point(mapping = aes(x = flipper_length_mm, y = body_mass_g,color=species)) +
  labs(title="My first Plot",subtitle = "flipper_length vs body_mass_g",caption = "Data collected from Google Data Analytics course") +
  annotate("text",x=200,y=5500,label="inside grid", color="red" , fontface="bold",size=4.5)  
 

plt <- ggplot(data=new_df) +
  geom_point(mapping = aes(x = flipper_length_mm, y = body_mass_g,color=species)) +
  labs(title="My first Plot",subtitle = "flipper_length vs body_mass_g",caption = "Data collected from Google Data Analytics course") 

plt +   annotate("text",x=200,y=5500,label="inside grid", color="red" , fontface="bold",size=4.5)


ggsave("Three species comparison.png")


#Saving file in png
png(file = "exampleplot.png", bg = "transparent")
plot(1:10)
rect(1, 5, 3, 7, col = "white")
dev.off()


#Saving file in pdf
pdf(file = "C:/Users/venka/Documents/R/R_ Programming/example.pdf",    
    width = 4,     
    height = 4) 
plot(x = 1:10,     
     y = 1:10)
abline(v = 0)
text(x = 0, y = 1, labels = "Random text")
dev.off()



ggplot(data = hotel_bookings) +
  geom_bar(mapping = aes(x = market_segment)) +
  facet_wrap(~hotel)


ggplot(data = hotel_bookings) +
  geom_bar(mapping = aes(x = market_segment)) +
  facet_wrap(~hotel) +
  labs(title="Practise Session")

mindate <- min(hotel_bookings$arrival_date_year)
maxdate <- max(hotel_bookings$arrival_date_year)

ggplot(data = hotel_bookings) +
  geom_bar(mapping = aes(x = market_segment)) +
  facet_wrap(~hotel) +
  theme(axis.text.x = element_text(angle = 45)) +
  labs(title="Comparison of market segments by hotel type for hotel bookings",
       subtitle=paste0("Data from: ", mindate, " to ", maxdate))

ggplot(data = hotel_bookings) +
  geom_bar(mapping = aes(x = market_segment)) +
  facet_wrap(~hotel) +
  theme(axis.text.x = element_text(angle = 45)) +
  labs(title="Comparison of market segments by hotel type for hotel bookings",
       caption=paste0("Data from: ", mindate, " to ", maxdate))
  

ggplot(data = hotel_bookings) +
  geom_bar(mapping = aes(x = market_segment)) +
  facet_wrap(~hotel) +
  theme(axis.text.x = element_text(angle = 45)) +
  labs(title="Comparison of market segments by hotel type for hotel bookings",
       caption=paste0("Data from: ", mindate, " to ", maxdate),
       x="Market Segment",
       y="Number of Bookings")

ggsave('hotel_booking_chart.png')
