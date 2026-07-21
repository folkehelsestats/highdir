
#' Build a Figure from a Specification
#'
#' Renders a [hd_spec] and [hd_opts] pair using the selected backend and
#' geometry.  This is the central function of the package - everything else
#' feeds into or flows out of `hd_make()`.
#'
#' @section Workflow:
#' ```r
#' spec <- hd_spec(df, x = "age", y = "pct", group = "sex", n = "n")
#' opts <- hd_opts(title = "Health survey", ylim = c(0, 80))
#'
#' hd_make(spec, "column", opts)                       # highcharter (default)
#' hd_make(spec, "column", opts, backend = "ggplot2")  # static ggplot2
#' hd_make(spec, "line",   opts, smooth = TRUE)        # smooth spline
#' hd_make(spec, "pie",    opts)                       # pie / donut
#' ```
#'
#' @param spec      A [hd_spec] object from [hd_spec()].
#' @param type      Character.  Geometry name - one of [list_geoms()]:
#'   `"column"`, `"line"`, `"scatter"`, `"arearange"`, `"pie"`, or any
#'   custom geometry added with [register_geom()].
#' @param opts      A [hd_opts] object or `NULL` (uses all defaults).
#'   Controls title, subtitle, caption, ylim, yint, flip, per-figure
#'   colours, and highcharter theme.
#' @param mode      Character.  Rendering mode - `"dynamic"` (default,
#'  interactive) or `"static"`.  `"dynamic"` uses the highcharter
#'  backend, `"static"` uses the ggplot2 backend.  See [list_backends()].
#' @param backend   Character.  Rendering engine - `"highcharter"` (default,
#'   interactive) or `"ggplot2"` (static), or any engine added with
#'   [register_backend()].
#' @param use_js    Logical.  When `TRUE` (default) injects a hover-band
#'   `htmlwidgets::JS()` callback via `point.events.mouseOver/Out`.
#'   Tooltips, accessibility module, and all other Highcharts declarative
#'   features are **always** present.  Set `FALSE` for clean, no-custom-JS
#'   widgets.  Ignored by the ggplot2 backend.
#' @param module Use available modules js from CDN <https://api.highcharts.com/highcharts/>
#' @param ...       Extra arguments forwarded to the geometry function.
#'   Required arguments (e.g. `ymin`, `ymax` for `"arearange"`) **must**
#'   be supplied here.
#'
#' @return A `highchart` widget (highcharter backend) or `ggplot` object
#'   (ggplot2 backend), invisibly wrapped so knitr/Shiny render it
#'   automatically.
#'
#' @seealso [hd_spec()], [hd_opts()], [hd_save()], [hd_set_theme()],
#'   [list_geoms()], [list_backends()], [hd_app()]
#'
#' @examples
#' df <- data.frame(
#'   age = rep(c("18-24", "25-34", "35-44", "45-54"), each = 2),
#'   sex = rep(c("Male", "Female"), 4),
#'   pct = c(42, 38, 55, 61, 48, 52, 60, 57),
#'   n   = c(120, 115, 200, 210, 180, 175, 160, 155)
#' )
#'
#' spec <- hd_spec(df, x = "age", y = "pct", group = "sex", n = "n")
#'
#' opts <- hd_opts(title    = "Health survey results",
#'                  subtitle = "Source: FHI 2024",
#'                  ylim     = c(0, 80))
#'
#' \donttest{
#' # -- Interactive charts (highcharter) --------------------------------------
#' hd_make(spec, "column", opts)
#' hd_make(spec, "line",   opts, smooth = TRUE)
#' hd_make(spec, "line",   opts, smooth = FALSE, dot_size = 6)
#' hd_make(spec, "scatter")
#'
#' # Pie chart - group is ignored; x = label, y = value
#' pie_df   <- data.frame(category = c("A","B","C","D"),
#'                         value    = c(35, 25, 20, 20))
#' pie_spec <- hd_spec(pie_df, x = "category", y = "value")
#' pie_opts <- hd_opts(title = "Share by category")
#' hd_make(pie_spec, "pie", pie_opts)
#' hd_make(pie_spec, "pie", pie_opts, inner_size = "50%")  # donut
#'
#' # Arearange - requires ymin + ymax in ...
#' df2   <- cbind(df, lo = df$pct - 5, hi = df$pct + 5)
#' spec2 <- hd_spec(df2, "age", "pct", group = "sex")
#' hd_make(spec2, "arearange", opts, ymin = "lo", ymax = "hi")
#'
#' # -- Disable JS hover band -------------------------------------------------
#' hd_make(spec, "column", opts, use_js = FALSE)
#'
#' # -- Static ggplot2 versions -----------------------------------------------
#' hd_make(spec, "column",  opts, backend = "ggplot2")
#' hd_make(spec, "line",    opts, backend = "ggplot2")
#' hd_make(spec, "scatter", opts, backend = "ggplot2")
#' hd_make(pie_spec, "pie", pie_opts, backend = "ggplot2")
#'
#' # -- Reuse spec with different presentation --------------------------------
#' opts_no <- hd_opts(title = "Helseundersøkelse", subtitle = "Alle aldre")
#' hd_make(spec, "column", opts_no)
#'
#' # -- Save outputs ----------------------------------------------------------
#' \dontrun{
#' hd_save(hd_make(spec, "column", opts), "column.html")
#' hd_save(hd_make(spec, "column", opts, backend="ggplot2"), "column.png")
#' }
#' }
#' 
#' @export

