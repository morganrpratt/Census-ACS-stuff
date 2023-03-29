library(tidyverse)
library(tidycensus)
options(tigris_use_cache = TRUE)
library(dplyr)
library(readxl)
library(openxlsx)
library(ggplot2)

# Load excel sheet from directory as a dataframe
GEOIDS <- read_excel("SomerGEOs.xlsx")
geoids <- GEOIDS$GEOID20

# List of all tracts in Somerville, Massachusetts
# tracts <- c(
#   "350103",
#   "350104",
#   "350200",
#   "350300",
#   "3504001",
#   "350500",
#   "350600",
#   "350700",
#   "350800",
#   "350900",
#   "351000",
#   "351100",
#   "351203",
#   "351300",
#   "351403",
#   "351404"
# )

# Find variables of interest
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
# B03002_012 = Hispanic or Latino

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

somerville_data <- get_acs(geography = "block group",
           variables = vars_of_interest,
           state = "MA",
           county = "Middlesex",
           geometry = TRUE,
           year = 2021) %>% filter(GEOID %in% geoids)

# Pivot wider and use variable names as column names
somerville_data <- somerville_data %>% 
  pivot_wider(id_cols = c("GEOID", "geometry"),
              names_from = "variable", values_from = "estimate")

plot(somerville_data["B25003_003"]) # Substitute with valuable of interest

# Export to Excel
write.xlsx(somerville_data, 'SomerData.xlsx')
