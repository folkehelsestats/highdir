# Show Arguments for a Geometry

Prints the required and optional `...` arguments accepted by a geometry
when used with
[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md).
This is the primary discoverability tool for geometry-specific arguments
that do not appear in
[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md)'s
signature.

## Usage

``` r
geom_args(type = NULL)
```

## Arguments

- type:

  Character. Geometry name, e.g. `"line"`, `"ranked_bar"`. If `NULL`
  (default), prints a summary for every registered geometry.

## Value

A data frame of argument metadata, invisibly. The primary purpose is the
side-effect of printing.

## Why this exists

[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md)
uses `...` for all geometry-specific arguments so its own signature
stays clean regardless of how many geometries are registered. The
trade-off is that users cannot see available args from
[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md)
alone. `geom_args()` solves that: it reads the `required_args` and
`optional_args` fields registered for each geometry and presents them in
a readable table.

## Examples

``` r
geom_args("line")
#> 
#> Arguments for hd_make(..., type = "line", ...):
#> 
#>   argument      kind      default  description
#>   ------------  --------  -------  ------------------------------
#>   smooth        optional  TRUE     Logical. TRUE = spline curves, FALSE = straight segments. Both backends.
#>   dot_size      optional  4        Numeric. Marker radius in pixels. Both backends.
#>   line_symbols  optional  NULL     Character vector. Highcharter only. Per-group marker shapes: 'circle','square','diamond','triangle','triangle-down'.
#> 
geom_args("ranked_bar")
#> 
#> Arguments for hd_make(..., type = "ranked_bar", ...):
#> 
#>   argument    kind      default  description
#>   ----------  --------  -------  ------------------------------
#>   ascending   optional  TRUE     Logical. TRUE = lowest bar at bottom, FALSE = highest at bottom. Both backends.
#>   vs          optional  NULL     Character. Category name to highlight with a second colour. Both backends.
#>   aim         optional  NULL     Numeric. Value for a dashed target/aim line. Both backends.
#>   char_scale  optional  0.045    Numeric. Scaling factor converting label character-count into axis-range units. Increase (e.g. 0.06) for larger text, decrease (e.g. 0.03) for smaller text. Default 0.045.
#>   min_frac    optional  0.08     Numeric. Minimum fraction of the axis range a bar must span before its label fits inside. Safety floor for short labels. Default 0.08 (8%).
#> 
geom_args("arearange")
#> 
#> Arguments for hd_make(..., type = "arearange", ...):
#> 
#>   argument  kind      default  description
#>   --------  --------  -------  ------------------------------
#>   ymin      required  NULL     Character. Column name for the lower bound of the range.
#>   ymax      required  NULL     Character. Column name for the upper bound of the range.
#> 
geom_args()           # all registered geometries
#> 
#> Arguments for hd_make(..., type = "arearange", ...):
#> 
#>   argument  kind      default  description
#>   --------  --------  -------  ------------------------------
#>   ymin      required  NULL     Character. Column name for the lower bound of the range.
#>   ymax      required  NULL     Character. Column name for the upper bound of the range.
#> 
#> geom 'column' has no extra arguments.
#> 
#> Arguments for hd_make(..., type = "line", ...):
#> 
#>   argument      kind      default  description
#>   ------------  --------  -------  ------------------------------
#>   smooth        optional  TRUE     Logical. TRUE = spline curves, FALSE = straight segments. Both backends.
#>   dot_size      optional  4        Numeric. Marker radius in pixels. Both backends.
#>   line_symbols  optional  NULL     Character vector. Highcharter only. Per-group marker shapes: 'circle','square','diamond','triangle','triangle-down'.
#> 
#> 
#> Arguments for hd_make(..., type = "pie", ...):
#> 
#>   argument    kind      default  description
#>   ----------  --------  -------  ------------------------------
#>   inner_size  optional  0%       Character. Inner radius as CSS %, e.g. '50%' for a donut
#> 
#> 
#> Arguments for hd_make(..., type = "ranked_bar", ...):
#> 
#>   argument    kind      default  description
#>   ----------  --------  -------  ------------------------------
#>   ascending   optional  TRUE     Logical. TRUE = lowest bar at bottom, FALSE = highest at bottom. Both backends.
#>   vs          optional  NULL     Character. Category name to highlight with a second colour. Both backends.
#>   aim         optional  NULL     Numeric. Value for a dashed target/aim line. Both backends.
#>   char_scale  optional  0.045    Numeric. Scaling factor converting label character-count into axis-range units. Increase (e.g. 0.06) for larger text, decrease (e.g. 0.03) for smaller text. Default 0.045.
#>   min_frac    optional  0.08     Numeric. Minimum fraction of the axis range a bar must span before its label fits inside. Safety floor for short labels. Default 0.08 (8%).
#> 
#> 
#> Arguments for hd_make(..., type = "scatter", ...):
#> 
#>   argument  kind      default  description
#>   --------  --------  -------  ------------------------------
#>   dot_size  optional  4        Numeric. Point size (ggplot2) or marker radius in px (highcharter).
#> 
#> 
#> Arguments for hd_make(..., type = "stacked_column", ...):
#> 
#>   argument  kind      default  description
#>   --------  --------  -------  ------------------------------
#>   stack     required  NULL     Character. Column name that assigns rows to stack groups.
#>   stacking  optional  normal   Character. Highcharter stacking mode: 'normal' or 'percent'.
#> 
#> 
#> Arguments for hd_make(..., type = "venn", ...):
#> 
#>   argument         kind      default       description
#>   ---------------  --------  ------------  ------------------------------
#>   sets             optional  NULL          List. Each element is a named list with slots:  sets  — character vector of set names for this entry         (length 1 = single set, length > 1 = intersection)  value — numeric size of this region  name  — optional character label shown in the diagramExample: list(  list(sets = list('A'), name = 'Animals', value = 5),  list(sets = list('B'), name = 'Four legs', value = 3),  list(sets = list('A','B'), value = 2))
#>   series_name      optional  Venn Diagram  Character. Series name shown in the chart title area. Highcharter only.
#>   label_font_size  optional  14px          Character. CSS font-size for set labels. Highcharter only.
#>   value_suffix     optional                Character. Symbol appended to displayed values. E.g. '%' renders '42%' instead of '42'. Applied in tooltips (highcharter) and region labels (ggplot2). Both backends.
#> 
```
