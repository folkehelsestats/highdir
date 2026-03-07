#
# Engine contract:
#   function(spec, geom, opts, geom_params, use_js, filename, ...)
#
# `geom_params` is a named list built by hd_make() that carries *all*
# geom-specific arguments (smooth, dot_size, line_symbols, ymin, ymax, …).
# Passing them as an explicit list instead of bare `...` means:
#   1. The engine signature is stable regardless of how many geoms exist.
#   2. Nothing unexpected leaks into hc_add_series() causing tibble errors.

# ── ggplot2 engine ───────────────────────────────────────────────────────────

#' @keywords internal
ggplot_engine <- function(spec,
                          geom,
                          opts,
                          geom_params,
                          use_js   = TRUE,
                          module   = TRUE,
                          filename = NULL, ...) {

  # ---- Map geom -------------------------------------------------
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

  p      <- base_fig(spec, opts, "ggplot2")
  layers <- geom$ggplot_fun(spec, opts, geom_params)
  for (layer in layers) p <- p + layer

  # ── Count groups so resolve_colors() applies the right rule ──────────────
  # grp_col mirrors the same logic as .base_constructors[[ggplot2]] uses
  # for the colour/group aesthetic — spec$colour takes priority over
  # spec$group, exactly as the canvas mapping does.
  grp_col <- spec$colour %||% spec$group

  n_groups <- if (!is.null(grp_col)) {
    length(unique(spec$data[[grp_col]]))
  } else {
    1L
  }

  # Group levels in data order — used to name the palette vector so
  # ggplot2 maps colours by name rather than by alphabetical sort order
  group_levels <- if (!is.null(grp_col)) {
    as.character(unique(spec$data[[grp_col]]))
  } else {
    NULL
  }

  p <- apply_gg_colors(p,
                       colors       = opts$colors,
                       n_groups     = n_groups,
                       group_levels = group_levels)

  # ── Font ──────────────────────────────────────────────────────────────────
  font <- getOption("highdir.font", default = NULL)
  if (!is.null(font))
    p <- p + ggplot2::theme(text = ggplot2::element_text(family = font))

  p
}
