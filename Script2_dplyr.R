library(tidyverse)
library(nycflights13)

?flights

#All flights on the first of Jan 
filter(flights, month == 1, day == 1) #Notice the use of '=='

#Save it to a variable
jan1 <- filter(flights, month == 1, day == 1)

#You can save and print to the console
(dec25 <- filter(flights, month == 12, day == 25))

#All flights that departed in Nov or Dec
filter(flights, month == 11 | month == 12)

#A useful short-hand for this problem is x %in% y. This will select every row where x 
#is one of the values in y. We could use it to rewrite the code above:

nov_dec <- filter(flights, month %in% c(11, 12,10,1))

#Flights that weren’t delayed (on arrival or departure) by more than two hours
filter(flights, !(arr_delay > 120 | dep_delay > 120))
filter(flights, arr_delay <= 120, dep_delay <= 120)

#Missing values are represented as NA
df <- tibble(x = c(1, NA, 3, NA, 5, 7))
filter(df, x > 1)
filter(df, is.na(x) | x > 1)


#Arrange rows with arrange()
#Changes the order of rows
arrange(flights, arr_delay)
arrange(flights, desc(arr_delay))
arrange(flights, year, month, day)

#Select columns with select()
select(flights, year, month, day)
# Select all columns between year and day (inclusive)
select(flights, year:day)
# Select all columns except those from year to day (inclusive)
select(flights, -(year:day))

# There are a number of helper functions you can use within select():
#   
# starts_with("abc"): matches names that begin with “abc”.
# 
# ends_with("xyz"): matches names that end with “xyz”.
# 
# contains("ijk"): matches names that contain “ijk”.
# 
# matches("(.)\\1"): selects variables that match a regular expression. 
#This one matches any variables that contain repeated characters. 
#You’ll learn more about regular expressions in strings.
# 
# num_range("x", 1:3) matches x1, x2 and x3.


#Rename
rename(flights, tail_num = tailnum)

#Move time_hour, air_time to the start of the df
select(flights, time_hour, air_time, everything())

# Add new variables with mutate()
flights_sml <- select(flights, 
                      year:day, 
                      ends_with("delay"), 
                      distance, 
                      air_time
)
mutate(flights_sml,
       gain = arr_delay - dep_delay,
       speed = distance / air_time * 60
)

#Note that you can refer to columns that you’ve just created:
mutate(flights_sml,
       gain = arr_delay - dep_delay,
       hours = air_time / 60,
       gain_per_hour = gain / hours
)

#If you only want to keep the new variables, use transmute():
transmute(flights,
          gain = arr_delay - dep_delay,
          hours = air_time / 60,
          gain_per_hour = gain / hours
)

#A not on some arithmetic
transmute(flights,
          dep_time,
          hour = dep_time %/% 100,
          minute = dep_time %% 100
)

#Lead and lag
(x <- 1:10)
lag(x)
lead(x)

#Cummulative and rolling aggregates
cumsum(x)
cummean(x)

#Ranking
y <- c(1, 2, 2, NA, 3, 4)
min_rank(y)
min_rank(desc(y))
row_number(y)
dense_rank(y)
percent_rank(y)
cume_dist(y)

#Grouped summaries with summarise()
summarise(flights, delay = mean(dep_delay, na.rm = TRUE))

#Becomes very useful with group_by()
by_day <- group_by(flights, year, month, day)
summarise(by_day, delay = mean(dep_delay, na.rm = TRUE))


#Combining multiple operations with the pipe
#Consider this code
by_dest <- group_by(flights, dest)
delay <- summarise(by_dest,
                   count = n(),
                   dist = mean(distance, na.rm = TRUE),
                   delay = mean(arr_delay, na.rm = TRUE)
)
delay <- filter(delay, count > 20, dest != "HNL")
# It looks like delays increase with distance up to ~750 miles 
# and then decrease. Maybe as flights get longer there's more 
# ability to make up delays in the air?
ggplot(data = delay, mapping = aes(x = dist, y = delay)) +
  geom_point(aes(size = count), alpha = 1/3) +
  geom_smooth(se = FALSE)

#Now look at the same code with the pipe operator
delays <- flights %>% 
  group_by(dest) %>% 
  summarise(
    count = n(),
    dist = mean(distance, na.rm = TRUE),
    delay = mean(arr_delay, na.rm = TRUE)
  ) %>% 
  filter(count > 20, dest != "HNL")

