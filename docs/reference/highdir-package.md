# highdir: Backend-Agnostic Figure Builder

`highdir` provides a unified API for building interactive figures with
**highcharter** or static figures with **ggplot2**. A figure is
described once as a
[fig_spec](https://github.com/folkehelsestats/highdir/reference/fig_spec.md)
object and rendered to either backend without changing the calling code.

### Quick start

    library(highdir)

    df <- data.frame(
      age  = rep(c("18-24", "25-34", "35-44", "45-54"), each = 2),
      sex  = rep(c("Male", "Female"), 4),
      pct  = c(42, 38, 55, 61, 48, 52, 60, 57),
      n    = c(120, 115, 200, 210, 180, 175, 160, 155)
    )

    spec <- fig_spec(
      data     = df,
      x        = "age",
      y        = "pct",
      group    = "sex",
      n        = "n",
      title    = "Health survey results",
      subtitle = "Source: Example data",
      caption  = "Tall om helse"
    )

    # Interactive highcharter chart (default)
    make_fig(spec, "column")

    # Same spec, static ggplot2 version
    make_fig(spec, "column", backend = "ggplot2")

    # Smooth line chart without JS hover effects
    make_fig(spec, "line", smooth = TRUE, use_js = FALSE)

    # Save to disk
    hd_save(make_fig(spec, "column"), "chart.html")

### Key functions

|  |  |
|----|----|
| Function | Purpose |
| [`fig_spec()`](https://github.com/folkehelsestats/highdir/reference/fig_spec.md) | Create a backend-agnostic figure specification |
| [`make_fig()`](https://github.com/folkehelsestats/highdir/reference/make_fig.md) | Render a spec to highcharter or ggplot2 |
| [`hd_save()`](https://github.com/folkehelsestats/highdir/reference/hd_save.md) | Export a figure to HTML / JSON / PNG / SVG / PDF |
| [`hd_set_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_set_theme.md) | Set package-wide colour, font, and theme defaults |
| [`hd_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_theme.md) | Build a highcharter theme object |
| [`hd_add_js()`](https://github.com/folkehelsestats/highdir/reference/hd_add_js.md) | Inject custom JavaScript into a highchart widget |
| [`run_app()`](https://github.com/folkehelsestats/highdir/reference/run_app.md) | Launch the interactive Shiny GUI |
| [`register_geom()`](https://github.com/folkehelsestats/highdir/reference/register_geom.md) | Add a custom geometry |
| [`register_backend()`](https://github.com/folkehelsestats/highdir/reference/register_backend.md) | Add a custom rendering backend |

## See also

Useful links:

- <https://folkehelsestats.github.io/highdir>

- Report bugs at <https://github.com/folkehelsestats/highdir/issues>

## Author

**Maintainer**: Yusman Kamaleri <ybkamaleri@gmail.com>
([ORCID](https://orcid.org/0000-0001-5014-3665))
