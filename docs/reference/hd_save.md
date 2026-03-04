# Save a Figure to Disk

Exports a `highchart` or `ggplot` figure produced by
[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md)
to a file. The output format is inferred from the file extension unless
`type` is supplied explicitly.

## Usage

``` r
hd_save(
  fig,
  file,
  type = "auto",
  width = 8,
  height = 5,
  dpi = 300,
  selfcontained = TRUE,
  ...
)
```

## Arguments

- fig:

  A `highchart` or `ggplot` object (output of
  [`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md)).

- file:

  Character. Output path including extension.

- type:

  `"auto"` (infer from extension) or an explicit format string. Default:
  `"auto"`.

- width:

  Numeric. Width in inches (ggplot2). Default: `8`.

- height:

  Numeric. Height in inches (ggplot2). Default: `5`.

- dpi:

  Numeric. Raster resolution for ggplot2. Default: `300`.

- selfcontained:

  Logical. Embed all JS/CSS in the HTML file. Default: `TRUE`.

- ...:

  Passed to
  [`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html)
  for ggplot2 figures.

## Value

`file`, invisibly.

## Details

|             |                                     |
|-------------|-------------------------------------|
| Backend     | Supported formats                   |
| highcharter | `html`, `json`                      |
| ggplot2     | `png`, `svg`, `pdf`, `jpeg`, `jpg`, |
|             | `tiff`, `bmp`, `eps`                |

To export a highcharter figure as an image, either save as `html` and
screenshot in a browser, or re-render with `backend = "ggplot2"` in
[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md)
and save as `png`.
