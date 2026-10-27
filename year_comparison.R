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
  start_data <- plot_data %>%
    filter(year(date) == start_year)
  
  end_data <- plot_data %>%
    filter(year(date) == end_year)
  
  list(start = start_data, end = end_data)
}

result <- year_frame_comparison(start_date, end_date, temp)

start_year_result <- result$start
end_year_result <- result$end

plot_data_start <- start_year_result
plot_data_end <- end_year_result


# Rounding data for displaying
plot_data_start <- plot_data_start %>%
  mutate(temperature_c = round(temperature_c, 4))

p_start <- ggplot(
  plot_data_start,
  aes(
    x = date,
    y = temperature_c
  )
) +
  geom_line(
    color = "#2C7FB8",
    linewidth = 0.4
  ) +
  labs(
    title = if (mode == "daily") {
      paste("Carpathian Daily Average Temperature ", start_date)
    } else {
      paste("Carpathian Temperature Over Time ", start_date)
    },
    x = "Date",
    y = "Temperature (°C)"
  ) +
  theme_minimal()


# Rounding data for displaying
plot_data_end <- plot_data_end %>%
  mutate(temperature_c = round(temperature_c, 4))


p_end <- ggplot(
  plot_data_end,
  aes(
    x = date,
    y = temperature_c
  )
) +
  geom_line(
    color = "#2C7FB8",
    linewidth = 0.4
  ) +
  labs(
    title = if (mode == "daily") {
      paste("Carpathian Daily Average Temperature ", end_date)
    } else {
      paste("Carpathian Temperature Over Time ", end_date)
    },
    x = "Date",
    y = "Temperature (°C)"
  ) +
  theme_minimal()


# Overlaping grpah

p <- ggplot() +
  #blue
  geom_line(data = plot_data_start %>% mutate(date_common = update(date, year = 2000)), aes(x=date_common, y=temperature_c), color = "#2C7FB8", linewidth = 0.4)+
  #red
  geom_line(data = plot_data_end %>% mutate(date_common = update(date, year = 2000)), aes(x=date_common, y=temperature_c), color = "#b83a2c", linewidth = 0.4)+
  labs(
    title = if (mode == "daily") {
      "Carpathian Daily Average Temperature"
    } else {
      "Carpathian Temperature Over Time"
    },
    x = "Date",
    y = "Temperature (°C)"
  ) +
  theme_minimal()

print(ggplotly(p))


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

raw_start <- temp %>%
  filter(year(date) == start_date)

raw_end <- temp %>%
  filter(year(date) == end_date)

raw_range <- rbind(raw_start, raw_end)


i_max <- which.max(raw_range$temperature_c)
i_min <- which.min(raw_range$temperature_c)

# Calculating mean month temperature
mean_month <- raw_range %>%
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

m_max <- which.max(mean_month$temperature_c)
m_min <- which.min(mean_month$temperature_c)


stats <- list(
  highest      = raw_range$temperature_c[i_max],
  highest_date = format(raw_range$date[i_max], "%Y-%m-%d %H:%M"),
  lowest       = raw_range$temperature_c[i_min],
  lowest_date  = format(raw_range$date[i_min], "%Y-%m-%d %H:%M"),
  hottest_month = mean_month$temperature_c[m_max],
  hottest_month_date = format(mean_month$date[m_max], "%Y-%m-%d"),
  coldest_month = mean_month$temperature_c[m_min],
  coldest_month_date = format(mean_month$date[m_min], "%Y-%m-%d")
)
write(toJSON(stats, auto_unbox = TRUE), "templates/stats_comparison.json")


