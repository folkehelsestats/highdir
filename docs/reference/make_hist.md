# Create Interactive Highchart Graph with Categories and Groups

Creates customizable interactive graph using highcharter with support
for multiple groups, different chart types (column/line), and Norwegian
health survey styling. Includes automatic color assignment, hover
effects, and export functionality.

## Usage

``` r
make_hist(
  d,
  x,
  y,
  group,
  n = NULL,
  title = "Title is here",
  subtitle = NULL,
  yint = 10,
  ylim = NULL,
  xtitle = NULL,
  ytitle = NULL,
  flip = FALSE,
  type = "column",
  line_symbols = NULL,
  dot_size = 4,
  smooth = TRUE,
  filename = NULL,
  caption = "Tall om alkohol"
)
```

## Arguments

- d:

  data.frame or data.table. The input dataset containing the variables
  to plot.

- x:

  Unquoted variable name. The x-axis variable (categories).

- y:

  Unquoted variable name. The y-axis variable (values, typically
  percentages).

- group:

  Unquoted variable name. The grouping variable for creating multiple
  series.

- n:

  Unquoted variable name. The count variable to display in tooltips (raw
  numbers). Default is NULL (no counts shown).

- title:

  Character string. Main title for the chart.

- subtitle:

  Character string, optional. Subtitle for the chart. If NULL, defaults
  to "Kilde: Navn av kilder". Default is NULL.

- yint:

  Numeric. Interval for y-axis tick marks. Default is 10.

- ylim:

  Numeric vector of length 2, optional. Sets fixed y-axis limits as
  c(min, max). If NULL (default), y-axis limits are determined
  automatically by the data. Example: c(0, 70) sets y-axis from 0 to 70.

- xtitle:

  Character string, optional. X-axis title. If NULL (default), no title
  is shown.

- ytitle:

  Character string, optional. Y-axis title. If NULL (default), no title
  is shown.

- flip:

  Logical. Whether to flip the chart orientation (horizontal bars).
  Default is FALSE.

- type:

  Character string. Chart type, either "column" or "line". Default is
  "column".

- line_symbols:

  Character vector, optional. Symbols for line markers when type="line".
  Should match the number of groups. Available symbols: "circle",
  "square", "diamond", "triangle", "triangle-down". If NULL, uses
  different symbols for each group automatically. Default is NULL.

- dot_size:

  Numeric. Size (radius in pixels) of the markers/dots for line charts.
  Only applies when type="line". Default is 4.

- smooth:

  Logical. Whether to create smooth spline curves for line charts. When
  TRUE, uses "spline" type for curved lines between points. When FALSE,
  uses straight line segments. Only applies when type="line". Default is
  TRUE.

- filename:

  Character string. Base filename for exported charts (without
  extension).

- caption:

  Character string. Caption text displayed below the chart.

## Value

A highchart object that can be displayed or further customized.

## Details

The function automatically handles color assignment based on the number
of groups:

- 2 groups: Custom teal and purple palette

- 3-7 groups: Extended custom palette with good contrast

- 8+ groups: Falls back to viridis color scale

For line charts, different symbols are automatically assigned to each
group to improve distinguishability, especially important for
accessibility and black-and-white printing.

The chart includes several interactive features:

- Hover effects with category highlighting

- Detailed tooltips showing both counts and percentages

- Export functionality (PNG, JPEG, PDF, SVG, CSV, Excel)

- Norwegian health survey styling and credits

## Color Palettes

The function uses carefully selected colors optimized for Norwegian
health surveys:

- Primary colors: Dark teal (#2E7D7B) and purple (#8A2952)

- Extended palette includes complementary blues, oranges, greens, and
  earth tones

- All colors meet accessibility contrast requirements

## Line Chart Symbols

When using type="line", the function automatically assigns different
symbols to each group in this order:

1.  circle

2.  square

3.  diamond

4.  triangle

5.  triangle-down

For more than 5 groups, symbols will cycle through the available
options.

## Smooth Lines

When smooth=TRUE and type="line", the function uses spline interpolation
to create curved lines between data points. This creates a more visually
appealing trend visualization but may not accurately represent the exact
path between measured data points. Use with caution when precise data
representation is critical.

## See also

[`hchart`](https://jkunst.com/highcharter/reference/hchart.html) for the
underlying charting function.
[`hc_add_series`](https://jkunst.com/highcharter/reference/hc_add_series.html)
for adding series to charts.
[`viridis`](https://sjmgarnier.github.io/viridisLite/reference/viridis.html)
for the fallback color palette.

## Examples

``` r
if (FALSE) { # \dontrun{
library(highcharter)
library(dplyr)

# Sample data
survey_data <- data.frame(
  age_group = rep(c("18-24", "25-34", "35-44", "45-54"), each = 3),
  gender = rep(c("Male", "Female", "Other"), 4),
  percentage = runif(12, 10, 80),
  count = sample(50:200, 12)
)

# Basic column chart
make_hist(survey_data, age_group, percentage, gender, count,
          title = "Survey Results by Age and Gender")

# Chart with fixed y-axis scale
make_hist(survey_data, age_group, percentage, gender, count,
          title = "Fixed Y-axis Scale",
          ylim = c(0, 70))

# Smooth line chart with custom symbols and fixed scale
make_hist(survey_data, age_group, percentage, gender, count,
          title = "Smooth Trend Analysis",
          type = "line",
          smooth = TRUE,
          ylim = c(0, 100),
          line_symbols = c("circle", "square", "diamond"))

# Regular (angular) line chart
make_hist(survey_data, age_group, percentage, gender, count,
          title = "Angular Line Chart",
          type = "line",
          smooth = FALSE)

# Horizontal bar chart with fixed scale
make_hist(survey_data, age_group, percentage, gender, count,
          title = "Horizontal View",
          flip = TRUE,
          ylim = c(0, 50))

# Custom y-axis intervals with fixed scale
make_hist(survey_data, age_group, percentage, gender, count,
          title = "Fine-grained Y-axis",
          yint = 5,
          ylim = c(0, 60))
} # }
```
