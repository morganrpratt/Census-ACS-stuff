# This script will get various census data for Cuyahoga County
# Load libraries
library(tidycensus)
options(tigris_use_cache = TRUE)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(readxl)
library(stringr)
library(openxlsx)

# You will need a census API key. You can get one here:
# https://api.census.gov/data/key_signup.html

# Variables of interest
# To find more variables, check the census website at:
# https://api.census.gov/data/2021/acs/acs1/variables.html
# or run this line and search here:
all_census_variables <- load_variables(2021, "acs1", cache = TRUE)
view(all_census_variables)

# B07204_001 - Total pop
# B07204_002 - Same house 1 year ago
# B07204_003 - Different house
# B07204_005 - Moved within 1 year but from the same county
# B07204_007 - Movers from "elsewhere" 
# B25071_001 = Median Gross Rent as a Percentage of Household Income
# B25003_003 = Renter Occupied
# B25003_001 = Total Housing Units
# B02001_003 = Black population
# B25003_002 = Owner occupied
# B25003_003 = Renter occupied


vars <- c(
  "B07204_001",
  "B07204_002",
  "B07204_003",
  "B07204_005",
  "B07204_007",
  "B25071_001",
  "B25003_003",
  "B25003_001",
  "B02001_003",
  "B25003_002",
  "B25003_003"
)

# Get migration data from census
pop <- get_acs(geography = "tract", 
                      state = "OH",
                      county = "Cuyahoga",
                      variables = "B07204_001",
                      year = 2021)
movers <- get_acs(geography = "tract", 
                  state = "OH",
                  county = "Cuyahoga",
                  variables = "B07204_003", 
                  year = 2021)
far_movers <- get_acs(geography = "tract", 
                     state = "OH",
                     county = "Cuyahoga",
                     variables = "B07204_005", 
                     year = 2021)

# Combine all and only take estimates
migration <- pop %>% merge(movers, by = "GEOID", all.x = TRUE) %>% 
  merge(far_movers, by = "GEOID", all.x = TRUE) %>% 
  select("GEOID", "estimate.x", "estimate.y", "estimate")

# Rename columns
colnames(migration) <- c("GEOID", "Total_Pop", "Movers", "From_Outside")

# Add new column dividing for percent of residents who are new
migration <- migration %>% mutate(Percent_New = From_Outside/Total_Pop)

# Export as csv
write.csv(migration, "InMigration.csv", row.names = FALSE)


# Sending and receiving block groups within Cuyahoga
block_activity <- get_acs(geography = "tract", 
                          state = "OH",
                          county = "Cuyahoga",
                          variables = vars,
                          geometry = TRUE,
                          year = 2021)

# Exploratory visuals
mover_viz <- block_activity %>% filter(variable == "B07204_003")
within_county <- block_activity %>%  filter(variable == "B07204_005")
rent_viz <- block_activity %>% filter(variable == "B25071_001")
black_viz <- block_activity %>% filter(variable == "B02001_003")
rent_viz <- block_activity %>% filter(variable == "B25003_003")
plot(mover_viz["estimate"])
plot(within_county["estimate"])
plot(rent_viz["estimate"])
plot(black_viz["estimate"])
plot(rent_viz["estimate"])

# Unpivoted version
cuya_geom <- block_activity %>% 
  pivot_wider(id_cols = c("GEOID", "geometry"),
    names_from = "variable", values_from = "estimate")

# Create new pct renter column
cuya_geom <- cuya_geom %>% mutate(pct_renter = B25003_003/B25003_001)
plot(cuya_geom["pct_renter"])

# Export as shapefile
st_write(cuya_geom, "Cuyahoga_Migration.shp")
