# R/base-figure.R ── Blank canvas constructors
#
# .base_constructors is a dispatch table (named list) keyed by backend name.
# Each entry is a function(spec, opts) that returns an empty backend object
# with axes, labels, and chart-level options already applied.
#
# Adding a new backend = adding one entry here.  No if/else chains.

#' @keywords internal
.base_constructors <- list(

  # ── ggplot2 ─────────────────────────────────────────────────────────────
  ggplot2 = function(spec, opts) {
    mapping <- ggplot2::aes(x = .data[[spec$x]], y = .data[[spec$y]])

    grp_col <- spec$colour %||% spec$group
    if (!is.null(grp_col)) {
      mapping <- utils::modifyList(mapping, ggplot2::aes(
        colour = .data[[grp_col]],
        group  = .data[[grp_col]],
        fill   = .data[[grp_col]]
      ))
    }

    p <- ggplot2::ggplot(spec$data, mapping) +
      ggplot2::labs(
        x        = spec$xlab,
        y        = spec$ylab,
        title    = opts$title,
        subtitle = opts$subtitle,
        caption  = opts$caption
      )

    if (isTRUE(opts$flip)) p <- p + ggplot2::coord_flip()
    p
  },

  # ── highcharter ──────────────────────────────────────────────────────────
  highcharter = function(spec, opts) {
    chart <- highcharter::highchart() |>
      highcharter::hc_chart(inverted = isTRUE(opts$flip)) |>
      highcharter::hc_yAxis(
        title        = list(text = spec$ylab %||% " "),
        ## labels       = list(format = "{value}%"),
        labels       = list(format = "{value}"), #TODO: optional with %
        tickInterval = opts$yint,
        min          = if (!is.null(opts$ylim)) opts$ylim[1] else 0,
        max          = if (!is.null(opts$ylim)) opts$ylim[2] else NULL
      )

    # x-axis: categories for character, numeric labels otherwise
    if (!is.numeric(spec$data[[spec$x]])) {
      chart <- chart |> highcharter::hc_xAxis(
        title        = list(text = spec$xlab %||% " "),
        categories   = unique(spec$data[[spec$x]]),
        tickInterval = 1,
        labels       = list(step = 1)
      )
    } else {
      chart <- chart |> highcharter::hc_xAxis(
        title  = list(text = spec$xlab %||% " "),
        labels = list(step = 1)
      )
    }

    if (!is.null(opts$title))
      chart <- chart |> highcharter::hc_title(text = opts$title)

    chart <- chart |>
      highcharter::hc_subtitle(
        text = opts$subtitle %||% "Kilde: Navn av kilder"
      )

    if (!is.null(opts$caption))
      chart <- chart |> highcharter::hc_caption(text = opts$caption)

    chart
  }
)

#' Build a Blank Backend Canvas
#'
#' Constructs the empty backend object (ggplot or highchart) with all
#' chart-level options applied from `spec` and `opts`. Called by the
#' backend engines; you rarely need this directly.
#'
#' @param spec    A [hd_spec] object.
#' @param opts    A [hd_opts] object.
#' @param backend Character. Backend name.
#' @return A `ggplot` or `highchart` object.
#' @keywords internal
base_fig <- function(spec, opts, backend) {
  ctor <- .base_constructors[[backend]]
  if (is.null(ctor))
    stop("No base constructor registered for backend '", backend, "'.",
         call. = FALSE)
  ctor(spec, opts)
}
