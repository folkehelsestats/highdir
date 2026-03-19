#
# Defines the full contract for every registered geometry:
#   required_args — columns the user MUST supply (e.g. ymin/ymax for arearange)
#   optional_args — arguments with sensible defaults (e.g. smooth, dot_size)
#
# HOW THIS FILE IS USED
#   .onLoad() in zzz.R iterates .geom_registry_defs and calls register_geom()
#   for each entry.  Because all R/*.R files are loaded into the package
#   namespace together, .onLoad() can reference .geom_registry_defs directly —
#   no source(), no file path, no environment tricks needed.
#
# ADDING A NEW GEOM
#   1. Add a new entry to .geom_registry_defs below.
#   2. Write gg_<name> and hc_<name> functions in their own R file.
#   3. That is all — zzz.R needs no changes.
#
# RULE OF THUMB: required vs optional
#   required  — geom cannot render at all without it  (e.g. ymin/ymax)
#   optional  — geom works fine with a built-in default (e.g. smooth = TRUE)

#' @keywords internal
.geom_registry_defs <- list(

  # column ---------------------------------------------------------------------
  column = list(
    ggplot_fun      = NULL,   # filled in .onLoad() after namespace is ready
    highcharter_fun = NULL,
    required_args   = character(),
    optional_args   = list()
    # No optional_args: column has no extra knobs beyond spec / opts
  ),

  # line -----------------------------------------------------------------------
  line = list(
    ggplot_fun      = NULL,
    highcharter_fun = NULL,
    optional_args   = list(
      smooth = list(
        default = TRUE,
        desc    = "Logical. TRUE = spline curves, FALSE = straight segments. Both backends."
      ),
      dot_size = list(
        default = 4L,
        desc    = "Numeric. Marker radius in pixels. Both backends."
      ),
      # line_symbols is highcharter-only; gg_line silently ignores it.
      line_symbols = list(
        default = NULL,
        desc    = paste0("Character vector. Highcharter only. Per-group marker shapes: ",
                         "'circle','square','diamond','triangle','triangle-down'.")
      )
    )
  ),

  # scatter --------------------------------------------------------------------
  scatter = list(
    ggplot_fun      = NULL,
    highcharter_fun = NULL,
    optional_args   = list(
      dot_size = list(
        default = 4L,
        desc    = "Numeric. Point size (ggplot2) or marker radius in px (highcharter)."
      )
    )
  ),

  # arearange ------------------------------------------------------------------
  arearange = list(
    ggplot_fun      = NULL,
    highcharter_fun = NULL,
    required_args   = list(
      ymin = list(
        default = NULL,
        desc    = "Character. Column name for the lower bound of the range."
      ),
      ymax = list(
        default = NULL,
        desc    = "Character. Column name for the upper bound of the range."
      )
    ),
    optional_args   = list()
  ),

  # pie ------------------------------------------------------------------------
  pie = list(
    ggplot_fun      = NULL,
    highcharter_fun = NULL,
    optional_args   = list(
      inner_size = list(
        default = "0%",
        desc    = "Character. Inner radius as CSS %, e.g. '50%' for a donut. Both backends."
      )
    )
  ),

  # ranked_bar -----------------------------------------------------------------
  ranked_bar = list(
    ggplot_fun      = NULL,
    highcharter_fun = NULL,
    optional_args   = list(
      ascending = list(
        default = TRUE,
        desc    = "Logical. TRUE = lowest bar at bottom, FALSE = highest at bottom. Both backends."
      ),
      vs = list(
        default = NULL,
        desc    = "Character. Category name to highlight with a second colour. Both backends."
      ),
      aim = list(
        default = NULL,
        desc    = "Numeric. Value for a dashed target/aim line. Both backends."
      ),
      char_scale = list(
        default = 0.045,
        desc    = paste0("Numeric. Scaling factor converting label character-count into ",
                         "axis-range units. Increase (e.g. 0.06) for larger text, ",
                         "decrease (e.g. 0.03) for smaller text. Default 0.045.")
      ),
      min_frac = list(
        default = 0.08,
        desc    = paste0("Numeric. Minimum fraction of the axis range a bar must span ",
                         "before its label fits inside. Safety floor for short labels. ",
                         "Default 0.08 (8%).")
      )
    )
  )

  # map ------------------------------------------------------------------------
  # map = list(                                                                       #
  #   ggplot_fun      = NULL,                                                         #
  #   highcharter_fun = NULL,                                                         #
  #   is_map_geom     = TRUE,                                                         #
  #   optional_args   = list(                                                         #
  #     level = list(                                                                 #
  #       default = "county",                                                         #
  #       desc    = "Character. Map granularity: 'county' or 'municipality'."         #
  #     ),                                                                            #
  #     value_lab = list(                                                             #
  #       default = NULL,                                                             #
  #       desc    = "Character. Colour scale legend label. Defaults to spec$ylab."    #
  #     ),                                                                            #
  #     low_col = list(                                                               #
  #       default = "#C6DBEF",                                                        #
  #       desc    = "Character. Hex colour for the low end of the choropleth scale."  #
  #     ),                                                                            #
  #     high_col = list(                                                              #
  #       default = "#025169",                                                        #
  #       desc    = "Character. Hex colour for the high end of the choropleth scale." #
  #     ),                                                                            #
  #     na_fill = list(                                                               #
  #       default = "#D3D3D3",                                                        #
  #       desc    = "Character. Hex fill colour for regions with no data."            #
  #     )                                                                             #
  #   )                                                                               #
  # )                                                                                 #

)
