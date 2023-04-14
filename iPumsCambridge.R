library(tidyverse)
library(dplyr)
library(readxl)
library(openxlsx)

# Cambridge PUMA is 506
all_data <- read.csv("usa_00002.csv") %>% filter(PUMA == 506) 

# Remove unnecessary columns
all_data <- all_data %>% select(-c(PUMA, SERIAL, CBSERIAL, STATEFIP, COUNTYFIP,
                                   STRATA, GQ))

# Separate most recent data 
data_2021 <- all_data %>% filter(YEAR == 2021)

# Set all owncosts of 99999 to NA
data_2021 <- data_2021 %>% 
  mutate(OWNCOST = ifelse(OWNCOST == 99999, NA, OWNCOST))

# Create a dummy for if the household is cost-burdened
data_2021 <- data_2021 %>% 
  mutate(cost_burdened = ifelse((OWNCOST*12)/HHINCOME > 0.3, 1, 0))

# Portion of homeowners cost burdened
data_2021 %>% summarise(cost_burdened = mean(cost_burdened, na.rm = TRUE))

# Same calculation for elderly (>60) only
data_2021 %>% filter(AGE > 60) %>% 
  summarise(cost_burdened = mean(cost_burdened, na.rm = TRUE))

# Portion who are homeowners
data_2021 %>% summarise(n = n())
data_2021 %>% filter(AGE > 60) %>% summarise(n = n())
data_2021 %>% filter(AGE > 60 & OWNERSHP == 1) %>% summarise(n = n())
data_2021 %>% filter(AGE > 60 & OWNERSHP == 1) %>%
  summarise(cost_burdened = mean(cost_burdened, na.rm = TRUE))

# Portion with mobility issues
data_2021 %>% filter(AGE > 60 & DIFFMOB == 2) %>% summarise(n = n())
data_2021 %>% filter(AGE > 60 & DIFFMOB == 2 & OWNERSHP == 1) %>% 
  summarise(n = n())
data_2021 %>% 
  filter(AGE > 60 & DIFFMOB == 2 & OWNERSHP == 1 & cost_burdened == 0) %>% 
  summarise(n = n())

# Portion in poverty
data_2021 %>% filter(AGE > 60 & OWNERSHP == 1 & POVERTY <= 100) %>%
  summarise(n = n())

# Back to full dataset. Clean out cost column
all_data <- all_data %>% 
  mutate(OWNCOST = ifelse(OWNCOST == 99999, NA, OWNCOST))

# Find average cost for each year
all_data %>% 
  group_by(YEAR) %>% 
  summarise(average_cost = mean(OWNCOST, na.rm = TRUE))
