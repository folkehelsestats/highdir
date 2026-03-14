# ggplot2 engine ----------------------------------------------------
#
# Engine contract:
#   function(spec, geom, opts, geom_params, use_js, ...)
#
# `geom_params` is a named list built by hd_make() that carries *all*
# geom-specific arguments (smooth, dot_size, line_symbols, ymin, ymax, …).
# Passing them as an explicit list instead of bare `...` means:
#   1. The engine signature is stable regardless of how many geoms exist.
#   2. Nothing unexpected leaks into hc_add_series() causing tibble errors.


#' @keywords internal
ggplot_engine <- function(spec, geom, opts, geom_params,
                           use_js = TRUE, ...) {

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

  # ── Resolve colour before handing off to the geom ────────────────────────
  grp_col <- spec$colour %||% spec$group

  if (!is.null(grp_col)) {
    # Multi-series: resolve palette, pass the full vector
    # geom functions use it via scale_fill_manual / scale_color_manual
    n_groups     <- length(unique(spec$data[[grp_col]]))
    group_levels <- as.character(unique(spec$data[[grp_col]]))
    single_colour <- NULL   # not used for multi-series

    layers <- geom$ggplot_fun(spec, opts, geom_params)
    for (layer in layers) p <- p + layer
    p <- apply_gg_colors(p,
                         colors       = opts$colors,
                         n_groups     = n_groups,
                         group_levels = group_levels)

  } else {
    # Single series: resolve exactly one colour and inject at layer level
    # resolve_colors(1, ...) returns hdir[1] by default — the brand teal
    single_colour <- resolve_colors(1L, opts$colors)[1]

    # Pass single_colour into geom_params so the geom function can use it
    # as a fixed fill/colour argument — NOT as a mapped aesthetic
    geom_params$single_colour <- single_colour

    layers <- geom$ggplot_fun(spec, opts, geom_params)
    for (layer in layers) p <- p + layer
    # No apply_gg_colors call for single series — colour is already in layers
  }

  # -- ggplot2 theme (per-figure opts$gg_theme > session default) ------------
  # gg_theme() resolves: theme object passed directly OR name string OR
  # session option "highdir.gg_theme" OR fallback "minimal".
  p <- p + gg_theme(opts$gg_theme)

  # No space below the bars but 10% above them
  if (is.numeric(spec$data[[spec$y]]) || is.integer(spec$data[[spec$y]]))
    p <- p + ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, .1)))

  # Font applied on top of the theme so it overrides the theme's font choice.
  font <- getOption("highdir.font", default = NULL)
  if (!is.null(font))
    p <- p + ggplot2::theme(text = ggplot2::element_text(family = font))

  p
}
