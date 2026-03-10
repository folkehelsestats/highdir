# start-use

## Quick start

``` r

library(highdir)

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
#> [1] "arearange"  "column"     "line"       "map"        "pie"       
#> [6] "ranked_bar" "scatter"
```

### Specification

There are 4 types specification in highdir and there are:

- [`hd_spec()`](https://github.com/folkehelsestats/highdir/reference/hd_spec.md) -
  for data specification
- [`hd_opts()`](https://github.com/folkehelsestats/highdir/reference/hd_opts.md) -
  for presentation specification or options that can be applicable to
  multiple geoms
- `required specification` - the arguments that must be specified based
  on geom type
- `optional specification` - other optional specification depending on
  the selected geom types

To see the required and optionals arguments:

``` r
geom_args("line") #args in geom line
geom_args("arearange")

# or
highdir:::get_geom("ranked_bar")$optional_args
highdir:::get_geom("arearange")$required_args
```

------------------------------------------------------------------------

## Theming

``` r
# Set package-wide defaults for the session
hd_set_theme(
  hc_theme = "helsedirektoratet",
  colors   = c("#025169", "#7C145C", "#C68803"),
  font     = "Source Sans Pro"
)

# All subsequent hd_make() calls use these settings automatically
hd_make(spec, "column")
```

------------------------------------------------------------------------

## JavaScript injection

``` r
fig <- hd_make(spec, "column")

# Inline JS
fig <- hd_add_js(fig, code = "console.log('chart loaded');")

# From a .js file
fig <- hd_add_js(fig, file = "path/to/my-plugin.js")

# From a bundled plugin (inst/js/<name>.js)
fig <- hd_add_js(fig, plugin = "my-plugin")
```
