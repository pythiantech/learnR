Introduction
============

A typical data science project looks something like the figure shown below. Credit to this goes to Hadley Wickham and his excellent book, **R For Data Science**. To begin our analysis we obbviously need to import our data. The dataset for this analysis is available [here](https://data.sonomacounty.ca.gov/Government/Animal-Shelter-Intake-and-Outcome/924a-vesw/data).
<img src="data-science-explore.png" alt="The Data Science Process" width="60%" />
<p class="caption">
The Data Science Process
</p>

We can download the dataset as a csv file or read it directly from the download url.

``` r
library(tidyverse)
animals <- read_csv("Animal_Shelter_Intake_and_Outcome.csv")
# animals <- read_csv("https://data.sonomacounty.ca.gov/api/views/924a-vesw/rows.csv?accessType=DOWNLOAD")
```

Let's have a look at our dataset. We can do this using the `glimpse()` function.

``` r
glimpse(animals)
```

    ## Observations: 13,560
    ## Variables: 24
    ## $ Name                   <chr> NA, "SUGAR", "*MILLIE", "SAM", "ZEUS", ...
    ## $ Type                   <chr> "CAT", "DOG", "DOG", "DOG", "DOG", "DOG...
    ## $ Breed                  <chr> "DOMESTIC SH", "LABRADOR RETR", "CHIHUA...
    ## $ Color                  <chr> "BLACK", "YELLOW", "BLUE/TAN", "YELLOW"...
    ## $ Sex                    <chr> "Male", "Neutered", "Spayed", "Male", "...
    ## $ Size                   <chr> "KITTN", "LARGE", "TOY", "LARGE", "X-LR...
    ## $ `Date Of Birth`        <chr> NA, "09/24/2008", "03/29/2009", "11/01/...
    ## $ `Impound Number`       <chr> "K17-026134", "K17-022441", "K17-022804...
    ## $ `Kennel Number`        <chr> "FREEZER", "DS75", "DA05", "DS66", "DS6...
    ## $ `Animal ID`            <chr> "A363799", "A228255", "A349551", "A2117...
    ## $ `Intake Date`          <chr> "11/01/2017", "02/03/2017", "03/15/2017...
    ## $ `Outcome Date`         <chr> "11/01/2017", "02/04/2017", "05/06/2017...
    ## $ `Days in Shelter`      <int> 0, 1, 52, 1, 0, 16, 34, 212, 7, 0, 0, 8...
    ## $ `Intake Type`          <chr> "STRAY", "STRAY", "STRAY", "STRAY", "ST...
    ## $ `Intake Subtype`       <chr> "FIELD", "FIELD", "OVER THE COUNTER", "...
    ## $ `Outcome Type`         <chr> "EUTHANIZE", "RETURN TO OWNER", "ADOPTI...
    ## $ `Outcome Subtype`      <chr> "INJ SEVERE", "OVER THE COUNTER_WEB", "...
    ## $ `Intake Condition`     <chr> "UNTREATABLE", "HEALTHY", "TREATABLE/RE...
    ## $ `Outcome Condition`    <chr> "UNTREATABLE", "HEALTHY", "HEALTHY", "H...
    ## $ `Intake Jurisdiction`  <chr> "COUNTY", "COUNTY", "SANTA ROSA", "SANT...
    ## $ `Outcome Jurisdiction` <chr> NA, "COUNTY", "OUT OF COUNTY", "*CLOVER...
    ## $ `Outcome Zip Code`     <int> NA, 95404, 94591, 95425, 95409, 95407, ...
    ## $ Location               <chr> NA, "95404\n(38.458384, -122.675588)", ...
    ## $ Count                  <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ...

Transforming Data
=================

As you can see there are some date fields which have been read in as characters. We need to convert these to dates. We can use functions from the `lubridate` package in order to achieve this.

``` r
library(lubridate)
animals$`Outcome Date` <- mdy(animals$`Outcome Date`)
animals$`Intake Date` <- mdy(animals$`Intake Date`)
animals$`Date Of Birth` <- mdy(animals$`Date Of Birth`)
```

The `mdy()` function converts the character variables to date variables in month, day, year format. We can check the structure of these fileds now to ascertain whether the conversion has happened.

``` r
str(animals$`Intake Date`)
```

    ##  Date[1:13560], format: "2017-11-01" "2017-02-03" "2017-03-15" "2014-02-13" "2015-10-17" ...

Notice the use of back ticks around variables that are more than one word. It's easy to overlook this and a better way to work is to follow camel case convention for naming variables. I always use the tab key for auto completion and this automatically takes care of variable names being addressed in the right format.

The `table()` function is a useful function to get a contingency table of the counts of levels in a factor. So for example, if we wanted to have a quick look the counts of brred in our dataset, we could use the following code:

``` r
table(animals$Type)
```

    ## 
    ##   CAT   DOG OTHER 
    ##  4788  7760  1012

As you can see there are some animals calssified as 'OTHER'. We can get rid of these and only work with dogs and cats. We can use the `filter()` function from `dplyr` to achieve this.

``` r
animals <- filter(animals, Type != 'OTHER')
```

By looking at the `Sex` variable, we can see that some of the animals have had a snippy-snippy job done on them! However to maintain their dignity, let's still classify them as Male or Female.

``` r
table(animals$Sex)
```

    ## 
    ##   Female     Male Neutered   Spayed  Unknown 
    ##     1361     1634     4794     4058      701

``` r
#We can again filter out animals with Unknown sex
animals <- filter(animals, Sex != 'Unknown')

animals$Sex <- ifelse(animals$Sex=='Neutered', 'Male', 
                      ifelse(animals$Sex=='Spayed','Female',animals$Sex))

table(animals$Sex)
```

    ## 
    ## Female   Male 
    ##   5419   6428

Another great function to use while examining our dataset is the `summary()` function. In one glance we can get a fairly good idea of the variable under examination.

``` r
summary(animals$`Date Of Birth`)
```

    ##         Min.      1st Qu.       Median         Mean      3rd Qu. 
    ## "1991-09-01" "2010-07-06" "2013-10-15" "2012-06-30" "2015-05-31" 
    ##         Max.         NA's 
    ## "2020-09-22"       "1863"

Do we spot some trouble here? If you look at the max value, we can see that some animals aren't born yet. Their year of birth is 2020. Also there are some missing values. While we could impute some values for the missing data, we will stick to just changing these values to NA.

``` r
animals$`Date Of Birth`[animals$`Date Of Birth`>Sys.Date() & !is.na(animals$`Date Of Birth`)] <- NA
```

Similarly, the DOB column cannot be greater than the `Intake Date`. A similar cleaning up can be performed on it.

``` r
animals$`Date Of Birth`[animals$`Date Of Birth`>animals$`Intake Date` & !is.na(animals$`Date Of Birth`)] <- NA
```

We also notice that some of the variables here should actually be factor variables and not characters. Typically Type, Breed, Color, Sex etc. should be factors. If you are not familiar with factor variables, watch [this](https://www.youtube.com/watch?v=xkRBfy8_2MU). We will make a new variable which will contain all the names of the variables that we want to convert into factors, and then use the `mutate_at()` function from `dplyr` to convert all of them into factors. We could have done this individually too by using the `as.factor()` function, but since we have a large number of variables, it makes sense to convert them all at once withour writing additional code. As a programmer, try to be as lazy as possible.

``` r
library(magrittr)
cols <- c(colnames(animals)[2:6],"Intake Type","Outcome Type","Intake Condition","Outcome Condition")

animals %<>% mutate_at(cols, funs(factor(.)))
```

Notice that we have used another package called `magrittr`. This was the package that brought in the use of the pipe operator ( `%>%` ) and a host of other operators like `%<>%` which we used in the code above. This operator updates the left hand side with the resulting value. Seek help on `mutate_at()` to understand what just happened. If we now take a look at our data, we will see that the character variables have indeed changed to factor variables.

``` r
glimpse(animals)
```

    ## Observations: 11,847
    ## Variables: 24
    ## $ Name                   <chr> NA, "SUGAR", "*MILLIE", "SAM", "ZEUS", ...
    ## $ Type                   <fct> CAT, DOG, DOG, DOG, DOG, DOG, DOG, DOG,...
    ## $ Breed                  <fct> DOMESTIC SH, LABRADOR RETR, CHIHUAHUA S...
    ## $ Color                  <fct> BLACK, YELLOW, BLUE/TAN, YELLOW, BLACK/...
    ## $ Sex                    <fct> Male, Male, Female, Male, Male, Female,...
    ## $ Size                   <fct> KITTN, LARGE, TOY, LARGE, X-LRG, MED, S...
    ## $ `Date Of Birth`        <date> NA, 2008-09-24, 2009-03-29, 2007-11-01...
    ## $ `Impound Number`       <chr> "K17-026134", "K17-022441", "K17-022804...
    ## $ `Kennel Number`        <chr> "FREEZER", "DS75", "DA05", "DS66", "DS6...
    ## $ `Animal ID`            <chr> "A363799", "A228255", "A349551", "A2117...
    ## $ `Intake Date`          <date> 2017-11-01, 2017-02-03, 2017-03-15, 20...
    ## $ `Outcome Date`         <date> 2017-11-01, 2017-02-04, 2017-05-06, 20...
    ## $ `Days in Shelter`      <int> 0, 1, 52, 1, 0, 16, 34, 212, 0, 0, 8, 1...
    ## $ `Intake Type`          <fct> STRAY, STRAY, STRAY, STRAY, STRAY, STRA...
    ## $ `Intake Subtype`       <chr> "FIELD", "FIELD", "OVER THE COUNTER", "...
    ## $ `Outcome Type`         <fct> EUTHANIZE, RETURN TO OWNER, ADOPTION, R...
    ## $ `Outcome Subtype`      <chr> "INJ SEVERE", "OVER THE COUNTER_WEB", "...
    ## $ `Intake Condition`     <fct> UNTREATABLE, HEALTHY, TREATABLE/REHAB, ...
    ## $ `Outcome Condition`    <fct> UNTREATABLE, HEALTHY, HEALTHY, HEALTHY,...
    ## $ `Intake Jurisdiction`  <chr> "COUNTY", "COUNTY", "SANTA ROSA", "SANT...
    ## $ `Outcome Jurisdiction` <chr> NA, "COUNTY", "OUT OF COUNTY", "*CLOVER...
    ## $ `Outcome Zip Code`     <int> NA, 95404, 94591, 95425, 95409, 95407, ...
    ## $ Location               <chr> NA, "95404\n(38.458384, -122.675588)", ...
    ## $ Count                  <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ...
