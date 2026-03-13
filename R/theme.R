# R/theme.R -- Style, theme and JavaScript configuration

# -- Package-level option defaults (applied in zzz.R) ------------------------

#' @keywords internal
.hd_defaults <- list(
  highdir.hc_theme   = "default",
  highdir.gg_theme   = "classic",
  highdir.colors     = NULL,
  highdir.font       = NULL,
  highdir.js_plugins = character(0)
)

# -- Session-wide style setter ------------------------------------------------

#' Set Package-Wide Style Defaults
#'
#' Configures the default theme, colour palette, font, and optional JavaScript
#' plugins for all figures produced with [hd_make()] in the current R session.
#' Call once at the top of a script or in `.Rprofile`.
#'
#' Per-figure overrides are provided via [hd_opts()], which always take
#' precedence over these session defaults.
#'
#' @param hc_theme   Character or `NULL`. Built-in highcharter theme name: one
#'   of `"default"`, `"smpl"`, `"economist"`, `"darkunica"`, `"gridlight"`,
#'   `"bloom"`, `"flat"`, `"flatdark"`, `"ggplot2"`.
#' @param gg_theme   Character, ggplot2 theme object, or `NULL`. Controls the
#'   ggplot2 backend appearance. Built-in name strings: `"minimal"` (default),
#'   `"classic"`, `"bw"`, `"light"`, `"dark"`, `"void"`, `"grey"`.
#'   Alternatively pass any `ggplot2::theme_*()` object directly for full
#'   control, e.g. `ggplot2::theme_bw(base_size = 14)`.
#' @param colors     Character vector, palette name, or `NULL`. Applied to all
#'   figures in the session. See [register_palette()].
#' @param font       Character or `NULL`. Font family name, e.g.
#'   `"Source Sans Pro"`.
#' @param js_plugins Character vector or `NULL`. Names of bundled JS plugins
#'   (files in `inst/js/`) injected into every highcharter figure. Use
#'   `character(0)` to clear all plugins.
#'
#' @return The previous option values invisibly; pass to `options()` to
#'   restore.
#'
#' @examples
#' hd_set_theme(hc_theme = "economist", gg_theme = "classic",
#'              colors   = c("#025169", "#7C145C", "#C68803"))
#' # Reset
#' hd_set_theme(hc_theme = "default", gg_theme = "minimal", colors = NULL)
#'
#' @seealso [hd_opts()] for per-figure overrides
#' @export
hd_set_theme <- function(hc_theme   = NULL,
                         gg_theme   = NULL,
                         colors     = NULL,
                         font       = NULL,
                         js_plugins = NULL) {
  prev <- list()
  if (!is.null(hc_theme)) {
    prev$highdir.hc_theme <- getOption("highdir.hc_theme")
    options(highdir.hc_theme = hc_theme)
  }
  if (!is.null(gg_theme)) {
    prev$highdir.gg_theme <- getOption("highdir.gg_theme")
    options(highdir.gg_theme = gg_theme)
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

# -- Highcharter theme builder ------------------------------------------------

#' Build a Highcharts Theme Object
#'
#' Constructs a highcharter theme by merging a named base theme with colour
#' and font overrides from the current [hd_set_theme()] session defaults and
#' any per-figure `opts`.
#'
#' Called automatically inside the highcharter engine; useful when you want to
#' apply a theme to a highchart built outside highdir.
#'
#' @param name   Character or `NULL`. Theme name; `NULL` reads from
#'   `getOption("highdir.hc_theme")`.
#' @param colors Character vector or `NULL`. Colour override for this call.
#' @param ...    Named arguments forwarded to [highcharter::hc_theme()] as
#'   extra overrides on top of the base theme.
#'
#' @return A highcharter theme object (`hc_theme`).
#'
#' @examples
#' \dontrun{
#' t <- hd_theme("darkunica")
#' highcharter::highchart() |> highcharter::hc_add_theme(t)
#' }
#'
#' @export
hd_theme <- function(name = NULL, colors = NULL, ...) {
  name   <- name   %||% getOption("highdir.hc_theme", default = "default")
  colors <- colors %||% getOption("highdir.colors",   default = NULL)
  font   <- getOption("highdir.font", default = NULL)

  base <- switch(name,
    "default" = , "smpl" = highcharter::hc_theme_smpl(),
    "economist"  = highcharter::hc_theme_economist(),
    "darkunica"  = highcharter::hc_theme_darkunica(),
    "gridlight"  = highcharter::hc_theme_gridlight(),
    "bloom"      = highcharter::hc_theme_bloom(),
    "flat"       = highcharter::hc_theme_flat(),
    "flatdark"   = highcharter::hc_theme_flatdark(),
    "ggplot2"    = highcharter::hc_theme_ggplot2(),
    stop("Unknown theme '", name, "'. Choose from: default, smpl, economist, ",
         "darkunica, gridlight, bloom, flat, flatdark, ggplot2",
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

  if (length(overrides) > 0)
    highcharter::hc_theme_merge(base,
                                do.call(highcharter::hc_theme, overrides))
  else
    base
}

# -- ggplot2 theme builder ----------------------------------------------------

#' Resolve a ggplot2 Theme Object
#'
#' Returns a ggplot2 theme object from either a name string or a theme object
#' passed directly. Priority: explicit argument > session option
#' (`highdir.gg_theme`) > `"minimal"` fallback.
#'
#' Called automatically inside `ggplot_engine()`; useful when you want to
#' apply the package theme to a ggplot built outside highdir.
#'
#' Built-in name strings and their ggplot2 equivalents:
#'
#' | Name | ggplot2 function |
#' |:-----|:----------------|
#' | `"minimal"` (default) | `theme_minimal()` |
#' | `"classic"` | `theme_classic()` |
#' | `"bw"` | `theme_bw()` |
#' | `"light"` | `theme_light()` |
#' | `"dark"` | `theme_dark()` |
#' | `"void"` | `theme_void()` |
#' | `"grey"` / `"gray"` | `theme_grey()` |
#'
#' @param theme Character name string, ggplot2 theme object, or `NULL`.
#'   `NULL` reads from `getOption("highdir.gg_theme")`.
#'
#' @return A ggplot2 `theme` object.
#'
#' @examples
#' gg_theme()                          # reads session default
#' gg_theme("classic")                 # theme_classic()
#' gg_theme(ggplot2::theme_bw(base_size = 14))  # object passed directly
#'
#' @export
gg_theme <- function(theme = NULL) {

  resolved <- theme %||% getOption("highdir.gg_theme", default = "classic")

  # Already a theme object -- return as-is
  if (inherits(resolved, "theme"))
    return(resolved)

  # Name string -- look up in the built-in map
  if (!is.character(resolved) || length(resolved) != 1L)
    stop("`gg_theme` must be a single theme name string or a ggplot2 theme ",
         "object. Got: ", class(resolved)[1L], call. = FALSE)

  switch(resolved,
    "minimal" = ggplot2::theme_minimal(),
    "classic" = ggplot2::theme_classic(),
    "bw"      = ggplot2::theme_bw(),
    "light"   = ggplot2::theme_light(),
    "dark"    = ggplot2::theme_dark(),
    "void"    = ggplot2::theme_void(),
    "grey" = ,
    "gray"    = ggplot2::theme_grey(),
    stop("Unknown gg_theme name '", resolved, "'. ",
         "Use: minimal, classic, bw, light, dark, void, grey. ",
         "Or pass a ggplot2::theme_*() object directly.",
         call. = FALSE)
  )
}

# -- ggplot2 colour helper ----------------------------------------------------

#' Apply brand colours to a ggplot object
#'
#' Uses the same `resolve_colors()` priority chain as the highcharter
#' engine so both backends always produce identical colour assignments:
#'
#' 1. Explicit `colors` argument
#' 2. `getOption("highdir.colors")` session default
#' 3. Built-in rules: n==2 -> hdir2, n<=10 -> hdir[1:n], n>10 -> viridis
#'
#' @param p            A ggplot object.
#' @param colors       Character vector, palette name string, or NULL.
#' @param n_groups     Integer. Number of groups in the data. Drives which
#'   palette rule fires. Passed from `ggplot_engine()`.
#' @param group_levels Character vector or NULL. Group level names in data
#'   order. Used to name the palette so ggplot2 matches colours to groups
#'   by name rather than alphabetical sort.
#' @return The modified ggplot object.
#' @keywords internal
apply_gg_colors <- function(p,
                            colors       = NULL,
                            n_groups     = NULL,
                            group_levels = NULL) {

  # -- Resolve palette through the shared rule engine ------------------------
  if (!is.null(n_groups) && n_groups >= 1L) {
    pal <- resolve_colors(n_groups, colors)
  } else {
    candidate <- colors %||% getOption("highdir.colors", default = NULL)
    if (is.character(candidate) && length(candidate) == 1L &&
        candidate %in% list_palettes()) {
      candidate <- get_palette(candidate)
    }
    pal <- candidate
  }

  if (is.null(pal)) return(p)

  # -- Name the palette by group level in data order -------------------------
  if (!is.null(group_levels) &&
      length(pal) >= length(group_levels)) {
    pal <- stats::setNames(
      pal[seq_along(group_levels)],
      group_levels
    )
  }

  p +
    ggplot2::scale_color_manual(values = pal) +
    ggplot2::scale_fill_manual(values  = pal)
}


# -- JavaScript injection -----------------------------------------------------

#' Inject JavaScript into a Highcharts Widget
#'
#' Appends custom JavaScript to a `highchart` object via
#' `chart.events.<where>`.  Use this for hand-written callbacks and plugins.
#' For Highcharts built-in modules (accessibility, exporting, etc.) use
#' [highcharter::hc_add_dependency()] instead.
#'
#' Exactly one of `code`, `file`, or `plugin` must be supplied.
#'
#' @param hc     A `highchart` object.
#' @param code   Character or `NULL`. Raw JavaScript string.
#' @param file   Character or `NULL`. Path to a `.js` file to read and inject.
#' @param plugin Character or `NULL`. Name of a plugin bundled in `inst/js/`.
#' @param where  `"load"` (default) or `"render"`.
#'
#' @return The `highchart` object with JS injected.
#'
#' @examples
#' \dontrun{
#' spec <- hd_spec(mtcars, "wt", "mpg")
#' fig  <- hd_make(spec, "scatter")
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
        list.files(system.file("js", package = "highdir",
                               mustWork = FALSE)))
      stop("Plugin '", plugin, "' not found in inst/js/.",
           if (length(avail))
             paste0(" Available: ", paste(avail, collapse = ", ")),
           call. = FALSE)
    }
  }

  if (!is.null(file)) {
    if (!file.exists(file))
      stop("File not found: ", file, call. = FALSE)
    code <- paste(readLines(file, warn = FALSE), collapse = "\n")
  }

  if (is.null(code))
    stop("Supply one of `code`, `file`, or `plugin`.", call. = FALSE)

  hc |> highcharter::hc_chart(
    events = stats::setNames(list(htmlwidgets::JS(code)), where)
  )
}
