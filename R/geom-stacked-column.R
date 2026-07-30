#' @keywords internal
gg_stacked_column <- function(spec, opts, geom_params) {
  # optional args ----------------------------------------------------------------
  facet_col <- geom_params$facet
  grp_col   <- spec$group
  stacking  <- geom_params$stacking %||% "normal"

  #   stacking <- geom_params$stacking
  #   if (stacking == "percent") {
  #     warning("Percent stacking isn't implemented in static figure yet.",
  #       call. = FALSE
  #     )
  #     stacking <- "normal"
  #   }

  if (is.null(grp_col)) {
    stop("stacked_column requires a group column in hd_spec().", call. = FALSE)
  }

  position <- switch(stacking,
    "normal"  = "stack",
    "percent" = "fill",
    stop("stacking must be 'normal' or 'percent'")
  )

  list(
    ggplot2::geom_col(
      position = position,
      width = 0.7
    ),
    if (!is.null(facet_col)) {
      ggplot2::facet_wrap(
        stats::as.formula(paste("~", facet_col)),
        nrow = 1,
        scales = "free_x"
      )
    },
    # Remove the x-axis tick labels inside facets - the facet strip
    # title already labels each stack group
    if (!is.null(facet_col)) {
      ggplot2::theme(
        axis.text.x = ggplot2::element_blank()
      )
    }
  )
}

#' @keywords internal
hc_stacked_column <- function(chart, spec, opts, geom_params,
                              use_js = TRUE, ...) {
  
  # Optional args ----------------------------------------------------------------
  facet_col <- geom_params$facet
  stacking  <- geom_params$stacking %||% "normal"

  d       <- spec$data
  x_col   <- spec$x
  y_col   <- spec$y
  grp_col <- spec$group

  if (is.null(grp_col)) {
    stop("stacked_column requires a group column in hd_spec().", call. = FALSE)
  }

  if (is.null(facet_col)) {
    d[[".stack"]] <- "default"
    facet_col <- ".stack"
  }
  
  # Enable stacking for all column series
  chart <- chart |>
    highcharter::hc_plotOptions(column = list(stacking = stacking))
  
  # -- Key insight: iterate every unique (series, stack) combination ---
  # The same series name can appear in multiple stacks.
  # Each unique pair produces one hc_add_series() call with its own stack id.
  # Highcharts separates the stacks visually; the legend shows unique names.
  combos <- unique(d[, c(grp_col, facet_col), drop = FALSE])
  pal <- resolve_colors(length(unique(d[[grp_col]])), opts$colors)
  # Named palette so same series name always gets the same colour across stacks
  series_names <- unique(d[[grp_col]])
  color_by_name <- stats::setNames(pal, series_names)

  for (i in seq_len(nrow(combos))) {
    series_name <- combos[[grp_col]][i]
    stack_id <- combos[[facet_col]][i]

    # Rows belonging to this (series, stack) pair, in x-axis order
    mask <- d[[grp_col]] == series_name & d[[facet_col]] == stack_id
    rows <- d[mask, , drop = FALSE]

    # Align to x-axis categories (base_fig sets categories = unique(x))
    # Missing categories get NA so the series stays aligned
    x_cats <- unique(d[[x_col]])
    idx <- match(x_cats, rows[[x_col]])

    # -- Build point objects -------------------------------------------------
    # When spec$n is set, the tooltip format in backend-highcharter.R
    # references {point.<n_col>}.  For this to work each Highcharts data
    # point must be a named list with both `y` and the n column value.
    # Passing bare numerics (as.list(values)) gives points with only `y`,
    # so {point.Count} is always undefined in the tooltip.
    #
    # Fix: build a list of named lists — one per x category — so Highcharts
    # receives { y: 36.5, Count: 148 } instead of just 36.5.
    n_col <- spec$n

    point_data <- lapply(seq_along(x_cats), function(j) {
      pt <- list(y = if (is.na(idx[j])) NA_real_ else rows[[y_col]][idx[j]])

      # Attach the n column value so the tooltip formatter can read it
      # via {point.<n_col>}.  Only attach when spec$n is set and the
      # row actually exists (idx[j] is not NA).
      if (!is.null(n_col) && nzchar(n_col) && !is.na(idx[j])) {
        pt[[n_col]] <- rows[[n_col]][idx[j]]
      }

      pt
    })

    chart <- chart |>
      highcharter::hc_add_series(
        name         = series_name,
        type         = "column",
        data         = point_data,
        stack        = stack_id,
        color        = color_by_name[[series_name]],
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
#' the column in the data that defines the stacks if exists.  The `group` aesthetic in
#' `hd_spec()` defines the series within each stack.  The `stacking`
#' argument controls how the stacks are rendered: `"normal"` (default) stacks values
#' on top of each other, while `"percent"` stacks values as percentages of the total
#' stack height.
#'
#' @param facet Character. Column name for the facet variable. Each unique value
#'   in this column creates a separate facet (stack) containing all series with
#'   that faceted value.
#' @param stack Deprecated argument replaced by `facet`.
#' @param stacking Character. Stacking mode for the column geometry. One of
#'   `"normal"` (default) or `"percent"`. For ggplot2, is equivalent to
#'   `position = "fill"`, else see Highcharts documentation for details:
#'   https://api.highcharts.com/highcharts/plotOptions.column.stacking
#' @inheritParams hd_geom_arearange
#'
#' @return An S3 object of class `"hd_geom"` for use with `+.hd`.
#' @examples
#'
#' # Example data: medal counts for four countries across three medal types
#' olympics <- data.frame(
#'     Country   = rep(c("Norway", "Germany", "United States", "Canada"), each = 3),
#'     Continent = rep(c("Europe", "Europe", "North America", "North America"), each = 3),
#'     Medal     = rep(c("Gold", "Silver", "Bronze"), times = 4),
#'     Count     = c(148, 133, 124, 102, 98, 65, 113, 122, 95, 77, 72, 80)
#' )
#'
#' # Define Specification and Options
#' spec_st <- hd_spec(olympics,
#'     x     = "Medal",
#'     y     = "Count",
#'     group = "Country"
#' )
#'
#' opts_st <- hd_opts(
#'     title    = "Olympic Games all-time medal table, grouped by continent",
#'     subtitle = "Source: Olympics",
#'     ylab     = "Count medals"
#' )
#'
#' hd_make(spec_st, "stacked_column", opts_st)
#'
#' # Interactive - stacks are separated by continent
#' hd_make(spec_st, "stacked_column", opts_st, facet = "Continent")
#'
#' # Static ggplot2 - stacks are separated by continent
#' hd(spec_st, mode = "static") +
#'   hd_geom_stacked_column(facet = "Continent") +
#'   hd_opts(title = "Olympic Games all-time medal table, grouped by continent", ylab = "Count medals")
#'
#' @export
hd_geom_stacked_column <- function(facet = NULL, stack = lifecycle::deprecated(), stacking = c("normal", "percent"), ...) {
  # for now, we ignore the `stacking` argument in ggplot2 since it requires more
  # complex data manipulation to implement percent stacking. The Highcharts
  # version supports both modes. So stacking below is mainly for future-proofing
  # and consistency with the Highcharts API and avoid erroring if users specify
  # it in ggplot2 backend.

  if (!lifecycle::is_present(stack)) {
    lifecycle::deprecate_warn(
      when = "0.6.0",
      what = "hd_geom_stacked_column(stack)",
      with = "hd_geom_stacked_column(facet)"
    )

    facet <- stack
  }

  stacking <- match.arg(stacking)

  hd_geom("stacked_column", facet = facet, stacking = stacking, ...)
}
