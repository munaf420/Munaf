#Loading required packages
library(tidyverse)
library(lubridate)
library(ggthemes)
library(scales)
library(data.table)

uber_data <- rbind(apr_data, may_data, june_data, july_data, aug_data, sept_data)
str(uber_data)
colnames(uber_data)[1] <- "Date_Time"
uber_data <- uber_data[, 1:8]
summary(uber_data)

#Checking for NA values
sum(is.na(uber_data))

#Converting the date_time column to the appropriate format
uber_data$Date_Time <- as.POSIXct(uber_data$Date_Time, format = "%m/%d/%Y %H:%M:%S")
uber_data$Time <- format(as.POSIXct(uber_data$Date_Time, format = "%m/%d/%Y %H:%M:%S"), format="%H:%M:%S")
uber_data$Date_Time <- ymd_hms(uber_data$Date_Time)
head(uber_data)

uber_data$day <- day(uber_data$Date_Time)
uber_data$Day_of_week <- wday(uber_data$Date_Time, label = TRUE)
uber_data$Month <- month(uber_data$Date_Time, label = TRUE)
uber_data$Hour <- hour(uber_data$Date_Time)

#Converting the base, day_of_week, Month and hour to factor variables
uber_data$Base <- as.factor(uber_data$Base)
uber_data$day_of_week <- as.factor(uber_data$day_of_week)
uber_data$Month <- as.factor(uber_data$Month)
uber_data$Hour <- as.factor(uber_data$Hour)

#Grouping the number of rides by hour
by_hour <- uber_data %>%
  group_by(Hour) %>%
  summarise(Total <- n())
colnames(by_hour) <- c("Hour" ,"Total")
data.table(by_hour)

#Plotting the graph of number of rides by hour
ggplot(by_hour, aes(Hour, Total)) + 
  geom_bar( stat = "identity", fill = "steelblue", color = "red") +
  ggtitle("Trips Every Hour") +
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5)) +
  scale_y_continuous(labels = comma)

#Grouping the number of rides by day of the week and hour
day_hour <- uber_data %>%
  group_by(day_of_week, Hour) %>%
  summarize(Total = n())

#Plotting number of rides by hour and day of the week
ggplot(day_hour, aes(Hour, Total, fill = day_of_week)) + 
  geom_bar( stat = "identity") +
  ggtitle("Trips by Hour and day of the week") +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_y_continuous(labels = comma)

by_day_of_month <- uber_data %>%
  group_by(day) %>%
  summarize(Total = n()) 
data.table(by_day_of_month)

#Plotting the number of trips by day of the month
ggplot(by_day_of_month, aes(day, Total)) + 
  geom_bar( stat = "identity", fill = "green") +
  ggtitle("Trips Every Day") +
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5)) +
  scale_y_continuous(labels = comma)

#Grouping the number of rides by day_of_week
by_dow <- uber_data %>%
  group_by(day_of_week) %>%
  summarise(Total <- n())
colnames(by_dow) <- c("day_of_week" ,"Total")
data.table(by_dow)

#Plotting trips by day of of the week
ggplot(by_dow, aes(day_of_week, Total)) + 
  geom_bar( stat = "identity", fill = "steelblue") +
  ggtitle("Number of trips every day of the week") +
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5)) +
  scale_y_continuous(labels = comma)

#Grouping the number of rides by month and day of the week
by_month_day <- uber_data %>%
  group_by(Month, day_of_week) %>%
  summarize(Total = n())

colors = c('violet', 'blue', 'green', 'yellow', 'red', 'grey', 'orange')

#Plotting number of trips by day of the week and month
ggplot(by_month_day, aes(Month, Total, fill = day_of_week)) + 
  geom_bar( stat = "identity", position = "dodge") +
  ggtitle("Trips by Day and Month") +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_y_continuous(labels = comma) +
  scale_fill_manual(values = colors)

#Grouping the number of rides by month
by_month <- uber_data %>%
  group_by(Month) %>%
  summarise(Total <- n())
colnames(by_month) <- c("Month" ,"Total")
data.table(by_month)

#Plotting number of rides by month
ggplot(by_month, aes(Month, Total, fill = Month)) + 
  geom_bar( stat = "identity") +
  ggtitle("Trips by Month") +
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5)) +
  scale_y_continuous(labels = comma) +
  scale_fill_manual(values = colors)

#Grouping the number of rides by base
by_base <- uber_data %>%
  group_by(Base) %>%
  summarise(Total <- n())
colnames(by_base) <- c('Base', 'Total')
data.table(by_base)

#Plotting number of trips by bases
ggplot(by_base, aes(Base, Total)) +
  geom_bar(stat = 'identity') +
  ggtitle('Number of trips by base') +
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5)) +
  scale_y_continuous(labels = comma)

#Grouping by base and month
by_base_month <- uber_data %>%
  group_by(Month, Base) %>%
  summarise(Total <- n())
colnames(by_base_month) <- c('Month', 'Base', "Total")
by_base_month

#Plotting the number of rides by base and month
ggplot(by_base_month, aes(Base, Total, fill = Month)) +
  geom_bar( stat = "identity", position = "dodge") +
  ggtitle("Trips by Base and Month") +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_y_continuous(labels = comma) +
  scale_fill_manual(values = colors)
  
#Grouping by base and day of week
by_base_day <- uber_data %>%
  group_by(day_of_week, Base) %>%
  summarise(Total <- n())
colnames(by_base_day) <- c('Day', 'Base', "Total")
data.table(by_base_day)

#Plotting the number of rides by base and day of week
ggplot(by_base_day, aes(Base, Total, fill = Day)) +
  geom_bar( stat = "identity", position = "dodge") +
  ggtitle("Trips by Base and Day") +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_y_continuous(labels = comma) +
  scale_fill_manual(values = colors)

#Plotting heat map for number of rides by day of the week and hour
ggplot(day_hour, aes(day_of_week, Hour, fill = Total)) +
  geom_tile(color = "white") +
  theme(plot.title = element_text(hjust = 0.5)) +
  ggtitle("Heat Map by Hour and Day")

#Plotting heat map for number of rides by day of the week and month
ggplot(by_month_day, aes(day_of_week, Month, fill = Total)) +
  geom_tile(color = "white") +
  theme(plot.title = element_text(hjust = 0.5)) +
  ggtitle("Heat Map by Month and Day")
