# theme.R — Style, theme, and JavaScript configuration layer
#
# Design:
#  * Package-level defaults live in R options() so users can call
#    hd_set_theme() once and have it apply everywhere.
#  * hd_theme() resolves the current options into a highcharter theme object.
#  * apply_gg_colors() maps the current colour palette onto a ggplot object.
#  * hd_add_js() injects JavaScript into an existing highchart widget.

# ---------------------------------------------------------------------------
# Package-level defaults (applied in zzz.R / .onLoad)
# ---------------------------------------------------------------------------

#' @keywords internal
.hd_defaults <- list(
  highdir.hc_theme   = "default",
  highdir.colors     = NULL,
  highdir.font       = NULL,
  highdir.js_plugins = character(0)
)

# ---------------------------------------------------------------------------
# User-facing theme setter
# ---------------------------------------------------------------------------

#' Set Package-Wide Style Defaults
#'
#' Configures default theme, colour palette, font, and JavaScript plugins for
#' all figures produced with [make_fig()] in the current R session. Call once
#' at the top of a script or in `.Rprofile` for consistent styling.
#'
#' @param hc_theme Character or `NULL`. Name of a built-in highcharter theme.
#'   One of `"default"`, `"smpl"`, `"economist"`, `"darkunica"`,
#'   `"gridlight"`, `"bloom"`, `"flat"`, `"flatdark"`, `"ggplot2"`.
#' @param colors Character vector or `NULL`. Hex colour codes applied to
#'   every figure (both backends). When `NULL` the hdir default palette or
#'   the theme colours are used.
#' @param font Character or `NULL`. Font family string, e.g.
#'   `"Source Sans Pro"`. `NULL` uses the theme/system font.
#' @param js_plugins Character vector or `NULL`. Names of bundled JS plugins
#'   (files in `inst/js/`) to inject into every highcharter figure. Supply
#'   `character(0)` to clear.
#'
#' @return The previous option values, invisibly, so you can restore them
#'   with `options(hd_set_theme(...))` if needed.
#'
#' @examples
#' # Use the economist theme with custom colours
#' hd_set_theme(hc_theme = "economist",
#'              colors   = c("#025169", "#7C145C", "#C68803"))
#'
#' # Reset to defaults
#' hd_set_theme(hc_theme = "default", colors = NULL)
#'
#' @export
hd_set_theme <- function(hc_theme   = NULL,
                          colors     = NULL,
                          font       = NULL,
                          js_plugins = NULL) {
  prev <- list()
  if (!is.null(hc_theme)) {
    prev$highdir.hc_theme <- getOption("highdir.hc_theme")
    options(highdir.hc_theme = hc_theme)
  }
  if (!is.null(colors)) {
    prev$highdir.colors <- getOption("highdir.colors")
    options(highdir.colors = colors)
  }
  if (!is.null(font)) {
    prev$highdir.font <- getOption("highdir.font")
    options(highdir.font = font)
  }
  if (!is.null(js_plugins)) {
    prev$highdir.js_plugins <- getOption("highdir.js_plugins")
    options(highdir.js_plugins = js_plugins)
  }
  invisible(prev)
}

# ---------------------------------------------------------------------------
# Highcharter theme builder
# ---------------------------------------------------------------------------

