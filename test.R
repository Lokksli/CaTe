library(readr)
library(dplyr)
library(ggplot2)
library(plotly)
library(htmlwidgets)
library(jsonlite)
library(lubridate)


temp <- read.csv("uzhorod_temperature.csv") %>%
  mutate(
    date = as.POSIXct(date, format = "%Y-%m-%d %H:%M:%S")
  ) %>%
  arrange(date)


mean_month <- temp %>%
  mutate(
    month = floor_date(date, "month")
  ) %>%
  group_by(month) %>%
  summarise(
    temperature_c = mean(temperature_c, na.rm = TRUE)
  ) %>%
  rename(
    date = month
  ) 
print(min(mean_month$temperature_c))

  



