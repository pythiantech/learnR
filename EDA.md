Introduction
------------

A typical data science project looks something like the figure shown below. Credit to this goes to Hadley Wickham and his excellent book, **R For Data Science**. To begin our analysis we obbviously need to import our data. The dataset for this analysis is available [here](https://data.sonomacounty.ca.gov/Government/Animal-Shelter-Intake-and-Outcome/924a-vesw/data).
<img src="www/data-science-explore.png" alt="The Data Science Process" width="60%" />
<p class="caption">
The Data Science Process
</p>

We can download the dataset as a csv file or read it directly from the download url.

``` r
library(tidyverse)
animals <- read_csv("Data/Animal_Shelter_Intake_and_Outcome.csv")
animals <- read_csv("https://data.sonomacounty.ca.gov/api/views/924a-vesw/rows.csv?accessType=DOWNLOAD")
```

Let's have a look at our dataset. We can do this using the `glimpse()` function.

``` r
glimpse(animals)
```

    ## Observations: 13,568
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
-----------------

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

    ##  Date[1:13568], format: "2017-11-01" "2017-02-03" "2017-03-15" "2014-02-13" "2015-10-17" ...

Notice the use of back ticks around variables that are more than one word. It's easy to overlook this and a better way to work is to follow camel case convention for naming variables. I always use the tab key for auto completion and this automatically takes care of variable names being addressed in the right format.

The `table()` function is a useful function to get a contingency table of the counts of levels in a factor. So for example, if we wanted to have a quick look the counts of brred in our dataset, we could use the following code:

``` r
table(animals$Type)
```

    ## 
    ##   CAT   DOG OTHER 
    ##  4788  7767  1013

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
    ##     1362     1633     4797     4061      702

``` r
#We can again filter out animals with Unknown sex
animals <- filter(animals, Sex != 'Unknown')

animals$Sex <- ifelse(animals$Sex=='Neutered', 'Male', 
                      ifelse(animals$Sex=='Spayed','Female',animals$Sex))

table(animals$Sex)
```

    ## 
    ## Female   Male 
    ##   5423   6430

Another great function to use while examining our dataset is the `summary()` function. In one glance we can get a fairly good idea of the variable under examination.

``` r
summary(animals$`Date Of Birth`)
```

    ##         Min.      1st Qu.       Median         Mean      3rd Qu. 
    ## "1991-09-01" "2010-07-06" "2013-10-15" "2012-06-30" "2015-05-31" 
    ##         Max.         NA's 
    ## "2020-09-22"       "1866"

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

    ## Observations: 11,853
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

One of the variables in our dataset is `Location` which contains the latitude and longitude of the outcome jurisdiction. If we can extract the latitude and longitude, we could add these on a map for visualizations. I find the `qdapRegex` package very useful for claning up this type of data. We can add two new variables to our dataframe to store the values of lat and long. With the location information available as coordinates, we can use the `leaflet` package to view this information on a map.

``` r
library(qdapRegex)
library(leaflet)
animals %>% group_by(Location) %>% 
  summarise(Count=n()) %>% 
  mutate(Lat = as.numeric(ex_between(Location, "(", ",")),
         Long = as.numeric(ex_between(Location, ",", ")"))) %>% 
leaflet() %>% addTiles() %>% 
  addCircleMarkers(lng = ~Long, lat= ~Lat, radius= ~log(Count),
                   stroke=FALSE,fillOpacity = 1, label=~as.character(Count))
```

    ## Warning in validateCoords(lng, lat, funcName): Data contains 10 rows with
    ## either missing or invalid lat/lon values and will be ignored

<!--html_preserve-->

<script type="application/json" data-for="htmlwidget-d127d21429b53de28cb1">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"maxNativeZoom":null,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"continuousWorld":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":null,"unloadInvisibleTiles":null,"updateWhenIdle":null,"detectRetina":false,"reuseTiles":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"addCircleMarkers","args":[[42.755957,41.910465,41.935005,39.263236,38.930714,36.85631,35.52935,33.854626,33.866271,34.394964,28.050248,28.082313,41.141584,39.748337,42.425581,43.514016,42.555918,42.784987,44.934888,43.54731,45.669877,47.527242,42.049297,37.614904,34.751389,33.357994,39.690219,43.579675,48.063631,47.641501,48.162891,47.79018,47.724059,32.949438,33.432721,32.213472,32.404936,35.107972,34.457824,36.196748,36.112371,39.597342,39.266631,34.048752,34.066269,34.121686,34.09981,33.971609,34.010653,33.93685,34.135081,34.370818,34.314352,34.432547,34.223883,34.20031,34.201484,34.102953,34.071864,34.065164,33.096916,34.172044,35.370028,34.415572,34.459721,33.90324,33.885024,33.739949,33.490422,33.614732,33.688992,33.63,33.520913,33.814615,34.230552,34.216668,34.399277,34.291238,36.243008,35.626556,35.654147,35.28,35.475579,35.14,null,37.022284,36.822639,36.998938,36.740803,36.814954,36.523602,36.675218,36.589755,36.408938,37.570872,37.679547,37.5406,37.617695,null,37.462383,37.428476,37.486352,37.534305,37.388509,37.779168,37.772469,37.788667,37.79181,37.792737,37.749202,37.797956,37.758161,37.744235,37.770274,37.781112,37.779036,37.761208,37.800677,37.798875,37.743863,37.801827,37.720238,37.78008,37.78008,37.78008,37.450262,37.538901,37.771666,38.178317,37.807057,38.574483,37.993814,38.076211,38.596259,37.957871,37.979103,37.814603,37.967667,38.27114,38.240285,37.562619,37.521278,37.51699,37.674148,37.634142,37.718472,37.899658,37.617901,37.990808,null,37.839051,38.383156,38.281163,37.535897,37.996731,37.878896,38.014874,37.659437,38.663508,37.712627,38.172836,38.525993,37.688234,37.678849,37.755754,38.221506,37.591945,38.142213,38.104843,38.107585,37.87821,37.919929,37.916331,37.777592,37.803359,37.73935,37.762831,37.792676,37.835234,37.8118,37.82999,37.844532,37.790444,37.889693,37.89728,37.895173,37.879005,37.874698,37.946213,37.966915,37.922963,37.941502,37.973771,38.015961,37.950062,37.889888,38.341597,38.336423,38.34,38.346718,38.252266,37.972497,38.325442,38.01237,37.937811,37.896402,38.117407,38.040193,38.098743,38.109189,38.06215,38.314417,38.236012,38.245316,38.232474,38.028234,37.984409,37.942746,37.852084,37.858771,38.248242,38.314938,38.232474,37.925105,37.280602,37.316166,37.319314,37.0187,36.857424,37.428366,37.348906,37.392685,37.268102,36.937136,null,37.346161,37.327651,37.305834,37.40447,null,37.723235,37.815278,37.766311,37.640493,37.756787,37.737693,38.446019,38.439698,38.486997,38.458384,38.439152,38.403734,38.458965,39.207646,38.705157,null,39.025737,39.687738,38.424885,38.610732,38.962754,39.104621,38.790859,38.82143,39.774565,38.437394,39.003747,38.491884,39.447,38.49169,38.729916,38.371317,39.029983,38.432805,38.829858,38.510032,38.618857,38.945732,38.493009,38.933149,38.416879,39.043586,39.749972,38.875468,39.074472,38.994277,39.312148,38.787437,38.468829,39.126839,38.406591,38.803087,39.398392,39.278782,38.526497,38.394388,38.280393,null,38.744504,39.150868,39.20336,39.694597,null,39.449888,38.541541,39.18766,38.721654,40.793421,40.947237,41.790231,40.102217,40.332472,40.261044,40.124053,40.797924,40.958843,null,38.986717,38.628077,38.555454,38.568407,38.695315,38.427382,38.670213,38.268736,38.921147,38.900529,38.813687,38.740211,38.403795,38.788619,38.762846,38.642548,38.346768,38.396893,38.575311,38.543791,38.691507,38.7479,39.081823,38.761263,38.745659,38.424655,38.682162,38.683905,38.57219,38.534818,38.513021,38.47699,38.550166,38.474725,38.641743,38.6712,38.642566,38.687146,38.715607,39.255572,39.204393,40.165159,39.112728,39.049129,39.485154,39.22425,39.195816,40.645212,40.456408,39.911445,40.341658,40.277333,38.910611,45.482846,45.577751,42.173482,43.402832,42.093116,42.691701,44.109551,44.260089,44.324603,45.620522,47.801416,47.565443,47.082882,45.677838,47.645579,46.204436,64.799895,null],[-70.926956,-72.600675,-74.029167,-76.502886,-78.169861,-76.463566,-82.387152,-84.217639,-84.770776,-83.658779,-81.717769,-82.758464,-81.846327,-84.159099,-83.251881,-82.95817,-96.476781,-87.980634,-93.120336,-96.731297,-111.135457,-114.841112,-88.04882,-97.315184,-92.345343,-94.318291,-105.14615,-116.224114,-116.255192,-116.716743,-117.010208,-116.590732,-116.955403,-112.120172,-111.848279,-110.823976,-110.975904,-106.577935,-103.259956,-115.265668,-115.277992,-119.774504,-119.803378,-118.340015,-118.309481,-118.29056,-118.327083,-118.171234,-118.470964,-117.95205,-118.666211,-118.506223,-118.407984,-118.512536,-118.44426,-118.491022,-118.329884,-117.583505,-118.015342,-118.084194,-117.245946,-116.287294,-116.646298,-117.306687,-117.540203,-117.456053,-117.222995,-117.17079,-117.11091,-117.261693,-117.787794,-117.69,-117.613242,-117.824086,-119.057652,-118.990368,-118.896012,-118.87573,-120.350304,-118.438061,-118.560851,-120.66,-120.679205,-120.64,null,-120.908089,-119.362687,-119.519173,-119.75458,-119.745225,-121.430714,-121.790758,-121.866389,-121.331529,-122.364486,-122.478678,-122.510903,-122.485896,null,-122.234589,-122.276859,-122.214854,-122.247522,-122.01556,-122.419625,-122.411853,-122.394444,-122.40812,-122.420971,-122.41575,-122.40011,-122.436326,-122.485994,-122.443224,-122.461499,-122.492791,-122.48469,-122.436863,-122.464475,-122.441007,-122.411027,-122.409289,-122.420168,-122.420168,-122.420168,-122.127263,-122.302625,-122.263995,-122.240598,-121.912878,-122.451366,-121.81295,-122.148763,-122.603413,-121.972682,-122.031333,-121.985857,-121.775744,-122.026467,-122.11101,-121.998912,-121.967986,-121.926137,-122.087822,-122.064979,-122.084844,-122.115236,-121.711865,-122.129782,null,-122.122313,-122.289164,-122.294975,-122.035463,-121.694828,-122.181998,-121.911466,-121.867131,-122.455222,-121.904985,-121.732104,-122.432854,-122.15302,-122.131241,-121.963415,-121.972404,-122.048438,-122.24692,-122.246963,-122.209634,-122.070145,-122.069523,-122.020165,-122.218202,-122.208722,-122.174404,-122.155976,-122.243983,-122.283407,-122.240335,-122.217907,-122.238793,-122.182146,-122.294926,-122.278466,-122.260817,-122.266902,-122.251456,-122.371708,-122.289275,-122.338618,-122.32399,-122.51209,-122.546013,-122.541307,-122.473327,-122.94284,-123.040451,-122.7,-122.695947,-122.96092,-122.607804,-122.71081,-122.703968,-122.532324,-122.547447,-122.559327,-122.707957,-122.592459,-122.578257,-122.53789,-122.656863,-122.730241,-122.59871,-122.636846,-122.810499,-122.571597,-122.490696,-122.508468,-122.484007,-122.912052,-122.928346,-122.636846,-122.518703,-121.955079,-122.048061,-122.029264,-121.569086,-121.325919,-121.923486,-121.953709,-121.962271,-122.027252,-121.765301,null,-121.885603,-121.917248,-122.001159,-121.853161,null,-120.111544,-121.295345,-121.233996,-120.971748,-121.128369,-121.434345,-122.766748,-122.715642,-122.749134,-122.675588,-122.672541,-122.736775,-122.630156,-123.703214,-123.351858,null,-123.383614,-123.617925,-122.958249,-123.200051,-122.634743,-122.648512,-123.010876,-122.719196,-123.096794,-123.062019,-122.875074,-122.90672,-123.759003,-122.776056,-122.883041,-122.520506,-122.737493,-122.865868,-123.528149,-122.996796,-122.861927,-123.090079,-123.187703,-122.779847,-122.549913,-122.936436,-123.494392,-122.566723,-122.78264,-123.636022,-123.755471,-122.64395,-123.018829,-123.553207,-123.001365,-122.548842,-123.035768,-123.247219,-122.98045,-122.850998,-122.464588,null,-123.477587,-123.215335,-122.912221,-123.773861,null,-123.380197,-122.809202,-122.964638,-123.466828,-124.157467,-124.073351,-124.08619,-123.822225,-123.396588,-123.881456,-123.87619,-124.198924,-123.624698,null,-121.096197,-121.329889,-121.7738,-121.781217,-121.308889,-121.347323,-121.147592,-121.280389,-120.733785,-121.296946,-121.172092,-121.249879,-120.655767,-121.233952,-121.28833,-120.961437,-121.947423,-121.990331,-121.560401,-121.963641,-121.831929,-120.673649,-120.948957,-120.535397,-121.186491,-121.438065,-121.064452,-121.730249,-121.467691,-121.445732,-121.495324,-121.442638,-121.37657,-121.340819,-121.516646,-121.522246,-121.442478,-121.349139,-121.364445,-122.040774,-120.981879,-120.894207,-121.097509,-121.557929,-121.444774,-121.150564,-121.282229,-122.327472,-122.315294,-122.425007,-122.384848,-121.107163,-120.013215,-122.599304,-122.686065,-124.185173,-123.204046,-123.546764,-121.5912,-121.302315,-120.602687,-121.591817,-118.640696,-122.370709,-122.227947,-122.584729,-122.576308,-117.152872,-118.930161,-147.709756,null],[0,0,0,0,0,0,1.09861228866811,0,0,0,0,0,0,0,0,0,0,0,0,0.693147180559945,0,0.693147180559945,0.693147180559945,0,1.09861228866811,0,0,2.70805020110221,0.693147180559945,0,0,0,0,0,0,0,0,0.693147180559945,0,0,0,1.09861228866811,0,0.693147180559945,0.693147180559945,0,0,0,0,0.693147180559945,0,0,0.693147180559945,0,0,0,0,0,0,0,0,0,0,0.693147180559945,0,0,0,0.693147180559945,0,0,0,0.693147180559945,0,0,0,0,0,1.6094379124341,0.693147180559945,0,0,0,0,0,1.09861228866811,0,0.693147180559945,0,0,0,0,0,0,0,0.693147180559945,0,0,0.693147180559945,0,1.94591014905531,0,0,0,1.09861228866811,0,2.89037175789616,0,0,1.38629436111989,1.09861228866811,0,0.693147180559945,1.09861228866811,0.693147180559945,1.09861228866811,0,0.693147180559945,1.09861228866811,0,0.693147180559945,0,0,3.3322045101752,1.94591014905531,0,0.693147180559945,0.693147180559945,1.79175946922805,1.6094379124341,0,1.38629436111989,0.693147180559945,1.09861228866811,3.71357206670431,0.693147180559945,1.09861228866811,0.693147180559945,0,1.6094379124341,1.79175946922805,0.693147180559945,1.09861228866811,0,0.693147180559945,0,0.693147180559945,0,1.09861228866811,0.693147180559945,0,0,3.29583686600433,2.19722457733622,0,1.09861228866811,0,0.693147180559945,0,0,0,0.693147180559945,2.39789527279837,0.693147180559945,0,0,0,0.693147180559945,1.38629436111989,1.38629436111989,2.07944154167984,1.38629436111989,0,1.94591014905531,0,0,0,0,0,1.09861228866811,0,0,0,0.693147180559945,0,0.693147180559945,0,1.09861228866811,0,1.6094379124341,1.09861228866811,2.19722457733622,3.36729582998647,2.63905732961526,2.484906649788,0.693147180559945,0.693147180559945,1.79175946922805,2.07944154167984,0,5.97635090929793,0,2.07944154167984,4.33073334028633,0,0,1.79175946922805,2.70805020110221,0,3.97029191355212,1.09861228866811,2.07944154167984,4.34380542185368,5.73334127689775,5.17614973257383,0.693147180559945,0,0,0,0,0,0,1.6094379124341,0,0,0,0,2.70805020110221,0,0,0,0.693147180559945,0,1.09861228866811,0,0.693147180559945,0,0,0,0,0.693147180559945,0,0.693147180559945,0,0.693147180559945,0,1.38629436111989,6.78445706263764,1.6094379124341,7.2848209125686,6.85646198459459,5.99893656194668,7.02908756414966,6.19236248947487,0,2.56494935746154,0,1.38629436111989,1.09861228866811,1.09861228866811,4.38202663467388,3.13549421592915,2.07944154167984,5.25227342804663,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,5.25749537202778,1.38629436111989,3.43398720448515,3.80666248977032,3.68887945411394,1.38629436111989,1.6094379124341,1.6094379124341,5.27811465923052,5.7037824746562,1.6094379124341,2.07944154167984,1.6094379124341,3.2188758248682,2.484906649788,0.693147180559945,1.94591014905531,1.09861228866811,0,1.09861228866811,2.30258509299405,4.30406509320417,0,3.98898404656427,2.70805020110221,0.693147180559945,3.43398720448515,1.6094379124341,6.16120732169508,5.41164605185504,0,1.09861228866811,3.25809653802148,0,0,0,2.484906649788,6.880384082186,0.693147180559945,0,1.38629436111989,0,0,0,0,0,0,0,0.693147180559945,0,1.38629436111989,0,1.6094379124341,1.09861228866811,0.693147180559945,0.693147180559945,0,0,0,0,0.693147180559945,0,2.19722457733622,0,1.38629436111989,1.6094379124341,0.693147180559945,0,0,0,0.693147180559945,0,0.693147180559945,0,2.07944154167984,1.09861228866811,0,0,0,0,0,0,1.38629436111989,1.09861228866811,0,0,0,0,0,0,0,0,0,1.09861228866811,0,0,0,1.09861228866811,0,1.94591014905531,0.693147180559945,0,0.693147180559945,0.693147180559945,0,0,0,0,0,0,0.693147180559945,0,0.693147180559945,0,0,0,1.09861228866811,0,0,0,7.31986492980897],null,null,{"lineCap":null,"lineJoin":null,"clickable":true,"pointerEvents":null,"className":"","stroke":false,"color":"#03F","weight":5,"opacity":0.5,"fill":true,"fillColor":"#03F","fillOpacity":1,"dashArray":null},null,null,null,null,["1","1","1","1","1","1","3","1","1","1","1","1","1","1","1","1","1","1","1","2","1","2","2","1","3","1","1","15","2","1","1","1","1","1","1","1","1","2","1","1","1","3","1","2","2","1","1","1","1","2","1","1","2","1","1","1","1","1","1","1","1","1","1","2","1","1","1","2","1","1","1","2","1","1","1","1","1","5","2","1","1","1","1","1","3","1","2","1","1","1","1","1","1","1","2","1","1","2","1","7","1","1","1","3","1","18","1","1","4","3","1","2","3","2","3","1","2","3","1","2","1","1","28","7","1","2","2","6","5","1","4","2","3","41","2","3","2","1","5","6","2","3","1","2","1","2","1","3","2","1","1","27","9","1","3","1","2","1","1","1","2","11","2","1","1","1","2","4","4","8","4","1","7","1","1","1","1","1","3","1","1","1","2","1","2","1","3","1","5","3","9","29","14","12","2","2","6","8","1","394","1","8","76","1","1","6","15","1","53","3","8","77","309","177","2","1","1","1","1","1","1","5","1","1","1","1","15","1","1","1","2","1","3","1","2","1","1","1","1","2","1","2","1","2","1","4","884","5","1458","950","403","1129","489","1","13","1","4","3","3","80","23","8","191","2","2","2","2","192","4","31","45","40","4","5","5","196","300","5","8","5","25","12","2","7","3","1","3","10","74","1","54","15","2","31","5","474","224","1","3","26","1","1","1","12","973","2","1","4","1","1","1","1","1","1","1","2","1","4","1","5","3","2","2","1","1","1","1","2","1","9","1","4","5","2","1","1","1","2","1","2","1","8","3","1","1","1","1","1","1","4","3","1","1","1","1","1","1","1","1","1","3","1","1","1","3","1","7","2","1","2","2","1","1","1","1","1","1","2","1","2","1","1","1","3","1","1","1","1510"],null,null]}],"limits":{"lat":[28.050248,64.799895],"lng":[-147.709756,-70.926956]}},"evals":[],"jsHooks":[]}</script>
<!--/html_preserve-->
