# highdir 0.6.1
- The version in Github.
- Fixed #28: `hd_geom_ranked_bar()` now ensures that `aim` is treated as
  numeric, avoiding plotting failures caused by character or factor inputs.
- YAML support for additional geom arguments instead of R syntax.

# highdir 0.6.0

- Add `hd_reset_theme()` function (#21)
- Add venn diagram with `gg_venn` or `hc_venn` backends.
- New feature added to support for 
```r
hd_make(mode = "dynamic")
hd_make(mode = "static")
# or equivalent functions
hd(mode = "dynamic")
hd(mode = "static")
```

`dynamic` replaces the previous `highcharter` backend and `static` replaces the previous `ggplot2` backend.

- Renamed the `stack` argument to `facet` in `hd_geom_stacked_column()` to avoid ambiguity with R's partial matching behavior (#27).
- Improved the static implementation of `hd_geom_ranked_bar()` by switching from
  `ggplot2::geom_bar(stat = "identity")` to `ggplot2::geom_col()`. This does not
  change the visual output but clarifies that ranked bars are drawn from
  pre-computed values.

## Breaking changes
- Introduced a new mode argument with values "dynamic" and "static" to replace backend-specific values.
- The `backend` argument in `hd_make()` and `hd()` functions is now deprecated
  and will be removed in a future release.
- Existing code using: 
```r
hd_make(backend = "highcharter")
hd_make(backend = "ggplot2")
# or equivalent functions
hd(backend = "highcharter")
hd(backend = "ggplot2")
```
continues to work but produces a deprecation warning.

- The `stack` argument in `hd_geom_stacked_column()` has been renamed to `facet`. Update existing code to use `facet` instead of `stack`.


# highdir 0.5.0

- First CRAN release version.

# highdir 0.3.0

- Replace the Highdir logo to reflect its historical origin.
- Add option to hide x‑ and y‑axis labels (#13).
- Implement flip support for bar and ranked‑bar charts in the Shiny app (#12).
- Include standard ggplot2 themes.
- Implement bar figure with no space below the bars but 10% above them in ggplot2 engine.
- Deploy to shinyapps.io <https://ybkamaleri.shinyapps.io/highdir/> 
- `DESCRIPTION` version bumped to 0.3.1.
- Added option to deactivate CDN-loaded modules available from <https://api.highcharts.com/highcharts/>. (#2)
- Fixed Shiny app GUI issues related to downloading and axis labels.
- Moved `xlab` and `ylab` arguments to `hd_opts()`, since they relate to figure presentation rather than data specification. Use NULL to hide axis labels. (#5)
- Corrected ggplot2 color palette selection to follow the standard rules defined by `resolve_colors()`.
- Improved the overall visual appearance of the highdir Shiny app.
- Implemented modules in the Shiny app.
- Added a registry for optional arguments for specific geoms. List them using `geom_args()`.
- Shiny app now displays optional geom arguments along with explanatory comments.
- Add arg `percent` to `hd_opts()` to show `%` in tooltip and y-axis if `TRUE`.
- Add arg `xtick` to `hd_opts` to select column for custom x‑axis tick labels
  when these differ from the numeric x values. Note that Highcharts uses
  zero-based indexing, while R uses one-based indexing.
- `DESCRIPTION` version bumped to 0.3.0.
- Fix `hd_save()` #3
- Renaming some functions to be consistence
- Rename function `run_app()` to `hd_app()`
- Rename function `fig_opts()` to `hd_opts()`

# highdir 0.2.0

- Initial release with `column`, `line`, `scatter`, `arearange` geometries.
- `highcharter` and `ggplot2` backends.
- `hd_save()`, `hd_set_theme()`, `hd_add_js()`.
- Shiny GUI via `run_app()`.

# highdir 0.1.0

- Implement registry to control geoms
- Just a skeleton for highdir structure with very basic functions

# highdir 0.0.0.9000

- Initial prototype of highdir using existing functions.
- No defined structure.
- Created for demonstration purposes to illustrate the potential of highdir.


