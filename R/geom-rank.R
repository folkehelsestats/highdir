# @param ascending Logical. If \code{TRUE} (default) bars are sorted in
#   ascending order of \code{y}.
# @param vs Character string (partial match) identifying one category to
#   highlight with a contrasting fill colour (\code{col2}). If omitted all
#   bars use \code{col1}.
# @param char_scale Numeric scaling factor that converts label character-count
#   into axis-range units. Controls how generously space is estimated for each
#   character. Defaults to \code{0.045}; increase (e.g. \code{0.06}) for
#   larger text sizes, decrease (e.g. \code{0.03}) for smaller ones.
# @param min_frac  Numeric. Minimum fraction of the axis range that a bar must
#   span before its label is considered to fit inside. Acts as a safety floor
#   for very short labels. Defaults to \code{0.08} (8 \%).

# --- ggplot2 ---------------------

#' @keywords internal
gg_ranked_bar <- function(spec, opts, geom_params) {

  # ── Extract params ──────────────────────────────────────────────────────────
  ascending  <- isTRUE(geom_params$ascending %||% TRUE)
  vs         <- geom_params$vs        %||% NULL   # character or NULL: vsarison group name
  aim        <- geom_params$aim         %||% NULL   # numeric or NULL: target line
  char_scale <- geom_params$char_scale  %||% 0.045
  min_frac   <- geom_params$min_frac    %||% 0.08
  sc         <- geom_params$single_colour  # verdien settes i engine
  
  # ── Resolve colours ─────────────────────────────────────────────────────────
  # col1: default bar colour (single series or non-highlighted bars)
  # col2: highlighted comparison bar colour
  # Both come from the hdir palette so they stay on-brand.
  pal  <- resolve_colors(2L, NULL)   # always need 2: default + highlight
  col1 <- sc %||% pal[1]            # single_colour overrides if set
  col2 <- pal[2]

  # ── Build working data ──────────────────────────────────────────────────────
  # Work on a copy — do not mutate spec$data
  d        <- spec$data
  x_col    <- spec$x
  y_col    <- spec$y

  # Append N to x labels if spec$n is set
  # spec$n mirrors the `num` argument from the original regbar function
  if (!is.null(spec$n)) {
    d$.xname <- sprintf("%s (N=%s)", d[[x_col]], d[[spec$n]])
  } else {
    d$.xname <- as.character(d[[x_col]])
  }

  # ── Smart label placement ───────────────────────────────────────────────────
  # Mirrors the original regbar logic exactly.
  # ypos = 1 → label inside bar (bar is long enough)
  # ypos = 0 → label outside bar (bar too short)
  y_range     <- max(d[[y_col]]) - min(0, min(d[[y_col]]))
  label_chars <- nchar(as.character(d[[y_col]]))
  label_width <- label_chars * char_scale * y_range
  threshold   <- pmax(label_width, min_frac * y_range)
  d$ypos      <- ifelse(d[[y_col]] > threshold, 1L, 0L)

  # ── Sort bars ───────────────────────────────────────────────────────────────
  if (ascending) {
    d$.xname <- factor(d$.xname,
                        levels = d$.xname[order(d[[y_col]])])
  } else {
    d$.xname <- factor(d$.xname,
                        levels = d$.xname[order(d[[y_col]], decreasing = TRUE)])
  }

  # ── Resolve comparison highlight ────────────────────────────────────────────
  # vs matches against the original x column (before N= appending)
  # so the user passes the raw category name e.g. vs = "Oslo"
  use_vs <- !is.null(vs) && nzchar(vs)
  if (use_vs) {
    vs_match  <- d$.xname[grepl(vs, d[[x_col]], fixed = TRUE)]
    d$.is_vs  <- d$.xname %in% vs_match
    bar_fill_aes <- ggplot2::aes(fill = .data[[".is_vs"]])
    fill_scale   <- ggplot2::scale_fill_manual(
      values = c("FALSE" = col1, "TRUE" = col2),
      guide  = "none"
    )
  } else {
    bar_fill_aes <- NULL
    fill_scale   <- NULL
  }
  
  # ── Split data for inside / outside labels ──────────────────────────────────
  inside  <- d[d$ypos == 1L, , drop = FALSE]
  outside <- d[d$ypos == 0L, , drop = FALSE]

  # ── Build layer list ────────────────────────────────────────────────────────
  pos  <- ggplot2::position_dodge(width = 0.80)
  wdth <- 0.80

  layers <- list()

  # Aim line (drawn first so it sits behind bars)
  if (!is.null(aim)) {
    layers <- c(layers, list(
      ggplot2::geom_hline(
        yintercept = aim,
        colour     = resolve_colors(3L, NULL)[3],   # hdir[3] for contrast
        linewidth  = 1,
        linetype   = "dashed"
      )
    ))
  }

  # Bars
  if (use_vs) {
    layers <- c(layers, list(
      ggplot2::geom_bar(
        data     = d,
        mapping  = ggplot2::aes(x = .data[[".xname"]],
                                y = .data[[y_col]],
                                fill = .data[[".is_vs"]]),
        width    = wdth,
        stat     = "identity",
        position = pos
      )
    ))
  } else {
    layers <- c(layers, list(
      ggplot2::geom_bar(
        data    = d,
        mapping = ggplot2::aes(x = .data[[".xname"]],
                               y = .data[[y_col]]),
        width   = wdth,
        stat    = "identity",
        fill    = col1,
        position = pos
      )
    ))
  }

  # Inside labels
  if (nrow(inside) > 0) {
    layers <- c(layers, list(
      ggplot2::geom_text(
        data     = inside,
        mapping  = ggplot2::aes(x     = .data[[".xname"]],
                                y     = .data[[y_col]],
                                label = .data[[y_col]]),
        hjust    = 1.5,
        position = pos,
        size     = 3.5,
        colour   = "#FFFFFF"
      )
    ))
  }

  # Outside labels
  if (nrow(outside) > 0) {
    layers <- c(layers, list(
      ggplot2::geom_text(
        data     = outside,
        mapping  = ggplot2::aes(x     = .data[[".xname"]],
                                y     = .data[[y_col]],
                                label = .data[[y_col]]),
        hjust    = -0.5,
        position = pos,
        size     = 3.5,
        colour   = "#555555"
      )
    ))
  }

  # Fill scale for comparison highlighting
  if (!is.null(fill_scale))
    layers <- c(layers, list(fill_scale))

  # ── Scales, coord, labels ────────────────────────────────────────────────────
  # ranked_bar bypasses base_fig() entirely (engine detects geom$name ==
  # "ranked_bar" and skips base_fig).  Therefore it owns ALL ggplot2
  # infrastructure: scales, coord_flip, and labs.

  # Discrete x scale for the sorted .xname factor
  layers <- c(layers, list(
    ggplot2::scale_x_discrete()
  ))

  # Continuous y scale — padding only, no limits.
  #
  # IMPORTANT: limits = ... is intentionally NOT set here.
  # scale_y_continuous(limits) removes data outside the range BEFORE
  # geoms draw.  For bar charts this drops entire rows because the bar
  # baseline (y = 0) is outside the user's range, making bars disappear.
  # ylim is handled by the coord object below (zooms after drawing).
  layers <- c(layers, list(
    ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0, 0.12))
    )
  ))
 
  # Coord — ONE object handles both flip and ylim zoom.
  #
  # ggplot2 allows only one coord per plot.  Adding coord_cartesian() and
  # coord_flip() as separate layers triggers:
  #   "Coordinate system already present. Adding new coordinate system,
  #    which will replace the existing one."
  # and the second coord silently replaces the first — flip is lost when
  # ylim is set, or the ylim zoom is lost when flip replaces cartesian.
  #
  # Solution: coord_flip(ylim = ...) collapses both into one object.
  #   flip=TRUE  + ylim set  → coord_flip(ylim = opts$ylim)
  #   flip=TRUE  + no ylim   → coord_flip()           [ylim=NULL is safe]
  #   flip=FALSE + ylim set  → coord_cartesian(ylim = opts$ylim)
  #   flip=FALSE + no ylim   → NULL (ggplot2 uses default CartesianCoord)
  do_flip  <- isTRUE(opts$flip %||% TRUE)
  has_ylim <- !is.null(opts$ylim)
 
  coord_layer <- if (do_flip) {
    ggplot2::coord_flip(ylim = opts$ylim)      # ylim=NULL is safe here
  } else if (has_ylim) {
    ggplot2::coord_cartesian(ylim = opts$ylim)
  } else {
    NULL
  }
 
  if (!is.null(coord_layer))
    layers <- c(layers, list(coord_layer))
 
  # Axis labels — opts$xlab / opts$ylab used directly (NULL -> element_blank
  # applied by the engine after theme is set).
  layers <- c(layers, list(
    ggplot2::labs(
      x = opts$xlab,
      y = opts$ylab
    )
  ))

  layers
}


