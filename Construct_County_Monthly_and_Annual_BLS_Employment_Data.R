## Code to construct county level monthly and annual BLS employment data 
## Matthew Fitzgerald

library(stringr)
library(dplyr)



## Get raw employment data from the bls
bls_county_raw <- read.delim("https://download.bls.gov/pub/time.series/la/la.data.64.County",
                             colClasses = "character")

## Remove trailing whitespace from series_id
bls_county_raw$series_id <- str_trim(bls_county_raw$series_id)

## All series_id's should be 20 characters
sum(nchar(bls_county_raw$series_id) != 20) == 0
## Should be no NA's in value
sum(is.na(bls_county_raw$value)) == 0

## Remove any trailing whitespace from value
bls_county_raw$value <- str_trim(bls_county_raw$value)

## Note that when value is missing, value = "-" (after whitespace is trimmed)
# - Therefore when converting value to numeric these values will become NA's

## Create County FIPS code column
bls_county_raw$FIPS <- str_sub(bls_county_raw$series_id, 6, 10)

## Extract data code
# - 3 is unemployment rate
# - 4 is number unemployed
# - 5 is number employed
# - 6 is total labor force 
bls_county_raw$code <- str_sub(bls_county_raw$series_id, -1)
bls_county_raw$code_name <- ifelse(bls_county_raw$code == "3", "unemployment_rate",
                                   ifelse(bls_county_raw$code == "4", "num_unemployed",
                                          ifelse(bls_county_raw$code == "5", "num_employed",
                                                 ifelse(bls_county_raw$code == "6", "total_labor_force", "CODE_ERROR"))))

## Make sure there is not an error in the data codes
nrow(filter(bls_county_raw, code_name == "CODE_ERROR")) == 0

## Create month column
bls_county_raw$month <- str_sub(bls_county_raw$period, 2, 3)


codes_vec <- c("3", "4", "5", "6")

annual_list <- list()
monthly_list <- list()

for (i in 1:length(codes_vec)){
  print(codes_vec[i])
  ## Add annual data to list
  annual_list[[i]] <- bls_county_raw %>% filter(code == codes_vec[i] & period == "M13")
  ## Rename value column to data type
  colnames(annual_list[[i]])[which(colnames(annual_list[[i]]) == "value")] <- annual_list[[i]]$code_name[1]
  ## Remove unnecessary columns
  annual_list[[i]] <- annual_list[[i]] %>% select(-series_id, -month, -footnote_codes, -code, -code_name, -period)
  ## Add monthly data to list
  monthly_list[[i]] <- bls_county_raw %>% filter(code == codes_vec[i] & period != "M13")
  ## Rename value column to data type
  colnames(monthly_list[[i]])[which(colnames(monthly_list[[i]]) == "value")] <- monthly_list[[i]]$code_name[1]
  ## Remove unnecessary columns
  monthly_list[[i]] <- monthly_list[[i]] %>% select(-series_id, -footnote_codes, -code, -code_name, -period)
}


## Combine monthly unemployment_rate, num_unemployed, num_employed, and total_labor_force into one data frame
monthly_bls_df <- Reduce(f = function(df1, df2) merge(df1, df2, by = c( "FIPS", "year", "month"), all = TRUE), monthly_list)

## Combine annual unemployment_rate, num_unemployed, num_employed, and total_labor_force into one data frame
annual_bls_df <- Reduce(f = function(df1, df2) merge(df1, df2, by = c( "FIPS", "year"), all = TRUE), annual_list)




rm(annual_list,
   bls_county_raw,
   codes_vec,
   i,
   monthly_list)

