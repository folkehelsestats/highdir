# highdir: Backend-Agnostic Figure Builder for Helsedirektoratet

**highdir** provides a unified API for building interactive figures with
**highcharter** or static figures with **ggplot2**. A figure is
described once as a data-mapping object
([hd_spec](https://github.com/folkehelsestats/highdir/reference/hd_spec.md))
and an optional presentation object
([hd_opts](https://github.com/folkehelsestats/highdir/reference/hd_opts.md)),
then rendered to either backend without changing the calling code.

### Core workflow

    library(highdir)

    # ── 1. Sample data ────────────────────────────────────────────────────────
    df <- data.frame(
      age = rep(c("18-24", "25-34", "35-44", "45-54"), each = 2),
      sex = rep(c("Male", "Female"), 4),
      pct = c(42, 38, 55, 61, 48, 52, 60, 57),
      n   = c(120, 115, 200, 210, 180, 175, 160, 155)
    )

    # ── 2. Describe the data mapping (once) ──────────────────────────────────
    spec <- hd_spec(df, x = "age", y = "pct", group = "sex", n = "n",
                     ylab = "Percentage (%)")

    # ── 3. Describe the presentation (reusable across specs) ─────────────────
    opts <- hd_opts(title    = "Health survey results",
                     subtitle = "Source: FHI 2024",
                     caption  = "Tall om helse",
                     ylim     = c(0, 80))

    # ── 4. Render — swap backend without touching spec or opts ────────────────
    hd_make(spec, "column", opts)                        # interactive HC
    hd_make(spec, "column", opts, backend = "ggplot2")   # static ggplot2
    hd_make(spec, "line",   opts, smooth = TRUE)         # HC spline
    hd_make(spec, "line",   opts, backend = "ggplot2")   # gg line
    hd_make(spec, "scatter")                             # HC scatter

    # Donut chart
    hd_make(pie_spec, "pie", pie_opts, inner_size = "50%")

    # ── 5. Arearange (confidence intervals) ──────────────────────────────────
    df2   <- cbind(df, lo = df$pct - 5, hi = df$pct + 5)
    spec2 <- hd_spec(df2, "age", "pct", group = "sex")
    hd_make(spec2, "arearange", opts, ymin = "lo", ymax = "hi")

    # ── 6. Save to disk ───────────────────────────────────────────────────────
    hd_save(hd_make(spec, "column", opts),               "chart.html")
    hd_save(hd_make(spec, "column", opts, backend="ggplot2"), "chart.png")

    # ── 7. Session-wide styling ───────────────────────────────────────────────
    hd_set_theme(hc_theme = "economist",
                 colors   = c("#025169","#7C145C","#C68803"))

    # ── 8. Launch the Shiny GUI ───────────────────────────────────────────────
    hd_app()

### Key functions

|  |  |
|----|----|
| Function | Purpose |
| [`hd_spec()`](https://github.com/folkehelsestats/highdir/reference/hd_spec.md) | Describe data mapping (x, y, group, n, labels) |
| [`hd_opts()`](https://github.com/folkehelsestats/highdir/reference/hd_opts.md) | Describe presentation (title, ylim, colours, theme) |
| [`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md) | Render spec + opts → highchart or ggplot |
| [`hd_save()`](https://github.com/folkehelsestats/highdir/reference/hd_save.md) | Export to HTML / JSON / PNG / SVG / PDF |
| [`hd_set_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_set_theme.md) | Session-wide colour / font / theme defaults |
| [`hd_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_theme.md) | Build a highcharter theme object directly |
| [`hd_add_js()`](https://github.com/folkehelsestats/highdir/reference/hd_add_js.md) | Inject custom JS into a highchart |
| [`register_geom()`](https://github.com/folkehelsestats/highdir/reference/register_geom.md) | Add a custom geometry |
| [`register_backend()`](https://github.com/folkehelsestats/highdir/reference/register_backend.md) | Add a custom rendering backend |
| [`register_palette()`](https://github.com/folkehelsestats/highdir/reference/register_palette.md) | Add a named colour palette |
| [`list_geoms()`](https://github.com/folkehelsestats/highdir/reference/list_geoms.md) | Show available geometries |
| [`list_backends()`](https://github.com/folkehelsestats/highdir/reference/list_backends.md) | Show available backends |
| [`list_palettes()`](https://github.com/folkehelsestats/highdir/reference/list_palettes.md) | Show available palettes |
| [`hd_app()`](https://github.com/folkehelsestats/highdir/reference/hd_app.md) | Launch the Shiny GUI |

## See also

Useful links:

- <https://folkehelsestats.github.io/highdir/>

- <https://github.com/folkehelsestats/highdir>

- Report bugs at <https://github.com/folkehelsestats/highdir/issues>

## Author

**Maintainer**: Yusman Kamaleri <ybkamaleri@gmail.com>
([ORCID](https://orcid.org/0000-0001-5014-3665))