# Highcharter ---------------

#' @keywords internal
hc_ranked_bar <- function(chart, spec, opts, geom_params,
                          use_js = TRUE, ...) {

  ascending  <- isTRUE(geom_params$ascending %||% TRUE)
  vs         <- geom_params$vs               %||% NULL   # character or NULL: vsarison group name
  aim        <- geom_params$aim              %||% NULL   # numeric or NULL: target line

  d     <- spec$data
  x_col <- spec$x
  y_col <- spec$y

  # .xname is always the plain category label.
  # N is attached to each point's data object for the tooltip only.
  d$.xname <- as.character(d[[x_col]])

  # Sort by value
  ord <- order(d[[y_col]], decreasing = !ascending)
  d   <- d[ord, ]

  # Colours
  pal  <- resolve_colors(2L, opts$colors)
  col1 <- pal[1]
  col2 <- pal[2]

  # ── Highlight comparison bar ------------------------------------------------
  # grepl must only be called when vs is a non-NULL non-empty string.
  # The & operator in ifelse() does NOT short-circuit, so
  # ifelse(use_vs & grepl(vs, ...), ...) evaluates grepl(NULL, ...)
  # when comp is NULL → "invalid 'pattern' argument" error.
  use_vs <- !is.null(vs) && nzchar(vs)

  if (use_vs) {
    is_vs    <- grepl(vs, d[[x_col]], fixed = TRUE)
    colors_vec <- ifelse(is_vs, col2, col1)
  } else {
    colors_vec <- rep(col1, nrow(d))
  }

  # Each point carries separate fields for name, y, and n_obs.
  # The tooltip pointFormat references {point.name}, {point.y},
  # and {point.n_obs} individually — Highcharts renders them cleanly
  # without cluttering the axis label.
  # n_obs is only added to the point when spec$n is set.
  point_data <- lapply(seq_len(nrow(d)), function(i) {
    pt <- list(
      name  = d$.xname[i],
      y     = d[[y_col]][i],
      color = colors_vec[i]
    )
    if (!is.null(spec$n)) {
      pt$n_obs <- d[[spec$n]][i]
    }
    pt
  })

  # x categories in sorted order (plain labels, no N= suffix)
  chart <- chart |>
    highcharter::hc_xAxis(
      categories = d$.xname,
      title      = list(text = opts$xlab)
    )

  # Aim line as plot line on y-axis
  if (!is.null(aim)) {
    chart <- chart |>
      highcharter::hc_yAxis(
        plotLines = list(list(
          value     = aim,
          color     = resolve_colors(3L, opts$colors)[3],
          width     = 2,
          dashStyle = "Dash",
          zIndex    = 5
        ))
      )
  }

  # Ranked_bar sets its own tooltip via hc_tooltip() here.
  # This overrides the engine-level tooltip for this geom only.
  # pointFormat shows value and — when spec$n is set — N on a
  # second line. When spec$n is NULL the N line is omitted entirely.
  point_fmt <- if (!is.null(spec$n)) {
    paste0(
      '<span style="color:{point.color}">\u25CF</span> ',
      '<b>{point.name}</b><br/>',
      opts$ylab %||% y_col, ': <b>{point.y}</b><br/>',
      'N: <b>{point.n_obs}</b>'
    )
  } else {
    paste0(
      '<span style="color:{point.color}">\u25CF</span> ',
      '<b>{point.name}</b><br/>',
      opts$ylab %||% y_col, ': <b>{point.y}</b>'
    )
  }

  chart <- chart |>
    highcharter::hc_tooltip(
      useHTML      = TRUE,
      shared       = FALSE,   # ranked bar: one bar per hover, not shared
      headerFormat = "",      # name already in pointFormat
      pointFormat  = point_fmt
    )

  # Add series
  # DataLabels disabled entirely. Value and N both live in
  # the tooltip which is always readable regardless of bar length.
  #
  # Highcharts series type vs flip:
  #   type = "bar"    is natively horizontal — ignores hc_chart(inverted).
  #   type = "column" is natively vertical   — respects hc_chart(inverted).
  #
  # base_fig() sets hc_chart(inverted = isTRUE(opts$flip)).
  # For ranked_bar we always use type = "column" and rely on inverted to
  # control orientation — this makes flip = TRUE/FALSE work correctly.
  #
  #   flip = TRUE  (default) -> inverted = TRUE  -> horizontal bars
  #   flip = FALSE           -> inverted = FALSE -> vertical bars
  chart <- chart |>
    highcharter::hc_chart(inverted = isTRUE(opts$flip %||% TRUE)) |>
    highcharter::hc_add_series(
      type         = "column",
      name         = opts$ylab %||% y_col,
      data         = point_data,
      showInLegend = FALSE,
      dataLabels   = list(enabled = FALSE)
    )

  chart
}

