##Code to get American Community Survey Data using Census API
## Matthew Fitzgerald
## March 1, 2021




#############################################################
# NOTE: Some of the values are listed as -666666666.0
# See https://www.census.gov/data/developers/data-sets/acs-1year/data-notes.html for details
# Need to remove these and any other negative values
#############################################################

## Install and load censusapi 
install.packages("censusapi")
library(censusapi)
library(dplyr)
library(stringr)

rm(list = ls())


## Request an API key from the Census here: https://api.census.gov/data/key_signup.html
census_key <- "YOUR_KEY_HERE"

## Set the year from which you want the data 
my_vintage <- 2019


#############################################################
# To get a list of all available API's without going to Census website run the function listCensusApis()
# You need to set 3 arguments in the function: "name", "vintage", and "type"
# - The API for 2010 Decennial Census summary file data is "dec/sf1"
# - The API for one year data from the ACS is "acs1"
# - The API for three year data from the ACS is "acs3"
# - The API for five year data from the ACS is "acs5"
# - "vintage" refers to the year you want, for example vintage = 2019 will get you 2019 data
# For small geographies you'll want the 5 year acs estimates so you'll want to choose "acs5"
# A good resource for looking up census tables is Social Explorer
# In the example below I get the data for table B25065 (Aggregate Gross Rent), here's the Social Explorer entry for this table:
# - https://www.socialexplorer.com/data/ACS2010/metadata/?ds=ACS10&var=B25065001
#############################################################

available_census_vars <- listCensusMetadata(name = "acs/acs5", vintage = my_vintage, type = "variables")
dim(available_census_vars)
View(available_census_vars)


#############################################################
#Get a list of possible variables geographies
#############################################################

available_census_geos <- listCensusMetadata(name = "acs/acs5", 
                                            vintage = my_vintage, 
                                            type = "geography")
dim(available_census_geos)
View(available_census_geos)

## Note: to subset variables you can use grepl (below I grab variables related to rent as an example)
rent_variables <- available_census_vars[grepl(" RENT", available_census_vars$concept), ]
View(rent_variables)


#############################################################
# The API for metro area is " region = "metropolitan statistical area/micropolitan statistical area:*") "
# The API for county is " region = "county:*" "
# The API for tract is " region = "tract:*" "
# The API for block group is " region = "block group:*" "
# You can specify "regionin" as:
# - State:                    regionin = "state:fips"
# - State and County:         regionin = "state:fips+county:fips"
# - State, County, and Tract: regionin = "state:fips+county:fips+tract:fips"
#############################################################


rents_example_metro <- getCensus(name = "acs/acs5", 
                                 vintage = my_vintage,
                                 key = census_key,
                                 vars = c("NAME", "B25065_001E"),
                                 region = "metropolitan statistical area/micropolitan statistical area:*")
View(rents_example_metro)

## Get data for all census tracts within King County, WA
rents_example_tract <- getCensus(name = "acs/acs5", 
                                 vintage = my_vintage, 
                                 key = census_key,
                                 vars = c("NAME", "B25065_001E"),
                                 region = "tract:*",
                                 regionin = "state:53+county:033")
View(rents_example_tract)

## Get data for all census block groups within King County, WA census tract 020700
rents_example_block <- getCensus(name = "acs/acs5", 
                                 vintage = my_vintage, 
                                 key = census_key,
                                 vars = c("NAME", "B25065_001E"),
                                 region = "block group:*",
                                 regionin = "state:53+county:033")
View(rents_example_block)

# You can also get block groups within a specific census tract
rents_example_block_within_tract <- getCensus(name = "acs/acs5", 
                                 vintage = my_vintage, 
                                 key = census_key,
                                 vars = c("NAME", "B25065_001E"),
                                 region = "block group:*",
                                 regionin = "state:53+county:033+tract:020700")
View(rents_example_block_within_tract)



