# Changelog

## highdir 0.3.1

- `DESCRIPTION` version bumped to 0.3.1.
- Can deactivate CDN modules available from
  <https://api.highcharts.com/highcharts> see
  ([\#2](https://github.com/folkehelsestats/highdir/issues/2))
- Fixed Shiny app GUI for downloading and axis labels
- Move arg `xlab` and `ylab` are related to figure presentation and not
  data specification. Move them to
  [`hd_opts()`](https://github.com/folkehelsestats/highdir/reference/hd_opts.md).
  Use `NULL` to hide axis labels.
  ([\#5](https://github.com/folkehelsestats/highdir/issues/5))

## highdir 0.3.0

- `DESCRIPTION` version bumped to 0.3.0.
- Fix
  [`hd_save()`](https://github.com/folkehelsestats/highdir/reference/hd_save.md)
  [\#3](https://github.com/folkehelsestats/highdir/issues/3)
- Renaming some functions to be consistence
- Rename function `run_app()` to
  [`hd_app()`](https://github.com/folkehelsestats/highdir/reference/hd_app.md)
- Rename function `fig_opts()` to
  [`hd_opts()`](https://github.com/folkehelsestats/highdir/reference/hd_opts.md)

## highdir 0.2.0

- Initial release with `column`, `line`, `scatter`, `arearange`
  geometries.
- `highcharter` and `ggplot2` backends.
- [`hd_save()`](https://github.com/folkehelsestats/highdir/reference/hd_save.md),
  [`hd_set_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_set_theme.md),
  [`hd_add_js()`](https://github.com/folkehelsestats/highdir/reference/hd_add_js.md).
- Shiny GUI via `run_app()`.

## highdir 0.1.0

- Implement registry to control geoms
- Just a skeleton for highdir structure with very basic functions

## highdir 0.0.0.9000

- Birth of *highdir* using existing function.
- No planned structure
- For demo purpose only to show what *highdir* can offer and its
  potential.
