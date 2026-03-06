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
                          use_js = TRUE,
                          module = TRUE, #only for hc but passed silently in backend engine
                          filename = NULL, ...) {

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

  layers <- geom$ggplot_fun(spec, opts, geom_params)

  # geom functions return a list of layers; + works element-wise on ggplots
  for (layer in layers) p <- p + layer

  p <- apply_gg_colors(p, opts$colors)

  font <- getOption("highdir.font", default = NULL)
  if (!is.null(font))
    p <- p + ggplot2::theme(text = ggplot2::element_text(family = font))

  p
}

