# Package index

## Declarative API

### Primary functions

Core functions used to generate figures. See the
[examples](https://folkehelsestats.github.io/highdir/articles/examples.html)
for practical usage.

- [`hd_spec()`](https://github.com/folkehelsestats/highdir/reference/hd_spec.md)
  : Create a Figure Data Specification
- [`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md)
  : Build a Figure from a Specification

### Secondary functions

Additional optional functions that support workflows.

- [`hd_opts()`](https://github.com/folkehelsestats/highdir/reference/hd_opts.md)
  : Create Figure Presentation Options
- [`hd_save()`](https://github.com/folkehelsestats/highdir/reference/hd_save.md)
  : Save a Figure to Disk
- [`hd_app()`](https://github.com/folkehelsestats/highdir/reference/hd_app.md)
  : Launch the highdir Shiny GUI

## Layered API

### Primary functions

All highdir plots start with a call to
[`hd()`](https://github.com/folkehelsestats/highdir/reference/hd.md),
either using a specification created with
[`hd_spec()`](https://github.com/folkehelsestats/highdir/reference/hd_spec.md)
or defined directly inside
[`hd()`](https://github.com/folkehelsestats/highdir/reference/hd.md).
You then layer geoms and options using `+`. See the examples under each
geom below for concrete usage patterns.

- [`hd()`](https://github.com/folkehelsestats/highdir/reference/hd.md) :
  Initialise a Composable highdir Figure

### Secondary functions

Geom types

- [`hd_geom_arearange()`](https://github.com/folkehelsestats/highdir/reference/hd_geom_arearange.md)
  : Add an Arearange (Confidence Band) Layer
- [`hd_geom_column()`](https://github.com/folkehelsestats/highdir/reference/hd_geom_column.md)
  : Column Geometry Layer for hd Objects
- [`hd_geom_layer`](https://github.com/folkehelsestats/highdir/reference/hd_geom_layer.md)
  : Geometry Layers for hd Objects
- [`hd_geom_line()`](https://github.com/folkehelsestats/highdir/reference/hd_geom_line.md)
  : Line Geometry Layer for hd Objects
- [`hd_geom_pie()`](https://github.com/folkehelsestats/highdir/reference/hd_geom_pie.md)
  : Pie Geometry Layer for hd Objects
- [`hd_geom_ranked_bar()`](https://github.com/folkehelsestats/highdir/reference/hd_geom_ranked_bar.md)
  : Ranked bar geometry
- [`hd_geom_scatter()`](https://github.com/folkehelsestats/highdir/reference/hd_geom_scatter.md)
  : Scatter Geometry Layer for hd Objects
- [`hd_geom_stacked_column()`](https://github.com/folkehelsestats/highdir/reference/hd_geom_stacked_column.md)
  : Stacked Column Geometry Layer

## Backends

Backend engines used to build figures.

- [`list_backends()`](https://github.com/folkehelsestats/highdir/reference/list_backends.md)
  : List Registered Backends
- [`register_backend()`](https://github.com/folkehelsestats/highdir/reference/register_backend.md)
  : Register a Rendering Backend and used when loding in zzz.R file

## Themes

Theme functions defining the visual style of figures.

- [`hd_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_theme.md)
  : Build a Highcharts Theme Object
- [`gg_theme()`](https://github.com/folkehelsestats/highdir/reference/gg_theme.md)
  : Build a ggplot2 Theme Object
- [`hd_set_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_set_theme.md)
  : Set Package-Wide Style Defaults
- [`list_palettes()`](https://github.com/folkehelsestats/highdir/reference/list_palettes.md)
  : List Registered Palettes
- [`get_palette()`](https://github.com/folkehelsestats/highdir/reference/get_palette.md)
  : Retrieve a Named Palette
- [`register_palette()`](https://github.com/folkehelsestats/highdir/reference/register_palette.md)
  : Register a Named Colour Palette

## Helpers

Geometric layers and related functions used to construct figures.

- [`` `+`( ``*`<hd>`*`)`](https://github.com/folkehelsestats/highdir/reference/plus-.hd.md)
  : Add Layers to an hd Object
- [`list_geoms()`](https://github.com/folkehelsestats/highdir/reference/list_geoms.md)
  : List Registered Geometries
- [`geom_args()`](https://github.com/folkehelsestats/highdir/reference/geom_args.md)
  : Show Arguments for a Geometry
- [`register_geom()`](https://github.com/folkehelsestats/highdir/reference/register_geom.md)
  : Register a Geometry
- [`print(`*`<hd>`*`)`](https://github.com/folkehelsestats/highdir/reference/print.hd.md)
  : Render an hd Object

## JavaScript

JavaScript-related utilities (relevant for Highcharts output).

- [`hd_add_js()`](https://github.com/folkehelsestats/highdir/reference/hd_add_js.md)
  : Inject JavaScript into a Highcharts Widget

## Datasets

Example datasets

- [`alco1`](https://github.com/folkehelsestats/highdir/reference/alco1.md)
  : Alcohol Consumption Data
- [`alco2`](https://github.com/folkehelsestats/highdir/reference/alco2.md)
  : Alcohol Consumption by Gender
