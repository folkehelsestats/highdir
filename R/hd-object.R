
# ══════════════════════════════════════════════════════════════════════════════
# hd()  ── constructor
# ══════════════════════════════════════════════════════════════════════════════

#' Initialise a Composable highdir Figure
#'
#' Creates an `hd` object that accumulates geometry and presentation layers
#' via `+`, then renders when printed.  This mirrors the way `ggplot2` builds
#' plots: data mapping is declared first; visual decisions are added
#' incrementally; nothing is rendered until the object hits the console (or an
#' explicit `print()` / `knit` call).
#'
#' `hd()` accepts either raw data columns **or** an existing [hd_spec()] object.
#' Passing an `hd_spec` is the recommended bridge for code that already
#' constructs specs separately (e.g. in Shiny or a reporting pipeline).
#'
#' @param data   A `data.frame` **or** an [hd_spec()] object.  When an
#'   `hd_spec` is supplied every other mapping argument (`x`, `y`, …) is
#'   ignored — the spec carries them already.
#' @param x      Character. Column name for the x-axis variable.
#'   Ignored when `data` is an `hd_spec`.
#' @param y      Character. Column name for the y-axis variable.
#'   Ignored when `data` is an `hd_spec`.
#' @param group  Character or `NULL`. Column used to split data into multiple
#'   series.  Ignored when `data` is an `hd_spec`.
#' @param n      Character or `NULL`. Column of raw counts shown in
#'   highcharter tooltips alongside the y value.
#'   Ignored when `data` is an `hd_spec`.
#' @param colour Character or `NULL`. ggplot2 colour aesthetic column.
#'   Defaults to `group` when `NULL` and `group` is set.
#'   Ignored when `data` is an `hd_spec`.
#' @param backend Character. Rendering engine — `"highcharter"` (default,
#'   interactive) or `"ggplot2"` (static), or any engine added with
#'   [register_backend()].  Falls back to `getOption("highdir.backend",
#'   "highcharter")`.
#'
#' @return An S3 object of class `"hd"` with slots:
#'   \describe{
#'     \item{`$spec`}{An [hd_spec()] object.}
#'     \item{`$geom`}{`NULL` until a `+ hd_geom_*()` layer is added.}
#'     \item{`$opts`}{An [hd_opts()] object (defaults until overridden).}
#'     \item{`$backend`}{Character. The resolved engine name.}
#'   }
#'
#' @seealso [hd_geom_column()], [hd_geom_line()], [hd_geom_arearange()],
#'   [hd_opts()], [hd_make()]
#'
#' @examples
#' df <- data.frame(
#'   age = rep(c("18-24", "25-34", "35-44", "45-54"), each = 2),
#'   sex = rep(c("Male", "Female"), 4),
#'   pct = c(42, 38, 55, 61, 48, 52, 60, 57),
#'   n   = c(120, 115, 200, 210, 180, 175, 160, 155)
#' )
#'
#' # Composable style
#' hd(df, x = "age", y = "pct", group = "sex") +
#'   hd_geom_column() +
#'   hd_opts(title = "Health survey", ylim = c(0, 80))
#'
#' # Pass an existing hd_spec
#' spec <- hd_spec(df, x = "age", y = "pct", group = "sex", n = "n")
#' hd(spec) +
#'   hd_geom_line(smooth = TRUE) +
#'   hd_opts(title = "Trend")
#'
#' # Switch backend per figure
#' hd(df, x = "age", y = "pct", backend = "ggplot2") +
#'   hd_geom_column() +
#'   hd_opts(title = "Static version")
#'
#' @export
hd <- function(data,
               x       = NULL,
               y       = NULL,
               group   = NULL,
               n       = NULL,
               colour  = NULL,
               backend = getOption("highdir.backend", "highcharter")) {

  spec <- if (inherits(data, "hd_spec")) {
    data  # already a spec — use as-is
  } else {
    hd_spec(data,
            x      = x,
            y      = y,
            group  = group,
            n      = n,
            colour = colour)
  }

  structure(
    list(
      spec    = spec,
      geom    = NULL,           # set by + hd_geom_*()
      opts    = default_opts(), # set by + hd_opts(); starts with all defaults
      backend = backend
    ),
    class = "hd"
  )
}


# ══════════════════════════════════════════════════════════════════════════════
# hd_geom()  ── internal geom-layer constructor
# ══════════════════════════════════════════════════════════════════════════════

#' @keywords internal
hd_geom <- function(type, ...) {
  structure(
    list(type = type, params = list(...)),
    class = "hd_geom"
  )
}


# ══════════════════════════════════════════════════════════════════════════════
# hd_geom_*()  ── public geom constructors  (one per registered geometry)
# ══════════════════════════════════════════════════════════════════════════════

