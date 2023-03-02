# 24 Webster Ave Background Data from Census
# Load libraries
library(tidyverse)
library(tidycensus)
library(dplyr)
library(openxlsx)

# You will need a census API key. You can get one here:
# https://api.census.gov/data/key_signup.html

# Variables of interest
# To find more variables, check the census website at:
# https://api.census.gov/data/2021/acs/acs1/variables.html
# or run this line and search here:
all_census_variables <- load_variables(2021, "acs1", cache = TRUE)
view(all_census_variables)

# I started with these:
# B19013_001 = Median Household Income
# B01003_001 = Total Population
# B01002_001 = Median Age
# B25077_001 = Median Home Value
# B25064_001 = Median Gross Rent
# B25003_002 = Owner Occupied
# B25003_003 = Renter Occupied
# B25003_001 = Total Housing Units
# B25035_001 = Median Year Structure Built
# B25071_001 = Median Gross Rent as a Percentage of Household Income
# B02001_002 = White
# B02001_003 = Black or African American
# B02001_004 = American Indian and Alaska Native
# B02001_005 = Asian
# B02001_006 = Native Hawaiian and Other Pacific Islander
# B03002_001 = Hispanic or Latino

# Creating a list of variables
vars_of_interest <- c("B19013_001",
                    "B01003_001",
                    "B01002_001",
                    "B25077_001",
                    "B25064_001",
                    "B25003_002",
                    "B25003_003",
                    "B25003_001",
                    "B25035_001",
                    "B25071_001",
                    "B02001_002",
                    "B02001_003",
                    "B02001_004",
                    "B02001_005",
                    "B02001_006",
                    "B03002_012")

# Create a script to get various data from 2020 census for Block Group 351500-2
webster24 <- get_acs(geography = "block group",
                   variables = vars_of_interest,
                            state = "MA",
                            county = "Middlesex",
                            year = 2021)

webster24 <- webster24 %>%
  filter(GEOID == "250173515002")

view(webster24)

# Now we label the variables. The first way will be automatic, but sloppy.
# Look up variable names in all_census_variables and create a dataframe
# auto_variable_names <- all_census_variables %>%
#   filter(name %in% vars_of_interest) %>%
#   select(name, label, concept)
# view(auto_variable_names)

# This is a cleaner but more manual way to do it:
# Create a vector of variable names
variable_names <- c("Median Household Income",
    "Total Population",
    "Median Age",
    "Median Home Value",
    "Median Gross Rent",
    "Owner Occupied",
    "Renter Occupied",
    "Total Housing Units",
    "Median Year Structure Built",
    "Median Gross Rent as a Percentage of Household Income",
    "White",
    "Black or African American",
    "American Indian and Alaska Native",
    "Asian",
    "Native Hawaiian and Other Pacific Islander",
    "Hispanic or Latino")

# Add column to names vector with census codes
variable_names <- cbind(variable_names, vars_of_interest)

# Convert variable names vector to data frame
variable_names <- as.data.frame(variable_names)

# Rename columns in varaible names vector
names(variable_names) <- c("name", "variable")
view(variable_names)

# Change this to auto if you used that method. If not:
# Join variable names to webster24 by GEOID
webster24 <- left_join(webster24, variable_names, by = "variable")
view(webster24)

# Select name, estimate, and MOE columns
webster24data <- webster24 %>%
  select(name, estimate, moe)
view(webster24data)

# Export
write.xlsx(webster24data, "24 Webster Ave Background Data.xlsx")
