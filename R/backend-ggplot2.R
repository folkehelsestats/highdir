# ggplot2 engine ----------------------------------------------------
#
# Engine contract:
#   function(spec, geom, opts, geom_params, use_js, ...)
#
# Theme, colours, and font are resolved in one call to gg_theme() at the
# top of the engine -- mirroring how highcharter_engine() calls hd_theme()
# at the end.  Both follow the same priority chain:
#   explicit opts > session option > package default
#
# gg_theme() returns an hd_gg_theme object with:
#   $theme  -- ggplot2 theme object with font already merged in
#   $colors -- resolved colour vector (or NULL)
# gt$colors is then passed to apply_gg_colors() so colours flow through
# a single resolved value rather than being read from opts twice.

#' @keywords internal
ggplot_engine <- function(spec, geom, opts, geom_params,
                          use_js = TRUE, ...) {
  
  # -- Resolve theme + colors + font in one step (mirrors hd_theme() call) ---
  # Priority for each: explicit opts > getOption("highdir.*") > default
  gt <- gg_theme(opts$gg_theme, colors = opts$colors)
  # gt$theme  = ggplot2 theme object with font baked in
  # gt$colors = resolved colour vector used by apply_gg_colors() below

  # -- Self-contained geoms: bypass base_fig() entirely -----------------------
  #
  # Some geoms own their complete ggplot - they supply their own aes(),
  # scales, coord, and labs from scratch.  Passing them through base_fig()
  # would produce a phantom axis mapping (spec$x / spec$y) underneath the
  # geom's own mapping, leaving an artefact axis line visible after
  # coord_flip().
  #
  # Geoms in this category:
  #   skip_base_fig  - registered flag in the registry (e.g. choropleth maps)
  #   ranked_bar   - uses .xname (sorted factor) not spec$x; manages its own
  #                  coord_flip(), scale_x_discrete(), scale_y_continuous()
  #                  and labs() internally via the layer list it returns.
  #
  # These geoms receive single_colour via geom_params (same as standard path)
  # so colour resolution is consistent.  Theme, axis label hiding, and
  # accessibility alt text are still applied below after the early return.
  .self_contained <- isTRUE(geom$skip_base_fig)

  if (.self_contained) {
    # Inject single_colour so the geom can use the resolved brand colour
    single_colour              <- resolve_colors(1L, gt$colors)[1]
    geom_params$single_colour  <- single_colour
    
    layers <- geom$ggplot_fun(spec, opts, geom_params)

    # Special case: geom returned a complete ggplot object (e.g. ggVennDiagram).
    # Detect via the sentinel key "__ggplot__" and return it directly after
    # applying theme and accessibility.  No layer-by-layer assembly needed.
    # if (!is.null(layers[["__ggplot__"]])) {
    #    p <- layers[["__ggplot__"]] + gt$theme + ggplot2::theme_void()
    # if (!is.null(opts$description))
    #    p <- p + ggplot2::labs(alt = opts$description)
    # return(p)
    #  }

    if (inherits(layers, "ggplot")) {
      return(layers + gt$theme + ggplot2::theme_void())
    }
    
    p <- ggplot2::ggplot() +
      ggplot2::labs(
        title    = opts$title,
        subtitle = opts$subtitle,
        caption  = opts$caption
      )
    for (layer in layers) p <- p + layer

    # Apply theme + axis hiding + accessibility then return - no scale block
    p <- p + gt$theme
    if (is.null(opts$ylab))
      p <- p + ggplot2::theme(axis.title.y = ggplot2::element_blank())
    if (is.null(opts$xlab))
      p <- p + ggplot2::theme(axis.title.x = ggplot2::element_blank())
    if (!is.null(opts$description))
      p <- p + ggplot2::labs(alt = opts$description)

    return(p)
  }

  # -- Standard path: base_fig() builds canvas, engine adds layers ------------
  p <- base_fig(spec, opts, "static")

  # -- Colour + layers ---------------------------------------------------------
  grp_col <- spec$colour %||% spec$group

  if (!is.null(grp_col)) {
    # Multi-series: resolve palette from gt$colors (already priority-resolved)
    n_groups     <- length(unique(spec$data[[grp_col]]))
    group_levels <- as.character(unique(spec$data[[grp_col]]))

    layers <- geom$ggplot_fun(spec, opts, geom_params)
    for (layer in layers) p <- p + layer
    p <- apply_gg_colors(p,
                         colors       = gt$colors,
                         n_groups     = n_groups,
                         group_levels = group_levels)

  } else {
    # Single series: one brand colour injected as a fixed aesthetic
    single_colour              <- resolve_colors(1L, gt$colors)[1]
    geom_params$single_colour  <- single_colour

    layers <- geom$ggplot_fun(spec, opts, geom_params)
    for (layer in layers) p <- p + layer
  }


  # scale_y_continuous + coord_cartesian - two separate jobs:
  #
  #   scale_y_continuous(expand = ...) controls axis padding only.
  #   limits = ... is intentionally NOT set here.
  #
  #   Why: scale limits REMOVE data outside the range before geoms draw.
  #   A bar chart draws from y=0 (the baseline) up to the value.  If
  #   limits = c(25, 100) is set, the baseline y=0 is outside the range
  #   and ggplot2 drops the entire bar row silently, making columns
  #   disappear.  This is ggplot2's oob_censor default behaviour.
  #
  #   coord_cartesian(ylim = ...) ZOOMS the viewport AFTER the geom has
  #   drawn.  Bars are drawn from their true origin and then clipped at
  #   the viewport edge - this is always what users expect from ylim.
  if (is.numeric(spec$data[[spec$y]]) || is.integer(spec$data[[spec$y]])) {
    p <- p + ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0, .1))
    )
    if (!is.null(opts$ylim))
      p <- p + ggplot2::coord_cartesian(ylim = opts$ylim)
  }
  
  
  # -- Theme (per-figure opts$gg_theme > session default) --------------------
  # Applied last so it sits on top of every layer -- same position as
  # hd_theme() in highcharter_engine().  Font is already merged into gt$theme
  # by gg_theme(), so no separate font block is needed here.
  p <- p + gt$theme

  # -- Axis label hiding (applied AFTER theme) --------------------------------
  # .resolve_axis_label() in base_fig() already set opts$xlab / opts$ylab to
  # NULL when the user passed NULL.  We re-apply element_blank() here, AFTER
  # gt$theme, because many ggplot2 themes reset axis.title to their own
  # default, silently undoing the element_blank() that base_fig() set earlier.
  # Applying it last guarantees NULL -> hide regardless of theme choice.
  # This also covers geoms like ranked_bar that bypass base_fig() entirely.
  if (is.null(opts$ylab))
    p <- p + ggplot2::theme(axis.title.y = ggplot2::element_blank())
  if (is.null(opts$xlab))
    p <- p + ggplot2::theme(axis.title.x = ggplot2::element_blank())

  # Accessibility alt text - set via labs(alt = ...) (ggplot2 >= 3.3.0).
  # Rendered as an HTML alt attribute when the plot is included in
  # R Markdown / Quarto documents.  NULL leaves alt text unset.
  # But this is only when saved as SVG
  if (!is.null(opts$description))
    p <- p + ggplot2::labs(alt = opts$description)

  p
}