not_cancelled <- flights %>% 
  filter(!is.na(dep_delay), !is.na(arr_delay))

not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(mean = mean(dep_delay))

#Show me unique planes with highest avg delays
delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(
    delay = mean(arr_delay)
  )

ggplot(data = delays, mapping = aes(x = delay)) + 
  geom_freqpoly(binwidth = 10)
#Wow, there are some planes that have an average delay of 5 hours (300 minutes)!

# draw a scatterplot of number of flights vs. average delay:
delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(
    delay = mean(arr_delay, na.rm = TRUE),
    n = n()
  )

ggplot(data = delays, mapping = aes(x = n, y = delay)) + 
  geom_point(alpha = 1/10)

#Filter out groups with the smallest number of variations
delays %>% 
  filter(n > 25) %>% 
  ggplot(mapping = aes(x = n, y = delay)) + 
  geom_point(alpha = 1/10)

#Let’s look at how the average performance of batters in baseball is related to the number of 
#times they’re at bat.
library(Lahman)

#compute the batting average (number of hits / number of attempts) of every major league 
#baseball player
?Batting

# Convert to a tibble so it prints nicely
batting <- as_tibble(Lahman::Batting)

batters <- batting %>% 
  group_by(playerID) %>% 
  summarise(
    ba = sum(H, na.rm = TRUE) / sum(AB, na.rm = TRUE),
    ab = sum(AB, na.rm = TRUE)
  )

batters %>% 
  filter(ab > 100) %>% 
  ggplot(mapping = aes(x = ab, y = ba)) +
  geom_point(alpha=0.1) + 
  geom_smooth(se = FALSE)

#Useful summary functions
#Logical subsetting
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(
    avg_delay1 = mean(arr_delay),
    avg_delay2 = mean(arr_delay[arr_delay > 0]) # the average positive delay
  )

#Measures of spread: sd(x), IQR(x), mad(x). The mean squared deviation, or standard deviation or
#sd for short, is the standard measure of spread. The interquartile range IQR() and median 
#absolute deviation mad(x) are robust equivalents that may be more useful if you have outliers.

# Why is distance to some destinations more variable than to others?
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(distance_sd = sd(distance)) %>% 
  arrange(desc(distance_sd))

#Measures of rank: min(x), quantile(x, 0.25), max(x). Quantiles are a generalisation of the 
#median. For example, quantile(x, 0.25) will find a value of x that is greater than 25% of 
#the values, and less than the remaining 75%.

## When do the first and last flights leave each day?
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(
    first = min(dep_time),
    last = max(dep_time)
  )

#Measures of position: first(x), nth(x, 2), last(x). These work similarly to x[1], x[2], 
#and x[length(x)] but let you set a default value if that position does not exist (i.e. 
#you’re trying to get the 3rd element from a group that only has two elements). For example, 
#we can find the first and last departure for each day:

not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(
    first_dep = first(dep_time), 
    last_dep = last(dep_time)
  )

## Which destinations have the most carriers?
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(carriers = n_distinct(carrier)) %>% 
  arrange(desc(carriers))

#Counts are so useful that dplyr provides a simple helper if all you want is a count:

not_cancelled %>% 
  count(dest)

#You can optionally provide a weight variable. For example, you could use this to “count” (sum) 
#the total number of miles a plane flew:

not_cancelled %>% 
  count(tailnum, wt = distance)

## How many flights left before 5am? (these usually indicate delayed
# flights from the previous day)
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(n_early = sum(dep_time < 500))

## What proportion of flights are delayed by more than an hour?
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(hour_perc = mean(arr_delay > 60))

#Grouping by multiple variables
#When you group by multiple variables, each summary peels off one level of the grouping. 
#That makes it easy to progressively roll up a dataset:
daily <- group_by(flights, year, month, day)
(per_day   <- summarise(daily, flights = n()))
(per_month <- summarise(per_day, flights = sum(flights)))
(per_year  <- summarise(per_month, flights = sum(flights)))

#Ungrouping
#If you need to remove grouping, and return to operations on ungrouped data, use ungroup()
daily %>% 
  ungroup() %>%             # no longer grouped by date
  summarise(flights = n())  # all flights

########################################################