library(tidyverse)

animals <- read_csv("Animal_Shelter_Intake_and_Outcome.csv")
animals <- read_csv("https://data.sonomacounty.ca.gov/api/views/924a-vesw/rows.csv?accessType=DOWNLOAD")
glimpse(animals)
