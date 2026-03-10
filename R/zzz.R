#
# All register_geom() calls live here so there is one place to see every
# geometry's full contract: required_args (must supply), optional_args
# (have defaults, may omit).
#
# The optional_args field is what eg. geom_args("line") prints for the user.
# Each entry is list(default = <value>, desc = "<short string>").
# The geom function itself applies the default via `geom_params$key %||%
# default` — the registry entry is informational only, not enforced.
#
# Rule of thumb for what goes in optional_args vs required_args:
#   required  — the geom cannot render at all without it (e.g. ymin/ymax)
#   optional  — the geom works fine with a built-in default (e.g. smooth)

#' @keywords internal
.onLoad <- function(libname, pkgname) {

  # ── Built-in colour palettes ───────────────────────────────────────────────
  register_palette("hdir", c(
    "#025169", "#0069E8",
    "#7C145C", "#047FA4",
    "#C68803", "#38A389",
    "#6996CE", "#366558",
    "#BF78DE", "#767676"
  ))

  # hdir2: two-colour palette for binary group comparisons
  ## register_palette("hdir2", c("rgba(49,101,117,1)", "rgba(138,41,77,1)")) ##
  register_palette("hdir2", c("#315975", "#8A294D"))

  # ── Backends ──────────────────────────────────────────────────────────────
  register_backend("ggplot2",     ggplot_engine)
  register_backend("highcharter", highcharter_engine)

  # ── Geometries ────────────────────────────────────────────────────────────

  register_geom("column",
    ggplot_fun      = gg_column,
    highcharter_fun = hc_column
    # No optional_args: column has no extra knobs beyond spec/opts
  )

  register_geom("line",
    ggplot_fun      = gg_line,
    highcharter_fun = hc_line,
    # optional_args documents every key that gg_line / hc_line reads from
    # geom_params.  Users discover these by calling geom_args("line").
    optional_args = list(
      smooth = list(
        default = TRUE,
        desc    = "Logical. TRUE = spline curves, FALSE = straight segments. Both backends."
      ),
      dot_size = list(
        default = 4,
        desc    = "Numeric. Marker radius in pixels. Both backends."
      ),
      # line_symbols is listed as highcharter-only because gg_line ignores it;
      # but passing it to the ggplot2 backend is harmless (silently ignored).
      line_symbols = list(
        default = NULL,
        desc    = paste0("Character vector. Highcharter only. Per-group marker shapes: ",
                         "'circle','square','diamond','triangle','triangle-down'."
                         )
      )
    )
    )

  register_geom("scatter",
    ggplot_fun      = gg_scatter,
    highcharter_fun = hc_scatter,
    optional_args   = list(
      dot_size = list(
        default = 4,
        desc    = "Numeric. Point size (ggplot2) or marker radius in px (highcharter)."
      )
    )
  )

  register_geom("arearange",
    ggplot_fun      = gg_arearange,
    highcharter_fun = hc_arearange,
    # ymin and ymax are required — the geom cannot render without them.
    # They are passed via ... in hd_make() like any other geom arg.
    required_args   = c("ymin", "ymax")
    # No optional_args for arearange currently.
  )

  register_geom("pie",
    ggplot_fun      = gg_pie,
    highcharter_fun = hc_pie,
    optional_args   = list(
      inner_size = list(
        default = "0%",
        desc    = "Character. Inner radius as CSS %, e.g. '50%' for a donut. Both backends."
      )
    )
  )

  register_geom("ranked_bar",
    ggplot_fun      = gg_ranked_bar,
    highcharter_fun = hc_ranked_bar,
    optional_args   = list(
      ascending = list(
        default = TRUE,
        desc    = "Logical. TRUE = lowest bar at bottom, FALSE = highest at bottom. Both backends."
      ),
      comp = list(
        default = NULL,
        desc    = "Character. Category name to highlight with a second colour. Both backends."
      ),
      aim = list(
        default = NULL,
        desc    = "Numeric. Value for a dashed target/aim line. Both backends."
      ),
      char_scale = list(
        default = 0.045,
        desc = paste0("Numeric scaling factor that converts label character-count",
                      "into axis-range units. Controls how generously space is estimated for each",
                      "character. Defaults to 0.045; increase (e.g. 0.06) for",
                      "larger text sizes, decrease (e.g. 0.03) for smaller ones.")
      ),
      min_frac = list(
        default = 0.08,
        desc = paste0("Numeric. Minimum fraction of the axis range that a bar must",
                      "span before its label is considered to fit inside. Acts as a safety floor",
                      "for very short labels. Defaults to 0.08 (8%).")
      ),
      flip = list(
        default = TRUE,
        desc    = "Logical. TRUE = horizontal bars (default for ranked_bar). ggplot2 only."
      )
    )
  )


  # ── Option defaults ────────────────────────────────────────────────────────
  op     <- options()
  to_set <- .hd_defaults[!names(.hd_defaults) %in% names(op)]
  if (length(to_set)) options(to_set)

  invisible()
}