## -----------------------------------------------------------------------------
## Public constructor for ranked bar geometry
## -----------------------------------------------------------------------------

#' Ranked bar geometry
#'
#' Draws a ranked bar chart with smart label placement and optional comparison
#' highlighting.  Bars are sorted by value, and labels are placed inside or
#' outside the bar depending on available space.  A single category can be
#' highlighted with a contrasting fill colour, and an optional horizontal line
#' can be added to indicate a target or benchmark value.
#'
#' @param ascending Logical. If `TRUE` (default) bars are sorted in
#'  ascending order of `y`.
#' @param vs Character string (partial match) identifying one category to
#'  highlight with a contrasting fill colour. If omitted all bars use the same
#'  colour.
#' @param aim Numeric. Optional horizontal line indicating a target or benchmark
#'  value.  If `NULL` (default) no line is drawn.
#' @param char_scale Numeric scaling factor that converts label character-count
#'  into axis-range units. Controls how generously space is estimated for each
#'  character. Defaults to `0.045`; increase (e.g. `0.06`0.06)
#'  for larger text sizes, decrease (e.g. `0.03`) for smaller ones.
#' @param min_frac  Numeric. Minimum fraction of the axis range that a bar must
#'  span before its label is considered to fit inside. Acts as a safety floor
#'  for very short labels. Defaults to `0.08` (8%).
#' @inheritParams hd_geom_column
#'
#' @return An S3 object of class `"hd_geom"` for use with `+.hd`.
#'
#' @examples
#' # Regional health indicator dataset
#' regions <- data.frame(
#'   region = c("Oslo", "Viken", "Vestland", "Rogaland",
#'              "Trondelag", "Innlandet", "Agder",
#'              "Nordland", "Troms og Finnmark"),
#'   rate   = c(68.4, 71.2, 87.8, 64.5, 61.3, 6.1, 54.2, 49.8, 42.1),
#'   n      = c(402, 448, 681, 318, 297, 251, 198, 177, 148)
#' )
#'
#' # Declarative API ----
#' spec_rb <- hd_spec(regions,
#'                   x    = "region",
#'                   y    = "rate",
#'                   n    = "n")
#'
#' opts_rb <- hd_opts(
#'  title    = "Health indicator by region",
#'  subtitle = "Source: Norwegian Directorate of Health",
#'  ylab     = "Rate per 100 000",
#'  flip     = TRUE
#' )
#'
#' hd_make(spec_rb, "ranked_bar", opts_rb, ascending = TRUE, vs = "Oslo", aim = 63)
#'
#' # Layered API ----
#' hd(regions, x = "region", y = "rate", n = "n", backend = "ggplot2") +
#'  hd_geom_ranked_bar(
#'   ascending  = TRUE,
#'   vs         = "Oslo",
#'   aim        = 63,
#'   char_scale = 0.045,
#'   min_frac   = 0.08) +
#'  hd_opts(
#'  title    = "Health indicator by region",
#'  subtitle = "Source: Norwegian Directorate of Health",
#'  ylab     = "Rate per 100 000",
#'  flip     = TRUE
#' )
#'
#' @family Geoms
#' @seealso [hd_geom_column()], [hd_geom_line()], [hd_geom_arearange()],
#'  [hd_opts()], [hd_make()]
#'
#' @export
hd_geom_ranked_bar <- function(ascending = TRUE,
                               vs = NULL,
                               aim = NULL,
                               char_scale = 0.045,
                               min_frac = 0.08, ...) {
  hd_geom("ranked_bar",
          ascending = ascending,
          vs = vs,
          aim = aim,
          char_scale = char_scale,
          min_frac = min_frac, ...)
}
