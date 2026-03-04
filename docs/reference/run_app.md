# Launch the highdir Shiny GUI

Opens an interactive browser-based application for building figures with
either the `highcharter` or `ggplot2` backend, without writing R code.

## Usage

``` r
run_app()
```

## Value

Does not return a value; launches a Shiny app in the browser.

## Details

The app allows users to:

- Upload a dataset in any format supported by the **rio** package.

- Choose a geometry, axis variables, and rendering backend.

- Configure chart title, subtitle, caption, and colour theme.

- Toggle JavaScript hover effects and the accessibility module.

- Render the figure on demand with the **Draw** button.

- Download as JSON or self-contained HTML (highcharter), PNG
  (highcharter, requires **webshot2**), or PNG / SVG (ggplot2).

- Copy the equivalent
  [`make_fig()`](https://github.com/folkehelsestats/highdir/reference/make_fig.md)
  call from the **R code** tab.

## See also

[`make_fig()`](https://github.com/folkehelsestats/highdir/reference/make_fig.md),
[`fig_spec()`](https://github.com/folkehelsestats/highdir/reference/fig_spec.md),
[`hd_save()`](https://github.com/folkehelsestats/highdir/reference/hd_save.md),
[`hd_set_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_set_theme.md)
