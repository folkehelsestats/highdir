#' @keywords internal
gg_stacked_column <- function(spec, opts, geom_params) {

  # required args --------------------------------------------------------------
  stack_col <- geom_params$stack

  # optional args ----------------------------------------------------------------
  grp_col   <- spec$group

  if (is.null(grp_col))
    stop("stacked_column requires a group column in hd_spec().", call. = FALSE)

  list(
    ggplot2::geom_bar(
      stat     = "identity",
      position = "stack",
      width    = 0.7
    ),
    ggplot2::facet_wrap(
      stats::as.formula(paste("~", stack_col)),
      nrow   = 1,
      scales = "free_x"
    ),
    # Remove the x-axis tick labels inside facets — the facet strip
    # title already labels each stack group
    ggplot2::theme(axis.text.x = ggplot2::element_blank())
  )
}

#' @keywords internal
hc_stacked_column <- function(chart, spec, opts, geom_params,
                              use_js = TRUE, ...) {

  # Required args ----------------------------------------------------------------
  stack_col <- geom_params$stack

  # Optional args ----------------------------------------------------------------
  stacking  <- geom_params$stacking %||% "normal"

  d       <- spec$data
  x_col   <- spec$x
  y_col   <- spec$y
  grp_col <- spec$group

  if (is.null(grp_col))
    stop("stacked_column requires a group column in hd_spec().", call. = FALSE)
  if (is.null(stack_col))
    stop("stacked_column requires `stack` argument naming the stack column.",
         call. = FALSE)

  # Enable stacking for all column series
  chart <- chart |>
    highcharter::hc_plotOptions(column = list(stacking = stacking))

#   chart <- chart |>
#   highcharter::hc_tooltip(
#     useHTML = TRUE,
#     format  = paste0(
#       "<b>{key}</b><br/>",
#       "{series.name}: {y}<br/>",
#       "Total: {point.stackTotal}"
#     )
#   )

  # ── Key insight: iterate every unique (series, stack) combination ──────────
  # The same series name can appear in multiple stacks (as in your example).
  # Each unique pair produces one hc_add_series() call with its own stack id.
  # Highcharts separates the stacks visually; the legend shows unique names.
  combos <- unique(d[, c(grp_col, stack_col), drop = FALSE])
  pal    <- resolve_colors(length(unique(d[[grp_col]])), opts$colors)

  # Named palette so same series name always gets the same colour across stacks
  series_names  <- unique(d[[grp_col]])
  color_by_name <- stats::setNames(pal, series_names)

  for (i in seq_len(nrow(combos))) {
    series_name <- combos[[grp_col]][i]
    stack_id    <- combos[[stack_col]][i]

    # Rows belonging to this (series, stack) pair, in x-axis order
    mask <- d[[grp_col]] == series_name & d[[stack_col]] == stack_id
    rows <- d[mask, , drop = FALSE]

    # Align to x-axis categories (base_fig sets categories = unique(x))
    # Missing categories get NA so the series stays aligned
    x_cats <- unique(d[[x_col]])
    values  <- rows[[y_col]][match(x_cats, rows[[x_col]])]

    chart <- chart |>
      highcharter::hc_add_series(
        name  = series_name,
        type  = "column",
        data  = as.list(values),
        stack = stack_id,
        color = color_by_name[[series_name]],
        # Suppress duplicate legend entries for series that appear in
        # multiple stacks — Highcharts shows the name once per unique name
        showInLegend = !duplicated(combos[[grp_col]])[i]
      )
  }

  chart
}


## -----------------------------------------------------------------------------
## Public geom constructor
## -----------------------------------------------------------------------------

#' Stacked Column Geometry Layer
#'
#' Create a stacked column geometry layer for `hd` objects.  Each stack is a facet
#' (sub-panel) containing one or more series.  The `stack` argument specifies
#' the column in the data that defines the stacks.  The `group` aesthetic in
#' `hd_spec()` defines the series within each stack.  The `stacking`
#' argument controls how the stacks are rendered: `"normal"` (default) stacks values
#' on top of each other, while `"percent"` stacks values as percentages of the total
#' stack height.
#' 
#' @param stack Character. Column name for the stack variable.  Each unique value
#' in this column creates a separate stack (facet) containing all series with that
#' stack value.  Required.
#' @param stacking Character. Stacking mode for the column geometry.  One of
#' `"normal"` (default) or `"percent"`.  See Highcharts documentation for
#' details: https://api.highcharts.com/highcharts/plotOptions.column.stacking
#' @inheritParams hd_geom_arearange
#' 
#' @return An S3 object of class `"hd_geom"` for use with `+.hd`.
#' @examples
#' # Example data: sales of three products (A, B, C) across four
#' #' # regions (North, South, East, West)
#' df <- data.frame(
#'  region = rep(c("North", "South", "East", "West"),
#'               each = 3),
#'  product = rep(c("A", "B", "C"), times = 4),
#' sales   = c(10, 20, 30, 15, 25, 35, 20, 30, 40, 25, 35, 45)
#' )
#' #' # Create a stacked column chart with `region` as the stack variable and
#' #' # `product` as the group variable
#' spec <- hd_spec(df, x = "region", y = "sales", group = "product")
#' 
#' hd(spec) +
#'  hd_geom_stacked_column(stack = "region", stacking = "normal") +
#' hd_opts(title = "Stacked Column Chart", ylim = c(0, 120))
#' 
#' @export
hd_geom_stacked_column <- function(stack, stacking, ...) {
  hd_geom("stacked_column", stack = stack, stacking = stacking, ...)
}