#' Build a Highcharts Theme Object
#'
#' Constructs a highcharter theme by merging a named base theme with colour
#' and font overrides from the current [hd_set_theme()] settings and any
#' extra named arguments passed via `...`.
#'
#' You normally do not need to call this directly — [make_fig()] applies it
#' automatically for `backend = "highcharter"`. Use it when you want to
#' preview or apply a theme to a highchart object built outside highdir.
#'
#' @param name Character or `NULL`. Theme name. `NULL` reads from
#'   `getOption("highdir.hc_theme")`.
#' @param ... Named arguments forwarded to [highcharter::hc_theme()] as
#'   overrides on top of the base theme. See the Highcharts API for the
#'   expected structure.
#'
#' @return A highcharter theme object (a named list of class `"hc_theme"`).
#'
#' @examples
#' \dontrun{
#' t <- hd_theme("darkunica")
#' highcharter::highchart() |> highcharter::hc_add_theme(t)
#' }
#'
#' @export
hd_theme <- function(name = NULL, ...) {
  name   <- name   %||% getOption("highdir.hc_theme", default = "default")
  colors <- getOption("highdir.colors", default = NULL)
  font   <- getOption("highdir.font",   default = NULL)

  base <- switch(name,
    "default"   = , "smpl" = highcharter::hc_theme_smpl(),
    "economist"  = highcharter::hc_theme_economist(),
    "darkunica"  = highcharter::hc_theme_darkunica(),
    "gridlight"  = highcharter::hc_theme_gridlight(),
    "bloom"      = highcharter::hc_theme_bloom(),
    "flat"       = highcharter::hc_theme_flat(),
    "flatdark"   = highcharter::hc_theme_flatdark(),
    "ggplot2"    = highcharter::hc_theme_ggplot2(),
    stop("Unknown theme '", name, "'. Choose one of: default, smpl, ",
         "economist, darkunica, gridlight, bloom, flat, flatdark, ggplot2",
         call. = FALSE)
  )

  overrides <- list(...)
  if (!is.null(colors)) overrides$colors <- colors
  if (!is.null(font)) {
    overrides$chart <- utils::modifyList(
      overrides$chart %||% list(),
      list(style = list(fontFamily = font))
    )
  }

  if (length(overrides) > 0) {
    overlay <- do.call(highcharter::hc_theme, overrides)
    highcharter::hc_theme_merge(base, overlay)
  } else {
    base
  }
}

# ---------------------------------------------------------------------------
# ggplot2 colour application
# ---------------------------------------------------------------------------

#' @keywords internal
apply_gg_colors <- function(p, colors = NULL) {
  pal <- colors %||% getOption("highdir.colors", default = NULL)
  if (is.null(pal)) return(p)
  p +
    ggplot2::scale_color_manual(values = pal) +
    ggplot2::scale_fill_manual(values  = pal)
}

# ---------------------------------------------------------------------------
# JavaScript injection
# ---------------------------------------------------------------------------

#' Inject JavaScript into a Highcharts Widget
#'
#' Appends custom JavaScript to a `highchart` object. Useful for Highcharts
#' plugins, custom `load` / `render` callbacks, or any other JS that must run
#' in the chart's context.
#'
#' @param hc A `highchart` object (output of [make_fig()] with
#'   `backend = "highcharter"`, or any object returned by
#'   [highcharter::highchart()]).
#' @param code Character or `NULL`. Raw JavaScript string.
#' @param file Character or `NULL`. Path to a `.js` file whose contents are
#'   read and injected.
#' @param plugin Character or `NULL`. Name of a JS plugin bundled with
#'   highdir (a file at `inst/js/<plugin>.js`). Convenient shorthand for
#'   `file = system.file(...)`.
#' @param where Character. One of `"load"` (default) — runs when the chart
#'   finishes loading — or `"render"` — runs after every render cycle.
#'
#' @details Exactly one of `code`, `file`, or `plugin` must be supplied.
#'
#' @return The `highchart` object with the JS injected via
#'   `chart.events.<where>`.
#'
#' @examples
#' \dontrun{
#' spec <- fig_spec(mtcars, "wt", "mpg")
#' fig  <- make_fig(spec, "scatter", backend = "highcharter")
#' fig  <- hd_add_js(fig, code = "console.log('chart loaded');")
#' }
#'
#' @export
hd_add_js <- function(hc,
                       code   = NULL,
                       file   = NULL,
                       plugin = NULL,
                       where  = c("load", "render")) {
  where <- match.arg(where)

  if (!is.null(plugin)) {
    file <- system.file("js", paste0(plugin, ".js"), package = "highdir")
    if (!nzchar(file)) {
      avail <- tools::file_path_sans_ext(
        list.files(system.file("js", package = "highdir", mustWork = FALSE))
      )
      stop("Plugin '", plugin, "' not found in inst/js/.",
           if (length(avail)) paste0(" Available: ", paste(avail, collapse = ", ")),
           call. = FALSE)
    }
  }

  if (!is.null(file)) {
    if (!file.exists(file))
      stop("File not found: ", file, call. = FALSE)
    code <- paste(readLines(file, warn = FALSE), collapse = "\n")
  }

  if (is.null(code))
    stop("Supply exactly one of `code`, `file`, or `plugin`.", call. = FALSE)

  events_update <- stats::setNames(list(htmlwidgets::JS(code)), where)
  hc |> highcharter::hc_chart(events = events_update)
}
