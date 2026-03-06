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
        x        = opts$xlab %||% ggplot2::waiver(),
        y        = opts$ylab %||% ggplot2::waiver(),
        title    = opts$title,
        subtitle = opts$subtitle,
        caption  = opts$caption
      )

    ## NULL → hide with element_blank() so no space is reserved
    if (is.null(opts$ylab))
      p <- p + ggplot2::theme(
        axis.title.y = ggplot2::element_blank()
      )
    if (is.null(opts$ylab))
      p <- p + ggplot2::theme(
        axis.title.x = ggplot2::element_blank()
      )

    if (!is.null(opts$ylim))
      p <- p + ggplot2::scale_y_continuous(limits = opts$ylim)

    if (!is.null(opts$yint))
      p <- p + ggplot2::geom_hline(
                   yintercept = opts$yint,
                   linetype   = "dashed",
                   colour     = "#AAAAAA"
                   )

    if (isTRUE(opts$flip)) p <- p + ggplot2::coord_flip()

    p
  },

  # ── highcharter ──────────────────────────────────────────────────────────
  highcharter = function(spec, opts) {
    chart <- highcharter::highchart() |>
      highcharter::hc_chart(inverted = isTRUE(opts$flip)) |>
      highcharter::hc_yAxis(
        title        = list(text = opts$ylab),
        ## labels       = list(format = "{value}%"),
        labels       = list(format = "{value}"), #TODO: optional with %
        tickInterval = opts$yint,
        min          = if (!is.null(opts$ylim)) opts$ylim[1] else 0,
        max          = if (!is.null(opts$ylim)) opts$ylim[2] else NULL
      )

    # x-axis: categories for character, numeric labels otherwise
    if (!is.numeric(spec$data[[spec$x]])) {
      chart <- chart |> highcharter::hc_xAxis(
        title        = list(text = opts$xlab),
        categories   = unique(spec$data[[spec$x]]),
        tickInterval = 1,
        labels       = list(step = 1)
      )
    } else {
      chart <- chart |> highcharter::hc_xAxis(
        title  = list(text = opts$xlab),
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

  ## Resolve axis labels
  opts$ylab <- .resolve_axis_label(opts$ylab, spec$y)
  opts$xlab <- .resolve_axis_label(opts$xlab, spec$x)

  ctor <- .base_constructors[[backend]]
  if (is.null(ctor))
    stop("No base constructor registered for backend '", backend, "'.",
         call. = FALSE)
  ctor(spec, opts)
}
