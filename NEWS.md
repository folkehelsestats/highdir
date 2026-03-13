# highdir 0.3.2

- Change highdir logo for historical reason for the birth of highdir.
- Fix lab to hide y-axis and x-axis labels (#13)
- Flip figure for bar and ranked-bar in Shiny app (#12)
- Add ggplot2 standard themes

# highdir 0.3.1

- `DESCRIPTION` version bumped to 0.3.1.
- Added option to deactivate CDN-loaded modules available from <https://api.highcharts.com/highcharts>. (#2)
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


# highdir 0.3.0

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


