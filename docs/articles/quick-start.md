# Quick start

``` r

library(highdir)

# Create dataset
df <- data.frame(
  age  = rep(c("18-24", "25-34", "35-44", "45-54"), each = 2),
  sex  = rep(c("Male", "Female"), 4),
  pct  = c(42, 38, 55, 61, 48, 52, 60, 57),
  n    = c(120, 115, 200, 210, 180, 175, 160, 155)
)

# Figure data specification 
spec <- hd_spec(df, x = "age", y = "pct", group = "sex", n = "n")

# Specify figure presentation
opts <- hd_opts(title = "Tall om Report",
                subtitle = "Source: Example data",
                caption  = "Tall om helse",
                ylim = c(0, 80))

hd_make(spec, "column", opts)                       # highcharter (default)
hd_make(spec, "column", opts, backend = "ggplot2")  # static ggplot2
hd_make(spec, "line",   opts, smooth = TRUE)        # smooth spline
hd_make(spec, "pie",    opts)                       # pie / donut

# Disable JavaScript (for static HTML export)
hd_make(spec, "column", opts, use_js = FALSE)

# Save
hd01 <- hd_make(spec, "column")
hd_save(fig = hd01, file = "chart.html")

gg01 <- hd_make(spec, "column", backend = "ggplot2")
hd_save(fig = gg01, file = "chart.png")
```

## Geom

To list all geom features.

``` r
list_geoms()
#> [1] "arearange"  "column"     "line"       "pie"        "ranked_bar"
#> [6] "scatter"
```
