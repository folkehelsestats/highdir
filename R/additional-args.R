#
# Defines the full contract for every registered geometry:
#   required_args - columns the user MUST supply (e.g. ymin/ymax for arearange)
#   optional_args - arguments with sensible defaults (e.g. smooth, dot_size)
#
# HOW THIS FILE IS USED
#   .onLoad() in zzz.R iterates .geom_registry_defs and calls register_geom()
#   for each entry.  Because all R/*.R files are loaded into the package
#   namespace together, .onLoad() can reference .geom_registry_defs directly -
#   no source(), no file path, no environment tricks needed.
#
# ADDING A NEW GEOM
#   1. Add a new entry to .geom_registry_defs below.
#   2. Write gg_<name> and hc_<name> functions in their own R file.
#   3. That is all - zzz.R needs no changes.
#
# RULE OF THUMB: required vs optional
#   required  - geom cannot render at all without it  (e.g. ymin/ymax)
#   optional  - geom works fine with a built-in default (e.g. smooth = TRUE)

#' @keywords internal
.geom_registry_defs <- list(

  # column ---------------------------------------------------------------------
  column = list(
    ggplot_fun      = NULL,   # filled in .onLoad() after namespace is ready
    highcharter_fun = NULL,
    skip_base_fig   = FALSE, 
    required_args   = character(),
    optional_args   = list()
    # No optional_args: column has no extra knobs beyond spec / opts
  ),

  # line -----------------------------------------------------------------------
  line = list(
    ggplot_fun      = NULL,
    highcharter_fun = NULL,
    skip_base_fig   = FALSE, 
    optional_args   = list(
      smooth = list(
        default = TRUE,
        desc    = "Logical. TRUE = spline curves, FALSE = straight segments. Both backends.",
        mode_only = NULL # both modes support this argument
      ),
      dot_size = list(
        default = 4L,
        desc    = "Numeric. Marker radius in pixels. Both backends.",
        mode_only = NULL # both modes support this argument
      ),
      # line_symbols is highcharter-only; gg_line silently ignores it.
      line_symbols = list(
        default = NULL,
        desc    = paste0("Character vector. Highcharter only. Per-group marker shapes: ",
                         "'circle','square','diamond','triangle','triangle-down'."),
        mode_only = "dynamic"
      )
    )
  ),

  # scatter --------------------------------------------------------------------
  scatter = list(
    ggplot_fun      = NULL,
    highcharter_fun = NULL,
    skip_base_fig   = FALSE, 
    optional_args   = list(
      dot_size = list(
        default = 4L,
        desc    = "Numeric. Point size (ggplot2) or marker radius in px (highcharter).",
        mode_only = NULL # both modes support this argument
      )
    )
  ),

  # arearange ------------------------------------------------------------------
  arearange = list(
    ggplot_fun      = NULL,
    highcharter_fun = NULL,
    skip_base_fig   = FALSE, 
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
    skip_base_fig   = TRUE,
    optional_args   = list(
      inner_size = list(
        default = "0%",
        desc    = "Character. Inner radius as CSS %, e.g. '50%' for a donut",
        mode_only = "dynamic"
      ),
      value_suffix = list(
        default      = NULL,
        desc         = paste0(
          "Character. Symbol appended to displayed values. ",
          "E.g. '%' renders '42%' instead of '42'. ",
          "Applied in tooltips (dynamic) and region labels (static). ",
          "Both backends."
        ),
        mode_only = NULL
      )
    )
  ),

  # ranked_bar -----------------------------------------------------------------
  ranked_bar = list(
    ggplot_fun      = NULL,
    highcharter_fun = NULL,
    skip_base_fig   = TRUE,   # bypasses base_fig() - geom manages its own axes and labels
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
                         "decrease (e.g. 0.03) for smaller text. Default 0.045."),
        mode_only = "static"
      ),
      min_frac = list(
        default = 0.08,
        desc    = paste0("Numeric. Minimum fraction of the axis range a bar must span ",
                         "before its label fits inside. Safety floor for short labels. ",
                         "Default 0.08 (8%)."),
        mode_only = "static"
      )
    )
  ),

  stacked_column = list(
    ggplot_fun      = NULL,
    highcharter_fun = NULL,
    skip_base_fig   = FALSE, 
    required_args   = list(
      stack = list(
        default = NULL,
        desc    = "Character. Column name that assigns rows to stack groups.",
        mode_only = NULL # both modes require this argument
      )
    ),
    optional_args   = list(
      stacking = list(
        default = "normal",
        desc    = "Character. Highcharter stacking mode: 'normal' or 'percent'.",
        mode_only = "dynamic"
      )
    )
  ),

  # venn -----------------------------------------------------------------------
  # Venn / Euler diagrams require a different data contract from all other geoms.
  # Instead of spec$x / spec$y columns, the user supplies a pre-built list of
  # set entries via the `sets` argument in hd_geom_venn().  spec$data is not
  # used by hc_venn / gg_venn; it may be NULL or an empty data frame.
  #
  # Each entry in `sets` is a named list:
  #   list(sets = list("A"),        name = "Animals", value = 5)
  #   list(sets = list("A", "B"),                     value = 2)  # intersection
  #
  # ggplot2 backend: rendered via the ggVennDiagram or eulerr package
  #   (must be in Suggests).  Falls back to a text message if neither is
  #   installed, so the package does not gain a hard dependency.
  # highcharter backend: native hc_chart(type = "venn") series.
  venn = list(
    ggplot_fun      = NULL,
    highcharter_fun = NULL,
    skip_base_fig   = TRUE,   # bypasses base_fig() - no x/y axis canvas needed
    required_args   = list(),
    optional_args = list(
      sets = list(
        default = NULL,
        desc    = paste0(
          "List. Each element is a named list with slots:",
          "  sets  - character vector of set names for this entry",
          "         (length 1 = single set, length > 1 = intersection)",
          "  value - numeric size of this region",
          "  name  - optional character label shown in the diagram",
          "Example: list(",
          "  list(sets = list('A'), name = 'Animals', value = 5),",
          "  list(sets = list('B'), name = 'Four legs', value = 3),",
          "  list(sets = list('A','B'), value = 2)",
          ")"
        ),
        mode_only = NULL
      ),
      series_name = list(
        default      = "Venn Diagram",
        desc         = "Character. Series name shown in the chart title area. Highcharter only.",
        mode_only = "dynamic"
      ),
      label_font_size = list(
        default      = "14px",
        desc         = "Character. CSS font-size for set labels. Highcharter only.",
        mode_only = "dynamic"
      ),
      value_suffix = list(
        default      = "",
        desc         = paste0(
          "Character. Symbol appended to displayed values. ",
          "E.g. '%' renders '42%' instead of '42'. ",
          "Applied in tooltips (dynamic) and region labels (static). ",
          "Both backends."
        ),
        mode_only = NULL
      ),
      use_names = list(
        default      = FALSE,
        desc         = paste0(
          "Logical. When TRUE, the human-readable 'name' field from each set ",
          "entry is used as the circle label instead of the short id. ",
          "E.g. 'esig' instead of 'A'. ggplot2 only."
        ),
        mode_only = "static"
      ),
      show_legend = list(
        default      = FALSE,
        desc         = paste0(
          "Logical. When TRUE, adds a legend mapping circle colours to set ",
          "labels. ggplot2 only (eulerr and ggVennDiagram paths)."
        ),
        mode_only = "static"
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
