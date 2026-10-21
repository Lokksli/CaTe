library(readr)
library(dplyr)
library(ggplot2)
library(plotly)
library(htmlwidgets)
library(jsonlite)
library(lubridate)

# Collecting command line arguments
args <- commandArgs(trailingOnly = TRUE)
mode       <- if (length(args) > 0) args[1] else "raw"
start_date <- if (length(args) > 1) as.numeric(args[2])else NULL
end_date   <- if (length(args) > 2) as.numeric(args[3]) else NULL

print(paste("Mode:", mode))

# Reading temp csv file
temp <- read.csv("uzhorod_temperature.csv") %>%
  mutate(
    date = as.POSIXct(date, format = "%Y-%m-%d %H:%M:%S")
  ) %>%
  arrange(date)

print(range(temp$date))

# Checking if mode is daily
if (mode == "daily") {
  plot_data <- temp %>%
    mutate(
      day = as.Date(date)
    ) %>%
    group_by(day) %>%
    summarise(
      temperature_c = mean(
        temperature_c,
        na.rm = TRUE
      )
    ) %>%
    rename(
      date = day
    )
} else {
  plot_data <- temp
}


year_frame_comparison <- function(start_year, end_year, temp) {
  start_data <- temp %>%
    filter(year(date) == start_year)
  
  end_data <- temp %>%
    filter(year(date) == end_year)
  
  list(start = start_data, end = end_data)
}

result <- year_frame_comparison(start_date, end_date, temp)

start_year_result <- result$start
end_year_result <- result$end

plot_data_start <- start_year_result
plot_data_end <- end_year_result

p_start <- ggplot(
  plot_data_start,
  aes(
    x = date,
    y = temperature_c
  )
) +
  geom_line(
    color = "#2C7FB8",
    linewidth = 0.2
  ) +
  labs(
    title = if (mode == "daily") {
      "Uzhhorod Daily Average Temperature"
    } else {
      "Uzhhorod Temperature Over Time"
    },
    x = "Date",
    y = "Temperature (°C)"
  ) +
  theme_minimal()

p_end <- ggplot(
  plot_data_end,
  aes(
    x = date,
    y = temperature_c
  )
) +
  geom_line(
    color = "#2C7FB8",
    linewidth = 0.2
  ) +
  labs(
    title = if (mode == "daily") {
      "Uzhhorod Daily Average Temperature"
    } else {
      "Uzhhorod Temperature Over Time"
    },
    x = "Date",
    y = "Temperature (°C)"
  ) +
  theme_minimal()

fig_end <- ggplotly(p_end) %>%
  layout(
    autosize = TRUE
  )

fig_start <- ggplotly(p_start) %>%
  layout(
    autosize = TRUE
  )

saveWidget(
  fig_start,
  "templates/start_year_comp.html",
  selfcontained = FALSE
)
saveWidget(
  fig_end,
  "templates/end_year_comp.html",
  selfcontained = FALSE
)



