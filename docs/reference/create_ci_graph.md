# Create a Highchart with Confidence Intervals

This function creates an interactive highchart displaying data over time
with 95% confidence intervals shown as a shaded area range.

## Usage

``` r
create_ci_graph(
  data,
  x_col = "year",
  y_col = "adj_enhet",
  lower_col = "lower_enhet",
  upper_col = "upper_enhet",
  ylim = NULL,
  title = NULL,
  subtitle = NULL,
  y_axis_title = NULL,
  x_axis_title = NULL,
  series_name = "Antall enheter",
  line_color = "#206276",
  caption = NULL,
  credits_text = "Helsedirektoratet",
  credits_href = "https://www.helsedirektoratet.no/",
  save = FALSE
)
```

## Arguments

- data:

  A data frame containing the data to plot.

- x_col:

  Character. Name of column in the dataset for x-axis. Default:
  `"year"`.

- y_col:

  Character. Name of column in the dataset for y-axis. Default:
  `"adj_enhet"`.

- lower_col:

  Character. Name of the lower CI column. Default: `"lower_enhet"`.

- upper_col:

  Character. Name of the upper CI column. Default: `"upper_enhet"`.

- ylim:

  Numeric vector of length 2, optional. Sets fixed y-axis limits as
  c(min, max). If NULL (default), y-axis limits are determined
  automatically by the data. Example: c(0, 70) sets y-axis from 0 to 70.

- title:

  Character. Main title for the chart.

- subtitle:

  Character. Subtitle text.

- y_axis_title:

  Character. Y-axis title.

- x_axis_title:

  Character. X-axis title.

- series_name:

  Character. Name for the main data series. Default: `"Antall enheter"`.

- line_color:

  Character. Hex color code for the line and area. Default: `"#206276"`.

- caption:

  Character. Chart caption text randered below the chart.

- credits_text:

  Character. Credits text. Default: `"Helsedirektoratet"`.

- credits_href:

  Character. URL for credits link. Default: Helsedirektoratet URL.

- save:

  Logical. Save file as a selfcontained HTML. Default: FALSE

## Value

A `highchart` object that can be rendered or further customized.

## Details

The function creates a line chart with the following features:

- Main line series showing the central values

- Shaded area range showing 95\\

- Accessibility features enabled

- Export functionality

- Shared tooltip on hover

## See also

[`highchart`](https://jkunst.com/highcharter/reference/highchart.html),
[`hc_add_series`](https://jkunst.com/highcharter/reference/hc_add_series.html)

## Examples

``` r
if (FALSE) { # \dontrun{
# Basic usage with default parameters
library(highcharter)
chart <- create_ci_graph(dtx)
chart

# Custom title and colors
chart <- create_ci_graph(
  data = dtx,
  title = "Custom Alcohol Use Chart",
  line_color = "#FF5733"
)

# Using different column names
chart <- create_ci_graph(
  data = my_data,
  x_col = "aar",
  y_col = "verdi",
  lower_col = "nedre_ci",
  upper_col = "ovre_ci"
)

# Full customization
chart <- create_ci_graph(
  data = dtx,
  title = "Alcohol Consumption Trends",
  subtitle = "Age and gender adjusted rates",
  y_axis_title = "Units of alcohol",
  x_axis_title = "Year",
  series_name = "Units",
  line_color = "#1E90FF",
  caption = "Source: Health Survey",
  credits_text = "Norwegian Directorate of Health"
)
} # }
```
