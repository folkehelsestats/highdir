# base-figure.R — Backend-specific blank canvas constructors
#
# Uses a named list for dispatch so that adding a backend means adding one
# entry here, not editing if/else chains.
#
# Deprecated aes_() / hcaes_string() have been replaced with:
#   ggplot2   → .data[[]] pronoun (tidy eval)
#   highcharter → hcaes() with !!rlang::sym()

#' @keywords internal
.base_constructors <- list(

  ggplot2 = function(spec) {
    mapping <- ggplot2::aes(
      x = .data[[spec$x]],
      y = .data[[spec$y]]
    )
    if (!is.null(spec$group) && is.null(spec$colour)) {
      mapping <- utils::modifyList(
        mapping,
        ggplot2::aes(colour = .data[[spec$group]], group = .data[[spec$group]])
      )
    } else if (!is.null(spec$colour)) {
      mapping <- utils::modifyList(
        mapping,
        ggplot2::aes(colour = .data[[spec$colour]])
      )
    }

    p <- ggplot2::ggplot(spec$data, mapping) +
      ggplot2::labs(
        x        = spec$xlab,
        y        = spec$ylab,
        title    = spec$title,
        subtitle = spec$subtitle,
        caption  = spec$caption
      )

    # Flip axes if requested
    if (isTRUE(spec$flip)) p <- p + ggplot2::coord_flip()

    p
  },

  highcharter = function(spec) {
    chart <- highcharter::highchart() |>
      highcharter::hc_chart(inverted = isTRUE(spec$flip)) |>
      highcharter::hc_xAxis(title = list(text = spec$xlab %||% " ")) |>
      highcharter::hc_yAxis(
        title       = list(text = spec$ylab %||% " "),
        labels      = list(format = "{value}%"),
        tickInterval = spec$yint,
        min          = if (!is.null(spec$ylim)) spec$ylim[1] else 0,
        max          = if (!is.null(spec$ylim)) spec$ylim[2] else NULL
      )

    # Title, subtitle, caption
    if (!is.null(spec$title))
      chart <- chart |> highcharter::hc_title(text = spec$title)

    sub_text <- spec$subtitle %||% "Kilde: Navn av kilder"
    chart <- chart |> highcharter::hc_subtitle(text = sub_text)

    if (!is.null(spec$caption))
      chart <- chart |> highcharter::hc_caption(text = spec$caption)

    chart
  }
)

#' Base Figure Canvas
#'
#' Constructs the blank backend-specific canvas (a bare `ggplot` or
#' `highchart`) with axes, labels, and chart-level options applied from
#' `spec`. Called internally by the backend engines; you rarely need this
#' directly.
#'
#' @param spec A [fig_spec] object.
#' @param backend Character. Backend name, e.g. `"ggplot2"` or
#'   `"highcharter"`.
#' @return A `ggplot` or `highchart` object.
#' @keywords internal
base_fig <- function(spec, backend) {
  ctor <- .base_constructors[[backend]]
  if (is.null(ctor))
    stop("No base constructor registered for backend '", backend, "'.",
         call. = FALSE)
  ctor(spec)
}
