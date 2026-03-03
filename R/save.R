# R/save.R ── Standalone figure export helper
#
# hd_save() is the single code path for both scripted and Shiny exports;
# every Shiny download handler calls it.

#' Save a Figure to Disk
#'
#' Exports a `highchart` or `ggplot` figure produced by [hd_make()] to a
#' file.  The output format is inferred from the file extension unless `type`
#' is supplied explicitly.
#'
#' | Backend     | Supported formats                    |
#' |:----------- |:------------------------------------ |
#' | highcharter | `html`, `json`, `png`\*              |
#' | ggplot2     | `png`, `svg`, `pdf`, `jpeg`, `tiff` |
#'
#' \* PNG for highcharter requires the **webshot2** package and a Chromium
#' browser (`install.packages("webshot2")`).
#'
#' @param fig           A `highchart` or `ggplot` object (output of
#'   [hd_make()]).
#' @param file          Character.  Output path including extension, e.g.
#'   `"output/chart.html"`.
#' @param type          `"auto"` (infer from extension) or an explicit format
#'   string such as `"html"`, `"png"`, `"svg"`.  Default: `"auto"`.
#' @param width         Numeric.  Width — inches for ggplot2; pixels for HC
#'   PNG.  Default: `8`.
#' @param height        Numeric.  Height.  Default: `5`.
#' @param dpi           Numeric.  Raster resolution for ggplot2.
#'   Default: `300`.
#' @param selfcontained Logical.  Embed all JS/CSS in the HTML file.
#'   Default: `TRUE`.
#' @param delay         Numeric.  Seconds to wait before screenshotting a
#'   highcharter widget to PNG.  Default: `0.8`.
#' @param ...           Passed to [ggplot2::ggsave()] for ggplot2 figures.
#'
#' @return `file`, invisibly.
#'
#' @examples
#' \dontrun{
#' spec <- hd_spec(mtcars, "wt", "mpg")
#' opts <- fig_opts(title = "Weight vs MPG")
#'
#' hc_fig <- hd_make(spec, "scatter")
#' hd_save(hc_fig, "chart.html")
#' hd_save(hc_fig, "chart.json")
#'
#' gg_fig <- hd_make(spec, "scatter", backend = "ggplot2")
#' hd_save(gg_fig, "chart.png")
#' hd_save(gg_fig, "chart.svg")
#' }
#'
#' @export
hd_save <- function(fig,
                     file,
                     type          = "auto",
                     width         = 8,
                     height        = 5,
                     dpi           = 300,
                     selfcontained = TRUE,
                     delay         = 0.8,
                     ...) {

  type <- .resolve_type(type, file)

  if (is_highchart(fig)) {
    .save_highchart(fig, file, type, width, height, selfcontained, delay)
  } else if (is_ggplot(fig)) {
    .save_ggplot(fig, file, type, width, height, dpi, ...)
  } else {
    stop("`fig` must be a highchart or ggplot object.", call. = FALSE)
  }

  invisible(file)
}

# ── Internals ────────────────────────────────────────────────────────────────

#' @keywords internal
.resolve_type <- function(type, file) {
  if (!identical(type, "auto")) return(tolower(trimws(type)))
  ext <- tolower(tools::file_ext(file))
  if (!nzchar(ext))
    stop("Cannot infer format from `file`: no file extension found.",
         call. = FALSE)
  ext
}

#' @keywords internal
.save_highchart <- function(hc, file, type, width, height,
                              selfcontained, delay) {
  switch(type,
    html = {
      htmlwidgets::saveWidget(hc, file = file,
                               selfcontained = selfcontained)
    },
    json = {
      cfg <- hc$x$hc_opts
      if (is.null(cfg))
        stop("Could not extract Highcharts config from widget.",
             call. = FALSE)
      jsonlite::write_json(cfg, path = file, pretty = TRUE,
                           auto_unbox = TRUE)
    },
    png = {
      if (!requireNamespace("webshot2", quietly = TRUE))
        stop("PNG export requires the webshot2 package.\n",
             "Install: install.packages('webshot2')", call. = FALSE)
      tmp <- tempfile(fileext = ".html")
      on.exit(unlink(tmp), add = TRUE)
      htmlwidgets::saveWidget(hc, file = tmp, selfcontained = TRUE)
      webshot2::webshot(tmp, file = file,
                        vwidth = width, vheight = height, delay = delay)
    },
    stop("Unsupported format '", type, "' for highcharter. ",
         "Use 'html', 'json', or 'png'.", call. = FALSE)
  )
}

#' @keywords internal
.save_ggplot <- function(p, file, type, width, height, dpi, ...) {
  ok <- c("png", "svg", "pdf", "jpeg", "jpg", "tiff", "bmp", "eps")
  if (!type %in% ok)
    stop("Unsupported format '", type, "' for ggplot2. Use: ",
         paste(ok, collapse = ", "), call. = FALSE)
  ggplot2::ggsave(filename = file, plot = p, device = type,
                  width = width, height = height, dpi = dpi, ...)
}
