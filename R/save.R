# save.R — Standalone figure export helpers
#
# hd_save() is the single entry point for both scripted and Shiny exports.
# The Shiny download handlers all call hd_save() so there is one code path.

#' Save a Figure to Disk
#'
#' Exports a figure produced by [make_fig()] (or any `ggplot` / `highchart`
#' object) to a file. The output format is inferred from the file extension
#' unless `type` is specified explicitly.
#'
#' | Backend      | Supported formats                     |
#' |:------------ |:--------------------------------------|
#' | highcharter  | `html`, `json`, `png`*                |
#' | ggplot2      | `png`, `svg`, `pdf`, `jpeg`, `tiff`  |
#'
#' *PNG for highcharter requires the **webshot2** package and a Chromium
#' browser. Install with `install.packages("webshot2")`.
#'
#' @param fig A `highchart` or `ggplot` object.
#' @param file Character. Output file path including extension, e.g.
#'   `"output/chart.html"` or `"output/chart.png"`.
#' @param type Character. Explicit format override. One of `"auto"` (infer
#'   from extension), `"html"`, `"json"`, `"png"`, `"svg"`, `"pdf"`,
#'   `"jpeg"`, `"tiff"`. Default: `"auto"`.
#' @param width Numeric. Output width. Inches for ggplot2; pixels for
#'   highcharter PNG. Default: `8`.
#' @param height Numeric. Output height. Inches for ggplot2; pixels for
#'   highcharter PNG. Default: `5`.
#' @param dpi Numeric. Resolution for raster ggplot2 exports. Default: `300`.
#' @param selfcontained Logical. For HTML export, embed all JS/CSS so the
#'   file is self-contained and portable. Default: `TRUE`.
#' @param delay Numeric. Seconds to wait for JavaScript to finish rendering
#'   before taking a PNG screenshot of a highcharter widget. Default: `0.8`.
#' @param ... Additional arguments forwarded to [ggplot2::ggsave()] (ggplot2
#'   figures only).
#'
#' @return `file`, invisibly. Called primarily for its side-effect.
#'
#' @examples
#' \dontrun{
#' spec <- fig_spec(mtcars, "wt", "mpg", title = "Weight vs MPG")
#'
#' # Highcharter
#' hc_fig <- make_fig(spec, "scatter", backend = "highcharter")
#' hd_save(hc_fig, "chart.html")
#' hd_save(hc_fig, "chart.json")
#' hd_save(hc_fig, "chart.png")   # requires webshot2
#'
#' # ggplot2
#' gg_fig <- make_fig(spec, "scatter", backend = "ggplot2")
#' hd_save(gg_fig, "chart.png")
#' hd_save(gg_fig, "chart.svg")
#' hd_save(gg_fig, "chart.pdf")
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
    .save_highchart(fig, file, type,
                    width = width, height = height,
                    selfcontained = selfcontained, delay = delay)
  } else if (is_ggplot(fig)) {
    .save_ggplot(fig, file, type,
                 width = width, height = height, dpi = dpi, ...)
  } else {
    stop("`fig` must be a highchart or ggplot object.", call. = FALSE)
  }

  invisible(file)
}

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

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
      htmlwidgets::saveWidget(hc, file = file, selfcontained = selfcontained)
    },
    json = {
      cfg <- hc$x$hc_opts
      if (is.null(cfg))
        stop("Could not extract Highcharts config from the widget.",
             call. = FALSE)
      jsonlite::write_json(cfg, path = file, pretty = TRUE, auto_unbox = TRUE)
    },
    png = {
      if (!requireNamespace("webshot2", quietly = TRUE))
        stop(
          "PNG export of highcharter figures requires the webshot2 package.\n",
          "Install it with:  install.packages(\"webshot2\")\n",
          "Then check Chrome is available with webshot2::webshot_chromote().",
          call. = FALSE
        )
      tmp <- tempfile(fileext = ".html")
      on.exit(unlink(tmp), add = TRUE)
      htmlwidgets::saveWidget(hc, file = tmp, selfcontained = TRUE)
      webshot2::webshot(tmp, file = file,
                        vwidth = width, vheight = height,
                        delay  = delay)
    },
    stop("Unsupported format '", type, "' for highcharter output. ",
         "Use 'html', 'json', or 'png'.", call. = FALSE)
  )
}

#' @keywords internal
.save_ggplot <- function(p, file, type, width, height, dpi, ...) {
  supported <- c("png", "svg", "pdf", "jpeg", "jpg", "tiff", "bmp", "eps")
  if (!type %in% supported)
    stop("Unsupported format '", type, "' for ggplot2 output. ",
         "Use one of: ", paste(supported, collapse = ", "), call. = FALSE)
  ggplot2::ggsave(
    filename = file,
    plot     = p,
    device   = type,
    width    = width,
    height   = height,
    dpi      = dpi,
    ...
  )
}
