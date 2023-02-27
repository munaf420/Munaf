library(tidyverse)
library(knitr)
library(kableExtra)
library(zoo)
library(DataCombine)

str(activity)
str(registrations)

activity$id <- substr(activity$id, 4, nchar(activity$id))

registrations$id <- substr(registrations$id, 4, nchar(registrations$id))

#Number of registrations by month
by_month <- activity %>%
  group_by(registration_month) %>%
  summarize(count = n_distinct(id))
  
ggplot(data = by_month, aes(x = registration_month, y = count, fill = ifelse(registration_month <= 12, 1, 2))) +
  geom_col(show.legend = FALSE) +
  ggtitle("Figure 1 : Number of registrations by month") +
  theme(plot.title = element_text(hjust = 0.5))


## Year over year growth of registrations
#Adding year and month
activity <- activity %>%
  mutate(year = ifelse(registration_month <= 12, 1, 2),
         reg_month = ifelse(registration_month <= 12, registration_month, registration_month-12))

# summarize registration number by year and month
yoyg <- activity %>%   
  select(id, year, reg_month) %>% 
  group_by(reg_month, year) %>% 
  summarize(n_distinct(id)) %>% 
  rename(regs = 'n_distinct(id)')

yoyg <- yoyg %>%
  spread(year, regs) %>%
  rename(year_1 = '1', year_2 = '2') %>% 
  mutate(yoyg = year_2 / year_1) %>% 
  select(reg_month, yoyg) %>%
  filter(reg_month <= 10)

yoyg$reg_month <- as.factor(yoyg$reg_month)

kable(yoyg, caption = 'Table 1: Year on Year Growth of registrations') %>%
  kable_styling('striped', full_width = F, position = 'center') %>%
  row_spec(0, color = 'white', background = 'blue', align ='c')

#Growth rates of each month
ts <- ts(yoyg$yoyg, frequency = 1, start = 1, end = 9)
plot(ts, main = "Figure 2 : Year on year growth")

#Registrations based on region
by_region <- activity %>%   
  select(id, year, reg_month, region) %>% 
  group_by(region, reg_month, year) %>% 
  summarize(n_distinct(id)) %>% 
  rename(regs = 'n_distinct(id)')

by_region <- by_region %>%
  spread(year, regs) %>%
  rename(year_1 = '1', year_2 = '2') %>% 
  mutate(yoyg = year_2 / year_1) %>% 
  select(reg_month, yoyg) %>%
  filter(reg_month < 10)

ggplot(data = by_region, aes(x = reg_month, y = yoyg, col = region)) +
  geom_line(size = 1.5) +
  ggtitle('Figure 3: Region differences in year-on-year growth')

#Active users in each month
activity %>%
  group_by(activity_month) %>% 
  summarize(count = n()) %>% 
  ggplot(aes(x = activity_month, y = count, fill = ifelse(activity_month <= 12, 1, 2))) +
  geom_col(show.legend = FALSE) +
  ggtitle('Figure 4: number of active users per month')

#Percentage of America among active users
activity %>%
  group_by(region, activity_month) %>% 
  summarize(count = n()) %>% 
  ggplot(aes(x = activity_month, y = count, fill = ifelse(region == 'America', 1, 2))) +
  geom_bar(position = 'fill', stat = 'identity', show.legend = FALSE) +
  ggtitle('Figure 5: number of active users per month') +
  theme(plot.title = element_text(hjust = 0.5))

#Looking at user's activity pattern
activity_slide <- slide(data = activity, Var = 'activity_month', TimeVar = 'activity_month',
                    GroupVar = 'id', NewVar = 'prev_activity', slideBy = -1,
                    keepInvalid = FALSE, reminder = TRUE)

activity_slide <- activity_slide %>%
  mutate(class = ifelse(activity_month == registration_month, 'New',
                        ifelse(activity_month - 1 != prev_activity | is.na(prev_activity), 'Resurrected', 'Retained')))

#Looking at a randomly chosen user's activity history
activity_slide %>% 
  filter(id == '33929') %>% 
  select(id, activity_month, registration_month, class) %>% 
  kable(caption = 'Table 2: User activity history') %>%
  kable_styling('striped', full_width = F, position = 'center') %>%
  row_spec(0, color = 'white', background = 'blue', align ='c')

#Number of retained active users in each month
activity_slide %>%
  filter(class == 'Retained') %>% 
  group_by(activity_month) %>% 
  summarize(count = n()) %>% 
  ggplot(aes(x = activity_month, y = count, fill = ifelse(activity_month <= 12, 1, 2))) +
  geom_col(show.legend = FALSE) +
  ggtitle('Figure 6: Number of Retained users per month') +
  theme(plot.title = element_text(hjust = 0.5))

#Second month retention rate
registered_month_1 <- activity %>%
  filter(registration_month == 1) %>% 
  summarize(count = n_distinct(id))

activity_month_2 <- activity %>% 
  filter(registration_month == 1 & activity_month == 2) %>% 
  summarize(count = n())

retention_rate_1_2 <- paste0(round(activity_month_2[[1]] / registered_month_1[[1]], 4) * 100, '%')

#Second month retention rate based on operating system
opsys_month_1 <- activity %>%
  filter(registration_month == 1) %>% 
  group_by(operating_system) %>% 
  summarize(reg_count = n_distinct(id))

opsys_month_2 <- activity %>% 
  filter(registration_month == 1 & activity_month == 2) %>%
  group_by(operating_system) %>% 
  summarize(active_count = n())

opsys_retention_rate <- left_join(opsys_month_1, opsys_month_2, by = 'operating_system') %>% 
  mutate(opsys_retention = round(active_count / reg_count, 4) * 100)

kable(opsys_retention_rate, caption = 'Table 3: Second month retention rate by Operating System') %>%
  kable_styling('striped', full_width = F, position = 'center') %>%
  row_spec(0, color = 'white', background = 'blue', align ='c')