hd_make <- function(spec,
                    type = "column",
                    opts = NULL,
                    mode = NULL,
                    backend = lifecycle::deprecated(),
                    use_js = TRUE,
                    module = FALSE,
                    ...) {

  opts <- opts %||% default_opts()
  extra_args <- list(...)

  # Gammelt argument brukes
  if (lifecycle::is_present(backend)) {

    lifecycle::deprecate_warn(
      when = "0.7.0",
      what = "hd_make(backend)",
      with = "hd_make(mode)"
    )

    # Backend tar effekt dersom mode ikke er oppgitt
    if (is.null(mode)) {

      mode <- switch(
        backend,
        highcharter = "dynamic",
        ggplot2     = "static",
        backend
      )

    } else {

      stop(
        "Please supply either `mode` or `backend`, not both.",
        call. = FALSE
      )
    }
  }

  mode <- normalize_mode(mode)

  validate_fig_inputs(
    spec,
    opts,
    type,
    mode,
    extra_args
  )

  spec <- check_decimals(
    spec,
    opts,
    type,
    extra_args
  )

  geom <- .get_geom(type)

  engine <- switch(
    mode,
    dynamic = backend_highcharter,
    static  = backend_ggplot2
  )

  engine(
    spec        = spec,
    geom        = geom,
    opts        = opts,
    geom_params = extra_args,
    use_js      = use_js,
    module      = module
  )
}



normalize_mode <- function(mode) {

  if (is.null(mode)) {
    mode <- "dynamic"
  }

  # Støtt gamle verdier en periode
  if (identical(mode, "highcharter")) {

    lifecycle::deprecate_warn(
      when = "0.7.0",
      what = 'mode = "highcharter"',
      with = 'mode = "dynamic"'
    )

    mode <- "dynamic"
  }

  if (identical(mode, "ggplot2")) {

    lifecycle::deprecate_warn(
      when = "0.7.0",
      what = 'mode = "ggplot2"',
      with = 'mode = "static"'
    )

    mode <- "static"
  }

  rlang::arg_match(
    mode,
    values = c("dynamic", "static")
  )
}

## When it's time to kill it
## -----------------------------------------------------------------------------
# if (lifecycle::is_present(backend)) {

#   replacement <- switch(
#     backend,
#     highcharter = "dynamic",
#     ggplot2 = "static",
#     "<unknown>"
#   )

#   lifecycle::deprecate_stop(
#     when = "0.9.0",
#     what = "hd_make(backend)",
#     details = sprintf(
#       "Use `mode = \"%s\"` instead.",
#       replacement
#     )
#   )
# }
