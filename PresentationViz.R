library(tidycensus)
options(tigris_use_cache = TRUE)
library(dplyr)
library(tidyverse)
library(ggplot2)

# Get list of block groups in Cambridge
geoids <- read.csv("Camb_GEOIDS.csv") %>% select(GEOID)

# Example: get population
camb_pop <- get_acs(
  geography = "block group", 
  variables = "B01001_001",
  state = "MA",
  county = "Middlesex",
  year = 2021,
  geometry = TRUE
) %>% filter(GEOID %in% geoids$GEOID)

plot(camb_pop["estimate"])

# Variables of interest:
# B25064_001 - Median gross rent
# B25071_001 - Median gross rent as a percentage of income
# Rent burdened (30%+ income spent on rent)
rent_burdened <- c(
  "B25070_007",
  "B25070_008",
  "B25070_009",
  "B25070_010"
)

# Gross rent
camb_rent_gross <- get_acs(
  geography = "block group", 
  variables = "B25064_001",
  state = "MA",
  county = "Middlesex",
  year = 2021,
  geometry = TRUE
) %>% filter(GEOID %in% geoids$GEOID)

plot(camb_rent_gross["estimate"])

# Rent as pct income
camb_rent_pct <- get_acs(
  geography = "block group", 
  variables = "B25071_001",
  state = "MA",
  county = "Middlesex",
  year = 2021,
  geometry = TRUE
) %>% filter(GEOID %in% geoids$GEOID)

plot(camb_rent_pct["estimate"])

# Rent burdened
camb_rent_burden <- get_acs(
  geography = "block group", 
  variables = rent_burdened,
  state = "MA",
  county = "Middlesex",
  year = 2021,
  geometry = TRUE
) %>% filter(GEOID %in% geoids$GEOID) %>% 
  group_by(GEOID) %>% 
  summarise(estimate = sum(estimate))

plot(camb_rent_burden["estimate"])

# GGplot examples
# 1
ggplot(data = camb_rent_burden, aes(fill = estimate)) + 
  geom_sf() + 
  labs(title = "Rent Burden in Cambridge",
       caption = "Data source: 2021 5-year ACS, US Census Bureau",
       fill = "ACS estimate") + 
  theme_void()
# 2
ggplot(data = camb_rent_burden, aes(fill = estimate)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "RdPu", 
                       direction = 1) + 
  labs(title = "Rent Burden in Cambridge",
       caption = "Data source: 2021 5-year ACS, US Census Bureau",
       fill = "Burdened Households") + 
  theme_void() 
# 3
ggplot(data = camb_rent_burden, aes(fill = estimate)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "RdPu", 
                       direction = 1) + 
  labs(title = "Rent Burden in Cambridge",
       caption = "Data source: 2021 5-year ACS, US Census Bureau",
       fill = "Burdened Households") 

