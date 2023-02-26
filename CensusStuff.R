library(tidycensus)
library(tidyverse)
library(dplyr)
library(readxl)
library(stringr)
library(openxlsx)

homeshares <- read_xlsx("R Homeshares.xlsx")
acs_data <- get_acs(geography = "zcta", variables = "B19013_001", year = 2021)

get_zip_inc <- function(zipcode) {
  # Handle character type
  zip <- str_pad(as.character(zipcode),5,"left",0)

  # Find zipcode in acs_data 
  row_index <- which(acs_data$GEOID == zip)
  
  # Return its median income
  if (length(row_index) > 0) {
    estimate <- acs_data$estimate[row_index]
    return(estimate)
  } else {
    # If no row is found, return NA
    return(NA)
  }
} 

get_zip_inc(02140) # Test for Cambridge

## Desired output for each element in Zipcodes
# mean(sapply(strsplit(homeshares$Zipcodes, " ")[[1]],get_zip_inc), na.rm = TRUE)

# Define a function to apply to each element of Zipcodes
get_mean_zip_inc <- function(zipcodes) {
  mean(sapply(strsplit(zipcodes, " ")[[1]], get_zip_inc), na.rm = TRUE)
}

# Add income column
income <- homeshares %>% 
  mutate(MeanZipInc = sapply(Zipcodes, get_mean_zip_inc))



# Repeat for ethnicity
acs_pop_data <- get_acs(geography = "zcta", 
                        variables = "B01003_001", year = 2021)
acs_white_pop <- get_acs(geography = "zcta", 
                        variables = "B02001_002", year = 2021)
get_pct_white <- function(zipcode) {
  # Handle character type
  zip <- str_pad(as.character(zipcode),5,"left",0)
  
  # Find zipcode in acs_data 
  row_index1 <- which(acs_pop_data$GEOID == zip)
  row_index2 <- which(acs_white_pop$GEOID == zip)
  
  # Return its median income
  if (length(row_index1) > 0) {
    estimate <- acs_white_pop$estimate[row_index2]/acs_pop_data$estimate[row_index2]
    return(estimate)
  } else {
    # If no row is found, return NA
    return(NA)
  }
} 

get_pct_white(02140) # Test for Cambridge

# Define a function to apply to each element of Zipcodes
get_mean_pct_white <- function(zipcodes) {
  mean(sapply(strsplit(zipcodes, " ")[[1]], get_pct_white), na.rm = TRUE)
}

inc_race <- income %>% 
  mutate(MeanPctWhite = sapply(Zipcodes, get_mean_pct_white))

# Export 2/25
write.xlsx(inc_race, 'Feb25.xlsx')



# Repeat for Bachelor's degree (B06009_005E)
acs_college <- get_acs(geography = "zcta", 
                       variables = "B06009_005E", year = 2021)



