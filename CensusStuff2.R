library(tidycensus)
library(tidyverse)
library(dplyr)
library(readxl)
library(stringr)
library(openxlsx)

# List of variables can be found here:
# variables <- load_variables(2021, "acs1", cache = TRUE)

# Load data
homeshares <- read_xlsx("Homeshares R 2.xlsx")

# Pivot by zipcodes
homeshares <- homeshares %>% 
  pivot_longer(
    cols = 3:ncol(homeshares), 
    names_to = "DROP",
    values_to = "Zip",
    values_drop_na = TRUE
  ) %>% select(-DROP)

# Variables of interest
# "B19013_001" - Median Income
# "B01003_001" - Total Population
# "B02001_002" - White Population
# "B15003_022" - Pop w/ a BA (over 25)
# "B15003_023" - Pop w/ a Masters (over 25)
# "B15003_024" - Pop w/ a Professional Degree (over 25)
# "B15003_025" - Pop w/ a Doctorate (over 25)
# "B15003_001" - Pop over 25
# "B01001_018" - Pop over 60 (all below combined)
# "B01001_019"
# "B01001_020"
# "B01001_021"
# "B01001_022"
# "B01001_023"
# "B01001_024"
# "B01001_025"
# "B01001_042"
# "B01001_043"
# "B01001_044"
# "B01001_045"
# "B01001_046"
# "B01001_047"
# "B01001_048"
# "B01001_049" - Pop over 60 (all above combined)
# "B25014_003" - Overhoused Population

vars <- c(
  "B19013_001",
  "B01003_001",
  "B02001_002",
  "B15003_022",
  "B15003_023",
  "B15003_024",
  "B15003_025",
  "B15003_001",
  "B01001_018E", 
  "B01001_019E",
  "B01001_020E",
  "B01001_021E",
  "B01001_022E",
  "B01001_023E",
  "B01001_024E",
  "B01001_025E", 
  "B01001_042E", 
  "B01001_043E",
  "B01001_044E",
  "B01001_045E",
  "B01001_046E",
  "B01001_047E",
  "B01001_048E",
  "B01001_049E",
  "B25014_003"
)

# Get ACS data for every zipcode
acs_data <- get_acs(geography = "zcta", 
                    variables = vars, 
                    year = 2021) %>% 
  filter(GEOID %in% homeshares$Zip)

# Pivot by Zip
acs_data <- acs_data %>% 
  pivot_wider(id_cols = c("GEOID", "NAME"),
              names_from = "variable", values_from = "estimate")

# Rename columns and mutate to create  variables of interest
names(acs_data)[1] <- "Zip"
names(acs_data)[3] <- "Median Income"
acs_data <- acs_data %>% mutate(
  pct_white = B02001_002/B01003_001
)
acs_data <- acs_data %>% mutate(
  pct_college = (B15003_022+B15003_023+B15003_024+B15003_025)/B15003_001
)
elders <- c("B01001_018", 
            "B01001_019",
            "B01001_020",
            "B01001_021",
            "B01001_022",
            "B01001_023",
            "B01001_024",
            "B01001_025", 
            "B01001_042", 
            "B01001_043",
            "B01001_044",
            "B01001_045",
            "B01001_046",
            "B01001_047",
            "B01001_048",
            "B01001_049")
acs_data <- acs_data %>% mutate(
  pct_elderly = rowSums(acs_data[, elders])/B01003_001
)
acs_data <- acs_data %>% mutate(
  pct_overhoused = B25014_003/B01003_001
)

# Remove excess
acs_data <- acs_data %>% select(-c(2, 4:27))

# Join with homeshares data
combined <- homeshares %>% 
  left_join(acs_data, by = "Zip")
combined <- combined %>% group_by(`Program Name`) %>% 
  summarise_all(mean, na.rm = TRUE) %>% select(-c(2,3))

# This part is janky
homeshares <- read_xlsx("Homeshares R 2.xlsx") %>% select(c(1:2))
homeshares <- homeshares %>% 
  left_join(combined, by = "Program Name")

# Export
write.xlsx(homeshares, 'Mar30.xlsx')
