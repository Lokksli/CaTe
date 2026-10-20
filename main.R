library(readr)
library(dplyr)
library(ggplot2)
library(plotly)
library(htmlwidgets)
library(jsonlite)

args <- commandArgs(trailingOnly = TRUE)
mode       <- if (length(args) > 0) args[1] else "raw"
start_date <- if (length(args) > 1) as.numeric(args[2])else NULL
end_date   <- if (length(args) > 2) as.numeric(args[3]) else NULL

print(paste("Mode:", mode))

temp <- read.csv("uzhorod_temperature.csv") %>%
  mutate(
    date = as.POSIXct(date, format = "%Y-%m-%d %H:%M:%S")
  ) %>%
  arrange(date)

print(range(temp$date))

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

year_frame <- function(start_year, end_year, temp) {
  start <- as.Date(paste0(start_year, "-01-01"))
  end   <- as.Date(paste0(end_year, "-12-31"))
  
  temp %>%
    filter(
      as.Date(date) >= start,
      as.Date(date) <= end
    )
}

if (!is.null(start_date) && !is.null(end_date)) {
  plot_data <- year_frame(start_date, end_date, plot_data)
}

p <- ggplot(
  plot_data,
  aes(
    x = date,
    y = temperature_c
  )
) +
  geom_line(
    color = "#2C7FB8",
    linewidth = 0.7
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



fig <- ggplotly(p) %>%
  layout(
    autosize = TRUE
  )
saveWidget(
  fig,
  "templates/temperature.html",
  selfcontained = FALSE
)

raw_range <- if (!is.null(start_date) && !is.null(end_date)) {
  year_frame(start_date, end_date, temp)
} else {
  temp
}

i_max <- which.max(raw_range$temperature_c)
i_min <- which.min(raw_range$temperature_c)

stats <- list(
  highest      = raw_range$temperature_c[i_max],
  highest_date = format(raw_range$date[i_max], "%Y-%m-%d %H:%M"),
  lowest       = raw_range$temperature_c[i_min],
  lowest_date  = format(raw_range$date[i_min], "%Y-%m-%d %H:%M")
)

write(toJSON(stats, auto_unbox = TRUE), "templates/stats.json")