#' Geometry Layers for hd Objects
#'
#' Each `hd_geom_*()` function creates a geometry layer that is added to an
#' [hd()] object via `+`.  The layer records the geometry type and any
#' geometry-specific arguments; rendering only happens when the `hd` object is
#' printed.
#'
#' Geometry-specific arguments (`...`) are forwarded to [hd_make()] as the
#' `...` pass-through which they are the same arguments documented by
#' [geom_args()].
#'
#' @param ... Geometry-specific arguments forwarded to [hd_make()].
#'   Use [geom_args()] to discover available arguments per geometry, e.g.
#'   `geom_args("line")` lists `smooth`, `dot_size`, `line_symbols`.
#'
#' @return An S3 object of class `"hd_geom"` for use with `+.hd`.
#'
#' @name hd_geom_layer
#' @seealso [hd()], [list_geoms()], [geom_args()], [hd_make()]
NULL



# ══════════════════════════════════════════════════════════════════════════════
# +.hd  ── accumulate layers
# ══════════════════════════════════════════════════════════════════════════════

#' Add Layers to an hd Object
#'
#' Implements the `+` operator for [hd()] objects, mirroring how `ggplot2`
#' builds plots incrementally.  Recognised right-hand sides:
#'
#' \describe{
#'   \item{`hd_geom` object}{Sets the geometry (from any `hd_geom_*()` call).
#'     Adding a second geom replaces the first where highdir renders one geometry
#'     per figure.}
#'   \item{`hd_opts` object}{Sets presentation options.  Adding a second
#'     `hd_opts` replaces the first.}
#' }
#'
#' Unknown right-hand sides produce an informative error rather than silently
#' being ignored.
#'
#' @param e1 An `hd` object (left-hand side).
#' @param e2 An `hd_geom` or `hd_opts` object (right-hand side).
#'
#' @return The updated `hd` object (invisibly, so the chain prints once).
#'
#' @examples
#' df <- data.frame(age = c("18-24", "25-34"), pct = c(42, 55))
#'
#' # Chain layers
#' p <- hd(df, x = "age", y = "pct") +
#'   hd_geom_column() +
#'   hd_opts(title = "Demo")
#'
#' # Reuse a partial object with different opts
#' base <- hd(df, x = "age", y = "pct") + hd_geom_column()
#' base + hd_opts(title = "English title")
#' base + hd_opts(title = "Norsk tittel")
#'
#' @export
`+.hd` <- function(e1, e2) {
  if (inherits(e2, "hd_geom")) {
    e1$geom <- e2
    .validate_geom_backend(e1)   # ← check immediately after attaching
  } else if (inherits(e2, "hd_opts")) {
    e1$opts <- e2
  } else {
    stop(
      "Cannot add an object of class <", paste(class(e2), collapse = "/"),
      "> to an <hd> object.\n",
      "Accepted types: hd_geom_*() or hd_opts().",
      call. = FALSE
    )
  }
  e1
}


# ══════════════════════════════════════════════════════════════════════════════
# print.hd  ── render by delegating to hd_make()
# ══════════════════════════════════════════════════════════════════════════════

#' Render an hd Object
#'
#' Printing an [hd()] object triggers rendering.  The geometry type and any
#' geometry-specific parameters are extracted from the stored `hd_geom` layer;
#' presentation options from the `hd_opts` layer; the backend from the
#' `$backend` slot.  All of these are forwarded to [hd_make()], which performs
#' the actual rendering via the registered engine.
#'
#' You rarely need to call `print.hd()` directly since R calls it automatically
#' when the object appears at the top level, in knitr/Quarto chunks, or in
#' Shiny `renderHighchart()` / `renderPlot()` blocks.
#'
#' @param x   An `hd` object.
#' @param ... Ignored; present for S3 consistency.
#'
#' @return The rendered output (a `highchart` widget or a `ggplot` object),
#'   invisibly.
#'
#' @export
print.hd <- function(x, ...) {

  # Resolve geom - default to "column" if no hd_geom_*() was added
  type        <- x$geom$type   %||% "column"
  geom_params <- x$geom$params %||% list()

  out <- do.call(
    hd_make,
    c(
      list(
        spec    = x$spec,
        type    = type,
        opts    = x$opts,
        backend = x$backend
      ),
      geom_params   # splices ymin/ymax/smooth/… back into hd_make()'s ...
    )
  )

  print(out)
  invisible(out)
}


# ══════════════════════════════════════════════════════════════════════════════
# S3 helpers
# ══════════════════════════════════════════════════════════════════════════════

#' @export
print.hd_geom <- function(x, ...) {
  cat("<hd_geom>\n")
  cat("  type  :", x$type, "\n")
  if (length(x$params)) {
    cat("  params:\n")
    for (nm in names(x$params))
      cat("    ", nm, "=", format(x$params[[nm]]), "\n")
  }
  invisible(x)
}
