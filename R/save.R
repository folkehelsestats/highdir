# R/save.R

#' Save a Figure to Disk
#'
#' Exports a `highchart` or `ggplot` figure produced by [hd_make()] to a
#' file. The output format is inferred from the file extension unless `type`
#' is supplied explicitly.
#'
#' | Backend     | Supported formats                        |
#' |:----------- |:---------------------------------------- |
#' | highcharter | `html`, `json`                           |
#' | ggplot2     | `png`, `svg`, `pdf`, `jpeg`, `jpg`,      |
#' |             | `tiff`, `bmp`, `eps`                     |
#'
#' To export a highcharter figure as an image, either save as `html` and
#' screenshot in a browser, or re-render with `backend = "ggplot2"` in
#' [hd_make()] and save as `png`.
#'
#' @param fig           A `highchart` or `ggplot` object (output of
#'   [hd_make()]).
#' @param file          Character. Output path including extension.
#' @param type          `"auto"` (infer from extension) or an explicit format
#'   string. Default: `"auto"`.
#' @param width         Numeric. Width in inches (ggplot2). Default: `8`.
#' @param height        Numeric. Height in inches (ggplot2). Default: `5`.
#' @param dpi           Numeric. Raster resolution for ggplot2. Default: `300`.
#' @param selfcontained Logical. Embed all JS/CSS in the HTML file.
#'   Default: `TRUE`.
#' @param ...           Passed to [ggplot2::ggsave()] for ggplot2 figures.
#'
#' @return `file`, invisibly.
#' @export
hd_save <- function(fig,
                     file,
                     type          = "auto",
                     width         = 8,
                     height        = 5,
                     dpi           = 300,
                     selfcontained = TRUE,
                     ...) {

  type <- .resolve_type(type, file)

  if (inherits(fig, "highchart")) {
    .save_highchart(fig, file, type, width, height, selfcontained)
  } else if (inherits(fig, "ggplot")) {
    .save_ggplot(fig, file, type, width, height, dpi, ...)
  } else {
    stop(
      "`fig` must be a highchart or ggplot object.\n",
      "Pass the direct output of hd_make().",
      call. = FALSE
    )
  }

  invisible(file)
}

# ── Internals ─────────────────────────────────────────────────────────────────

#' @keywords internal
.resolve_type <- function(type, file) {
  if (!identical(type, "auto")) return(tolower(trimws(type)))
  ext <- tolower(tools::file_ext(file))
  if (!nzchar(ext))
    stop(
      "Cannot infer format from `file`: no file extension found.\n",
      "Add an extension e.g. 'chart.html' or 'chart.png'.",
      call. = FALSE
    )
  ext
}

#' @keywords internal
.sanitise_hc_config <- function(x) {
  # Recursively convert JS_EVAL objects to plain character strings.
  # highcharter stores raw JavaScript (formatters, callbacks) as JS_EVAL —
  # a character vector with class attribute "JS_EVAL". jsonlite has no
  # asJSON method for this class and errors without this conversion.
  # The JS string content is preserved; only the class wrapper is removed.
  if (inherits(x, "JS_EVAL")) return(as.character(x))
  if (is.list(x))              return(lapply(x, .sanitise_hc_config))
  x
}

#' @keywords internal
.save_highchart <- function(hc, file, type, width, height, selfcontained) {

  # ── Format gate ───────────────────────────────────────────────────────────
  hc_formats <- c("html", "json")

  if (!type %in% hc_formats)
    stop(
      "Format '.", type, "' is not supported for highcharter figures.\n",
      "Supported formats: ", paste0(".", hc_formats, collapse = ", "), "\n",
      "To save as an image use backend = 'ggplot2' in hd_make(), ",
      "then call hd_save() with '.png', '.svg', or '.pdf'.",
      call. = FALSE
    )

  switch(type,

    html = {
      if (!requireNamespace("htmlwidgets", quietly = TRUE))
        stop(
          "HTML export requires the htmlwidgets package.\n",
          "Install: install.packages('htmlwidgets')",
          call. = FALSE
        )
      htmlwidgets::saveWidget(
        widget        = hc,
        file          = normalizePath(file, mustWork = FALSE),
        selfcontained = selfcontained
      )
    },

    json = {
      if (!requireNamespace("jsonlite", quietly = TRUE))
        stop(
          "JSON export requires the jsonlite package.\n",
          "Install: install.packages('jsonlite')",
          call. = FALSE
        )
      cfg <- hc$x$hc_opts
      if (is.null(cfg))
        stop(
          "Could not extract Highcharts config from widget.\n",
          "Ensure `fig` is the direct output of hd_make().",
          call. = FALSE
        )
      jsonlite::write_json(
        .sanitise_hc_config(cfg),
        path       = file,
        pretty     = TRUE,
        auto_unbox = TRUE
      )
    }
  )
}

#' @keywords internal
.save_ggplot <- function(p, file, type, width, height, dpi, ...) {

  gg_formats <- c("png", "svg", "pdf", "jpeg", "jpg", "tiff", "bmp", "eps")

  if (!type %in% gg_formats)
    stop(
      "Format '.", type, "' is not supported for ggplot2 figures.\n",
      "Supported formats: ", paste0(".", gg_formats, collapse = ", "),
      call. = FALSE
    )

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
