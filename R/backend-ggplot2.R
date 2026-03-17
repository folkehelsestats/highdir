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

  # ── Map geom: build from a blank ggplot (no axis mapping from base_fig) ──
  if (!is.null(geom$is_map_geom) && isTRUE(geom$is_map_geom)) {
    layers <- geom$ggplot_fun(spec, opts, geom_params)
    p <- ggplot2::ggplot() +
      ggplot2::labs(
        title    = opts$title,
        subtitle = opts$subtitle,
        caption  = opts$caption
      )
    for (layer in layers) p <- p + layer
    return(p)
  }

  p <- base_fig(spec, opts, "ggplot2")

  # -- Colour + layers ---------------------------------------------------------
  grp_col <- spec$colour %||% spec$group

  if (!is.null(grp_col)) {
    # Multi-series: resolve palette from gt$colors (already priority-resolved)
    n_groups     <- length(unique(spec$data[[grp_col]]))
    group_levels <- as.character(unique(spec$data[[grp_col]]))
    single_colour <- NULL

    layers <- geom$ggplot_fun(spec, opts, geom_params)
    for (layer in layers) p <- p + layer
    p <- apply_gg_colors(p,
                         colors       = gt$colors,
                         n_groups     = n_groups,
                         group_levels = group_levels)

  } else {
    # Single series: one brand colour injected as a fixed aesthetic
    single_colour          <- resolve_colors(1L, gt$colors)[1]
    geom_params$single_colour <- single_colour

    layers <- geom$ggplot_fun(spec, opts, geom_params)
    for (layer in layers) p <- p + layer
  }

  # No space below bars, 10% breathing room above
  if (is.numeric(spec$data[[spec$y]]) || is.integer(spec$data[[spec$y]]))
    p <- p + ggplot2::scale_y_continuous(
               expand = ggplot2::expansion(mult = c(0, .1)))

  # -- Theme (per-figure opts$gg_theme > session default) --------------------
  # Applied last so it sits on top of every layer -- same position as
  # hd_theme() in highcharter_engine().  Font is already merged into gt$theme
  # by gg_theme(), so no separate font block is needed here.
  p + gt$theme
}
