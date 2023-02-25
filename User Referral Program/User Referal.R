#The goal of this challenge is to analyze the data from a referral program and draw conclusions about its effectiveness.

#Loading the required packages
library(tidyverse)
library(ggplot2)
library(scales)

str(referral)
summary(referral)

referral$is_referral <- as.factor(referral$is_referral)

#Checking for any missing values in the dataset
colSums(is.na(referral)) #No missing values in the dataset

#Total revenue by date
referral %>%
  ggplot(aes(x = date, y  = money_spent)) +
  stat_summary(fun = sum, geom="line") +
  geom_vline(xintercept = as.Date("2015-10-31"), linetype = 2 , color = "red")
#The plot shows a jump in daily sales after the referral program is launched on Oct 31st (dashed line in the plot)

#Revenue split between referrals and non referrals
rev_by_ref <- referral %>%
  group_by(is_referral) %>%
  summarise(unique_users = n_distinct(user_id), total_sales = sum(money_spent), revenue_per_user = sum(money_spent)/n_distinct(user_id))
rev_by_ref

referral %>%
  ggplot(aes(x = date, y  = money_spent, color = is_referral)) +
  stat_summary(fun = sum, geom="line") +
  geom_vline(xintercept = as.Date("2015-10-31"), linetype = 2, color = "blue") +
  scale_y_continuous(labels = comma)
#The plot reveals that daily sales from users, who came from referrals, are helping the overall sales after the launch of the
#program. However, due to the way the experiment is set up, the jump in sales cannot be attributed to the referral program.

# Question 1: Can you estimate the impact the program had on the site?

#Summarizing the data to get daily sales
sales_daily <- referral %>%
  group_by(date) %>%
  summarise(daily_sales = sum(money_spent))
sales_daily

#Conducting t test to check if the program had an impact
t.test(sales_daily$daily_sales[sales_daily$date < as.Date("2015-10-31")],
       sales_daily$daily_sales[sales_daily$date >= as.Date("2015-10-31")])
#The t-test suggests that the difference in daily sales before and after the launch of program is not statistically significant. 

# Compute average daily sales for each country
sales_daily_country <- referral %>%
  mutate(before_after_launch = ifelse(date < as.Date("2015-10-31"), "Before Launch", "After Launch"),
         country = as.factor(country)) %>%
  group_by(date, country, before_after_launch) %>%
  summarise(daily_sales = sum(money_spent)) %>%
  group_by(country) %>%
  summarise( avg_diff_daily_sales = mean(daily_sales[before_after_launch == "After Launch"]) -
              mean(daily_sales[before_after_launch == "Before Launch"]),
             p_value = t.test(daily_sales[before_after_launch == "Before Launch"],
             daily_sales[before_after_launch == "After Launch"])$p.value)
sales_daily_country
#The difference in average daily sales before and after launch are statistically significant for Mexico MX and China CH. However,
#sales are better after launch in MX and worse in CH.


referral %>%
  mutate(before_after_launch = ifelse(date < as.Date("2015-10-31"), "Before Launch", "After Launch"),
         country = as.factor(country)) %>%
  group_by(date, country, before_after_launch) %>%
  summarise(daily_sales = sum(money_spent)) %>%
  group_by(country, before_after_launch) %>%
  summarise(avg_daily_sales = mean(daily_sales)) %>%
  ggplot(aes(x = country, y  = avg_daily_sales, color = before_after_launch, group = before_after_launch)) +
  geom_line() +
  geom_point()
#The plot reveals that the referral program is performing differently across different countries.
#The average daily sales dropped after the launch of program in countries like China CH and Germany DE. While sales appear to 
#increase in other countries after the launch.

#Based on the way the experiment is set up, Any change in sales after the launch of referral program cannot be attributed to it alone. 
#There are other confounding factors like seasonality or launch of some marketing event that could be affecting the sales. In US and
#in some other countries, Thanks giving (occurs in end of November every year) is one of the major holiday season and sales are 
#generally expected to grow and the experiment is not controlling for the lurking variables like that.


# Question 2: Based on the data, what would you suggest to do as a next step?

#From the revenue split between referrals and non-referrals plot, It is apparent that the sales from the non-referrals, which includes
#all existing users who signed up/made purchases before Oct 31st, after launch of the program are down significantly. 

#Lets check if the drop in sales from the non-referrals is significant before and after launch of program is significant.

nonreferrals_before_vs_after <- referral %>%
  mutate(before_after_launch = ifelse(date < as.Date("2015-10-31"), "Before Launch", "After Launch")) %>%
  filter(is_referral == 0) %>%
  group_by(date, before_after_launch) %>%
  summarise(daily_sales = sum(money_spent))
nonreferrals_before_vs_after

t.test(nonreferrals_before_vs_after$daily_sales[nonreferrals_before_vs_after$before_after_launch == "Before Launch"],
       nonreferrals_before_vs_after$daily_sales[nonreferrals_before_vs_after$before_after_launch == "After Launch"])
#Clearly, T-test suggests that the difference in sales from non-referrals before and after the launch of program is statistically
#significant.

#It is quite possible that new program is cannibalizing sales from the existing users. Lets check if that is the case.


# Check if multiple users are using same device
counts_deviceid <- referral %>%
  group_by(device_id) %>%
  summarise(n_users = n_distinct(user_id), referral_types = n_distinct(is_referral)) %>%
  arrange(desc(referral_types))
counts_deviceid

# Are new referred users coming from existing devices
referrals_using_existing_devices <- referral %>%
  filter(device_id %in% counts_deviceid$device_id[counts_deviceid$referral_types > 1], is_referral == 1) %>%
  select(user_id) %>%
  distinct()
nrow(referrals_using_existing_devices)
#There are about 8571 users that were showing up as new referrals, but were using devices seen earlier.
#Clearly, users are referring themselves or members of same family.

# Question 3:The referral program wasn't really tested in a rigorous way. It simply started on a given day for all users and you are
#drawing conclusions by looking at the data before and after the test started. What kinds of risks this approach presents? Can you
#think of a better way to test the referral program and measure its impact?

#The way the referral program was tested is faulty. The experimental set up is not accounting for the seasonal nature of sales and 
#there could be confounding variables in play that affect the sales. This approach poses the risk of false positive, concluding that
#the new program is causing the jump in sales when in fact it is not. 

#A better way to test the referral program is Testing by Markets. 
#Metric : Average Daily sales