# Accessibility: writing descriptions for figures

## Why accessibility descriptions matter

A chart communicates a trend, a comparison, or a distribution. For a
sighted user that communication happens visually. For a user with a
visual impairment, who relies on a screen reader, or who accesses a
report through assistive technology, the chart is silent unless the
author provides an alternative text description.

The `description` argument in
[`hd_opts()`](https://github.com/folkehelsestats/highdir/reference/hd_opts.md)
is the single place to write that alternative text. It is **invisible to
sighted users** ie. it does not appear on the figure, but it is
announced by screen readers and embedded in the output file in a
machine-readable way.

This is distinct from `caption`, which is a visible footnote (source
citations, caveats) shown below the chart:

``` r
library(highdir)

opts <- hd_opts(
  title       = "Alcohol consumption over time",
  subtitle    = "Source: Norwegian Directorate of Health",

  # Visible below the chart — for citations and footnotes
  caption     = "Data: Hdir annual report 2023. Adjusted for population age.",

  # Read by screen readers only — describes what the chart shows
  description = paste(
    "Line chart showing adjusted mean alcohol consumption in Norway from",
    "2010 to 2023. Consumption peaked at 7.3 litres per capita in 2014 and",
    "declined steadily to 5.3 litres by 2023."
  )
)
```

------------------------------------------------------------------------

## Example data

The examples below use the built-in alcohol consumption datasets.
`hd_data1` contains a single time series with 95 % confidence interval
bounds; `hd_data2` adds a `kjonn` grouping column:

``` r
library(highdir)

# Single series — annual adjusted mean with 95% CI
alcohol <- highdir::alco1   # columns: year, adj_mean, lower_95CI, upper_95CI

# Grouped by sex
alcohol2 <- highdir::alco2  # same columns + kjonn
```

------------------------------------------------------------------------

## Highcharter: how description is delivered

When `description` is set and the backend is `"highcharter"`, highdir
calls:

``` r
highdir:::.hd_accessibility(chart, description = opts$description)
```

This embeds the text in the Highcharts widget configuration. The
accessibility module, loaded automatically by highdir, injects it as an
`aria-label` attribute on the SVG container. When a screen reader user
tabs to or clicks the chart, the browser announces the description
before reading the interactive series data.

The accessibility module also provides keyboard navigation, ARIA roles
for series and data points, and a data table view. Setting `description`
enhances all of these and it gives the user orientation before they
explore the chart interactively.

``` r
spec_line <- hd_spec(alcohol,
                     x    = "year",
                     y    = "adj_mean")

opts_line <- hd_opts(
  title       = "Alcohol consumption in Norway",
  subtitle    = "Source: Norwegian Directorate of Health",
  ylab        = "Litres per capita",
  ylim        = c(0, 40),
  description = paste(
    "Line chart showing adjusted mean alcohol consumption per capita in",
    "Norway from 2010 to 2023.",
    "Consumption peaked at approximately 7.3 litres in 2014 and declined",
    "to 5.3 litres by 2023, a reduction of 27 percent."
  )
)

# The description is embedded in the widget — invisible in the browser
# but announced by screen readers
# ------------------------------------------------------------------------------
# Layered approach
hd(spec_line) +
  hd_geom_line() +
  opts_line
#> Registered S3 method overwritten by 'quantmod':
#>   method            from
#>   as.zoo.data.frame zoo

# Declarative approach
hd_make(spec_line, "line", opts_line)
```

For grouped data, describe the comparison explicitly ie. which group is
higher, and whether the gap widens or narrows over time:

``` r
spec_line2 <- hd_spec(alcohol2,
                      x     = "year",
                      y     = "adj_mean",
                      group = "kjonn")

opts_line2 <- hd_opts(
  title       = "Alcohol consumption by sex",
  subtitle    = "Source: Norwegian Directorate of Health",
  ylab        = "Litres per capita",
  ylim        = c(0, 50),
  description = paste(
    "Line chart comparing adjusted mean alcohol consumption per capita",
    "between men and women in Norway, 2010 to 2023.",
    "Men consistently drink more than women throughout the period.",
    "Both groups show a declining trend from 2014 onwards."
  )
)

hd_make(spec_line2, "line", opts_line2)
```

``` r
opts_ar <- hd_opts(
  title       = "Alcohol consumption with 95% confidence interval",
  subtitle    = "Source: Norwegian Directorate of Health",
  ylab        = "Litres per capita",
  ylim        = c(0, 40),
  description = paste(
    "Area range chart showing adjusted mean alcohol consumption in Norway",
    "with 95 percent confidence intervals, 2010 to 2023.",
    "The shaded band represents uncertainty around the estimate.",
    "The interval is narrowest in the most recent years."
  )
)

# Layered approach
hd(spec_line) +
  hd_geom_arearange(ymin = "lower_95CI", ymax = "upper_95CI") +
  opts_ar

# Declarative approach
hd_make(spec_line, "arearange", opts_ar,
        ymin = "lower_95CI", ymax = "upper_95CI")
```

------------------------------------------------------------------------

## Saving to HTML and JSON: what is preserved

### HTML (`hd_save(fig, "file.html")`)

[`hd_save()`](https://github.com/folkehelsestats/highdir/reference/hd_save.md)
calls
[`htmlwidgets::saveWidget()`](https://rdrr.io/pkg/htmlwidgets/man/saveWidget.html)
internally. The saved HTML file is a complete self-contained Highcharts
widget with all JavaScript, CSS, and configuration embedded. The
`description` you set in
[`hd_opts()`](https://github.com/folkehelsestats/highdir/reference/hd_opts.md)
is part of the Highcharts configuration object, which is serialised into
the file. **The accessibility description is preserved automatically** —
no extra steps are needed.

When the HTML file is opened in a browser, the accessibility module
reads the embedded description and attaches it as an `aria-label` to the
chart container. A screen reader will announce the description when the
user tabs to the chart.

``` r
hc_fig <- hd_make(spec_line, "line", opts_line)

# Description is embedded — the saved HTML file is fully accessible
hd_save(hc_fig, "alcohol_line.html")

# selfcontained = TRUE (the default) embeds all JS/CSS so the file works
# without an internet connection — recommended for sharing
hd_save(hc_fig, "alcohol_line.html", selfcontained = TRUE)
```

### JSON (`hd_save(fig, "file.json")`)

[`hd_save()`](https://github.com/folkehelsestats/highdir/reference/hd_save.md)
writes the Highcharts configuration object (`hc$x$hc_opts`) as a JSON
file. The `accessibility` key including your `description` is part of
that configuration object and is therefore **included in the JSON
output**.

``` r
# The JSON file contains:
# {
#   "title": { "text": "Alcohol consumption in Norway" },
#   "accessibility": {
#     "description": "Line chart showing adjusted mean alcohol..."
#   },
#   ...
# }
hd_save(hc_fig, "alcohol_line.json")
```

If you are passing this JSON to a JavaScript application that
initialises Highcharts manually, the `accessibility` configuration is
already present. You only need to ensure the Highcharts accessibility
module is loaded on the page:

``` html
<!-- Load Highcharts and the accessibility module in your HTML page -->
<script src="https://code.highcharts.com/highcharts.js"></script>
<script src="https://code.highcharts.com/modules/accessibility.js"></script>
```

------------------------------------------------------------------------

## ggplot2 — which output formats carry the description

The description is set via `ggplot2::labs(alt = ...)` (available since
ggplot2 3.3.0). Whether it reaches end users depends entirely on the
**output format**:

| Output format | Description included? | How |
|:---|:---|:---|
| **SVG** via `hd_save(fig, "file.svg")` | ✅ Yes | Written as `<desc>` element inside the SVG |
| **R Markdown / Quarto** | ✅ Yes | Use chunk option `fig.alt` *or* set `description` in [`hd_opts()`](https://github.com/folkehelsestats/highdir/reference/hd_opts.md) — both are picked up by knitr |
| **PNG** via `hd_save(fig, "file.png")` | ❌ No | Raster images have no metadata layer; alt text cannot be embedded |
| **PDF** via `hd_save(fig, "file.pdf")` | ❌ No | PDF supports accessibility tags but ggplot2’s PDF device does not write them |
| **Interactive print in RStudio** | ❌ No | The plot viewer renders visually only |

The SVG format is therefore the recommended output for ggplot2 figures
in accessible web documents. When embedding a figure in an HTML page,
the SVG’s `<desc>` element is read by screen readers as the alternative
description of the image.

``` r
spec_line <- hd_spec(alcohol,
                     x    = "year",
                     y    = "adj_mean",
                     ylab = "Litres per capita")

opts_gg <- hd_opts(
  title       = "Alcohol consumption in Norway",
  subtitle    = "Source: Norwegian Directorate of Health",
  ylab        = "Litres per capita",
  ylim        = c(0, 10),
  description = paste(
    "Line chart showing adjusted mean alcohol consumption per capita in",
    "Norway from 2010 to 2023.",
    "Consumption peaked at approximately 7.3 litres in 2014 and has",
    "declined steadily since."
  )
)

gg_fig <- hd_make(spec_line, "line", opts_gg, backend = "ggplot2")

# SVG preserves the description as a <desc> element — recommended
hd_save(gg_fig, "alcohol_line.svg")

# PNG does not carry alt text — only use for contexts where accessibility
# is not required or where the alt text is set separately in the HTML
hd_save(gg_fig, "alcohol_line.png")
```

In R Markdown and Quarto, you can also set the alt text at the chunk
level using `fig.alt`. When both `fig.alt` and `description` are set,
`fig.alt` takes precedence in the rendered HTML output:

```` markdown
``` r
hd_make(spec_line, "line", opts_gg, backend = "ggplot2")
```
````

For highcharter figures in R Markdown, knitr renders the widget as an
inline HTML frame. The `aria-label` set by highdir is preserved inside
the iframe, so screen readers will still find it:

```` markdown
``` r
hd_make(spec_line, "line", opts_line)
```
````

------------------------------------------------------------------------

## Writing good descriptions

A good accessibility description answers three questions:

1.  **What type of chart is it?** : “Line chart”, “Bar chart”, “Area
    range chart”
2.  **What does it show?** : the variable, the time period or
    categories, the grouping
3.  **What is the key finding?** : the main trend, peak, comparison, or
    conclusion

Keep descriptions to one or two sentences. Avoid repeating the title
verbatim ie. the screen reader will have already announced the title.
Mention specific values for the most important data points.

``` r
# Too vague — does not help a non-sighted user understand the finding
opts_vague <- hd_opts(
  title       = "Alcohol consumption",
  description = "A chart about alcohol."   # unhelpful
)

# Too long — screen readers become tedious to listen to
opts_too_long <- hd_opts(
  title       = "Alcohol consumption",
  description = paste(
    "This chart shows data from the Norwegian Directorate of Health about",
    "alcohol consumption measured in litres per capita per year adjusted for",
    "the age distribution of the population from the year 2010 through 2023",
    "for the total population of Norway showing an increase from 6.2 litres",
    "in 2010 to a peak of 7.3 litres in 2014 followed by a sustained",
    "reduction to 5.3 litres in the year 2023."   # too long
  )
)

# Well-written — chart type, subject, key finding, specific values
opts_good <- hd_opts(
  title       = "Alcohol consumption in Norway",
  subtitle    = "Source: Norwegian Directorate of Health",
  ylab        = "Litres per capita",
  description = paste(
    "Line chart of adjusted per capita alcohol consumption in Norway,",
    "2010 to 2023. Consumption peaked at 7.3 litres in 2014 and fell to",
    "5.3 litres by 2023."
  )
)

hd_make(spec_line, "line", opts_good)
hd_make(spec_line, "line", opts_good, backend = "ggplot2")
```

For grouped charts, name the groups and describe the relationship
between them:

``` r
opts_grouped <- hd_opts(
  title       = "Alcohol consumption by sex",
  subtitle    = "Source: Norwegian Directorate of Health",
  ylab        = "Litres per capita",
  description = paste(
    "Line chart comparing alcohol consumption between men and women in",
    "Norway, 2010 to 2023. Men consume approximately twice as much as women",
    "throughout the period. Both groups show a declining trend after 2014."
  )
)

hd_make(spec_line2, "line", opts_grouped)
hd_make(spec_line2, "line", opts_grouped, backend = "ggplot2")
```
