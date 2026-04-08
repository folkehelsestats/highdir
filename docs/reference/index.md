# Package index

## Plot basics

All highdir plots begin with a call to
[`hd()`](https://github.com/folkehelsestats/highdir/reference/hd.md),
supplying a specification via
[`hd_spec()`](https://github.com/folkehelsestats/highdir/reference/hd_spec.md)
or defined directly in
[`hd()`](https://github.com/folkehelsestats/highdir/reference/hd.md).
You then add geoms and options with `+`. To save a plot to disk, use
[`hd_save()`](https://github.com/folkehelsestats/highdir/reference/hd_save.md).

- [`hd()`](https://github.com/folkehelsestats/highdir/reference/hd.md) :
  Initialise a Composable highdir Figure
- [`` `+`( ``*`<hd>`*`)`](https://github.com/folkehelsestats/highdir/reference/plus-.hd.md)
  : Add Layers to an hd Object
- [`hd_spec()`](https://github.com/folkehelsestats/highdir/reference/hd_spec.md)
  : Create a Figure Data Specification
- [`hd_opts()`](https://github.com/folkehelsestats/highdir/reference/hd_opts.md)
  : Create Figure Presentation Options
- [`hd_save()`](https://github.com/folkehelsestats/highdir/reference/hd_save.md)
  : Save a Figure to Disk

## Layers

### Geoms

Geoms define the visual representation of your data. Each `hd_geom_*()`
function adds a layer to the plot with a specific chart type.

- [`hd_geom_arearange()`](https://github.com/folkehelsestats/highdir/reference/hd_geom_arearange.md)
  : Add an Arearange (Confidence Band) Layer
- [`hd_geom_column()`](https://github.com/folkehelsestats/highdir/reference/hd_geom_layer.md)
  [`hd_geom_line()`](https://github.com/folkehelsestats/highdir/reference/hd_geom_layer.md)
  [`hd_geom_scatter()`](https://github.com/folkehelsestats/highdir/reference/hd_geom_layer.md)
  [`hd_geom_pie()`](https://github.com/folkehelsestats/highdir/reference/hd_geom_layer.md)
  [`hd_geom_ranked_bar()`](https://github.com/folkehelsestats/highdir/reference/hd_geom_layer.md)
  : Geometry Layers for hd Objects
- [`hd_geom_stacked_column()`](https://github.com/folkehelsestats/highdir/reference/hd_geom_stacked_column.md)
  : Stacked Column Geometry Layer

### Geom helpers

Utility functions for working with geoms — listing available types,
inspecting arguments, and registering custom geoms.

- [`list_geoms()`](https://github.com/folkehelsestats/highdir/reference/list_geoms.md)
  : List Registered Geometries
- [`geom_args()`](https://github.com/folkehelsestats/highdir/reference/geom_args.md)
  : Show Arguments for a Geometry
- [`register_geom()`](https://github.com/folkehelsestats/highdir/reference/register_geom.md)
  : Register a Geometry

## Themes

Themes control the visual style of figures. Use
[`hd_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_theme.md)
for highcharter output,
[`gg_theme()`](https://github.com/folkehelsestats/highdir/reference/gg_theme.md)
for ggplot2 output, and
[`hd_set_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_set_theme.md)
to apply a theme globally across all plots.

- [`hd_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_theme.md)
  : Build a Highcharts Theme Object
- [`gg_theme()`](https://github.com/folkehelsestats/highdir/reference/gg_theme.md)
  : Build a ggplot2 Theme Object
- [`hd_set_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_set_theme.md)
  : Set Package-Wide Style Defaults

### Palettes

Functions for working with colour palettes used across chart types.

- [`list_palettes()`](https://github.com/folkehelsestats/highdir/reference/list_palettes.md)
  : List Registered Palettes
- [`get_palette()`](https://github.com/folkehelsestats/highdir/reference/get_palette.md)
  : Retrieve a Named Palette
- [`register_palette()`](https://github.com/folkehelsestats/highdir/reference/register_palette.md)
  : Register a Named Colour Palette

## Backends

highdir is backend-agnostic and can render charts using either ggplot2
or highcharter. Use these functions to list, register, and switch
between available backends.

- [`list_backends()`](https://github.com/folkehelsestats/highdir/reference/list_backends.md)
  : List Registered Backends
- [`register_backend()`](https://github.com/folkehelsestats/highdir/reference/register_backend.md)
  : Register a Rendering Backend

## JavaScript

JavaScript utilities for extending Highcharts output. Relevant only when
using the highcharter backend.

- [`hd_add_js()`](https://github.com/folkehelsestats/highdir/reference/hd_add_js.md)
  : Inject JavaScript into a Highcharts Widget

## Applications

Helpers for building interactive Shiny applications with highdir charts.

- [`hd_app()`](https://github.com/folkehelsestats/highdir/reference/hd_app.md)
  : Launch the highdir Shiny GUI
- [`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md)
  : Build a Figure from a Specification

## Printing

Methods for rendering highdir objects in the console and interactive
sessions.

- [`print(`*`<hd>`*`)`](https://github.com/folkehelsestats/highdir/reference/print.hd.md)
  : Render an hd Object

## Datasets

Example datasets bundled with highdir, used in documentation examples
and vignettes to illustrate typical use cases.

- [`alco1`](https://github.com/folkehelsestats/highdir/reference/alco1.md)
  : Alcohol Consumption Data
- [`alco2`](https://github.com/folkehelsestats/highdir/reference/alco2.md)
  : Alcohol Consumption by Gender
