# inst/app/modules/mod_figure.R
# ── Figure module ─────────────────────────────────────────────────────────────
#
# Responsibilities:
#   • Build hd_spec() and hd_opts() from reactive inputs
#   • Render highcharter figure  (hc_out)
#   • Render ggplot2 figure      (gg_out)
#   • Generate R code preview    (code_preview)

# ── UI ────────────────────────────────────────────────────────────────────────

#' @keywords internal
mod_figure_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tabsetPanel(
    id   = "out_tabs",
    type = "tabs",

    shiny::tabPanel("Figure",
      shiny::br(),
      shiny::conditionalPanel(
        condition = "input.backend == 'highcharter'",
        highcharter::highchartOutput(ns("hc_out"), height = "520px")
      ),
      shiny::conditionalPanel(
        condition = "input.backend == 'ggplot2'",
        shiny::plotOutput(ns("gg_out"), height = "520px")
      )
    ),

    shiny::tabPanel("Data",
      shiny::br(),
      # tbl_head is owned by mod_data_server — use its namespaced output id.
      # The "data-" prefix matches the module id used in server.R:
      #   mod_data_server("data", ...)  →  output id is "data-tbl_head"
      DT::DTOutput("data-tbl_head")
    ),

    shiny::tabPanel("R code",
      shiny::br(),
      shiny::verbatimTextOutput(ns("code_preview"))
    )
  )
}

# ── Server ────────────────────────────────────────────────────────────────────

#' @keywords internal
#' @param id            Module id.
#' @param run_r         Reactive integer — input$run click counter.
#' @param data_r        Named list from mod_data_server().
#' @param opts_r        Reactive list from mod_opts_server()$opts_r.
#'                      Contains only hd_opts() arguments (no use_js).
#' @param use_js_r      Reactive logical — JS hover band toggle (hd_make arg).
#' @param geom_r        Reactive string — selected geometry name.
#' @param backend_r     Reactive string — "highcharter" or "ggplot2".
#' @param geom_inputs_r Reactive named list of all geom-specific sidebar
#'                      values assembled in server.R.
mod_figure_server <- function(id,
                               run_r,
                               data_r,
                               opts_r,
                               use_js_r,
                               geom_r,
                               backend_r,
                               geom_inputs_r) {

  shiny::moduleServer(id, function(input, output, session) {

    # ── hd_spec ───────────────────────────────────────────────────────────────
    the_spec <- shiny::eventReactive(run_r(), {
      shiny::req(data_r$dataset(), data_r$x(), data_r$y())
      hd_spec(
        data  = data_r$dataset(),
        x     = data_r$x(),
        y     = data_r$y(),
        group = if (nzchar(data_r$group() %||% "")) data_r$group() else NULL,
        n     = if (nzchar(data_r$n_col() %||% "")) data_r$n_col() else NULL
      )
    })

    # ── hd_opts ───────────────────────────────────────────────────────────────
    # opts_r() is already a plain list of hd_opts() arguments
    the_opts <- shiny::eventReactive(run_r(), {
      do.call(hd_opts, opts_r())
    })

    # ── Assemble geom extra args ──────────────────────────────────────────────
    .build_extra <- function() {
      gi <- geom_inputs_r()
      c(
        data_r$req_args(),
        list(
          smooth     = isTRUE(gi$smooth),
          dot_size   = gi$dot_size   %||% 4L,
          inner_size = gi$inner_size %||% "0%",
          ascending  = isTRUE(gi$ascending),
          comp       = if (nzchar(gi$comp %||% "")) gi$comp else NULL,
          aim        = if (!is.na(gi$aim  %||% NA)) gi$aim  else NULL,
          level      = gi$map_level    %||% "county",
          value_lab  = if (nzchar(gi$map_value_lab %||% "")) gi$map_value_lab else NULL,
          low_col    = gi$map_low_col  %||% "#C6DBEF",
          high_col   = gi$map_high_col %||% "#025169",
          na_fill    = gi$map_na_fill  %||% "#D3D3D3"
        )
      )
    }

    # ── Highcharter figure ────────────────────────────────────────────────────
    hc_fig <- shiny::eventReactive(run_r(), {
      shiny::req(backend_r() == "highcharter", the_spec())
      do.call(hd_make, c(
        list(
          spec    = the_spec(),
          type    = geom_r(),
          opts    = the_opts(),
          backend = "highcharter",
          use_js  = use_js_r()        # hd_make() arg, not hd_opts()
        ),
        .build_extra()
      ))
    })

    # ── ggplot2 figure ────────────────────────────────────────────────────────
    gg_fig <- shiny::eventReactive(run_r(), {
      shiny::req(backend_r() == "ggplot2", the_spec())
      do.call(hd_make, c(
        list(
          spec    = the_spec(),
          type    = geom_r(),
          opts    = the_opts(),
          backend = "ggplot2"
          # use_js is not passed to ggplot2 backend — hd_make() ignores it
          # for ggplot2, but keeping it out is cleaner
        ),
        .build_extra()
      ))
    })

    output$hc_out <- highcharter::renderHighchart(hc_fig())
    output$gg_out <- shiny::renderPlot(gg_fig())

    # ── R code preview ────────────────────────────────────────────────────────
    output$code_preview <- shiny::renderText({
      shiny::req(data_r$x(), data_r$y(), geom_r(), backend_r())

      o  <- opts_r()
      gi <- geom_inputs_r()

      L <- function(nm, val, quote = TRUE) {
        if (!nzchar(val %||% "")) return("")
        v <- if (quote) paste0('"', val, '"') else as.character(val)
        paste0("  ", nm, " = ", v, ",\n")
      }

      paste0(
        "spec <- hd_spec(\n",
        "  data  = your_data,\n",
        L("x",     data_r$x()),
        L("y",     data_r$y()),
        L("group", data_r$group()),
        L("n",     data_r$n_col()),
        ")\n\n",
        "opts <- hd_opts(\n",
        L("title",    o$title),
        L("subtitle", o$subtitle),
        L("caption",  o$caption),
        L("xlab",     if (!identical(o$xlab, " ")) o$xlab else ""),
        L("ylab",     if (!identical(o$ylab, " ")) o$ylab else ""),
        ")\n\n",
        "hd_make(\n",
        "  spec    = spec,\n",
        "  opts    = opts,\n",
        L("type",    geom_r()),
        L("backend", backend_r()),
        if (backend_r() == "highcharter")
          paste0("  use_js   = ", isTRUE(use_js_r()), ",\n")      else "",
        if (geom_r() == "line")
          paste0("  smooth   = ", isTRUE(gi$smooth), ",\n")        else "",
        if (geom_r() == "line" && !is.null(gi$dot_size))
          paste0("  dot_size = ", gi$dot_size %||% 4L, ",\n")      else "",
        if (geom_r() == "pie" && nzchar(gi$inner_size %||% ""))
          L("inner_size", gi$inner_size)                            else "",
        if (geom_r() == "map")
          L("level", gi$map_level %||% "county")                    else "",
        if (geom_r() == "ranked_bar")
          paste0(
            if (nzchar(gi$comp %||% "")) L("comp", gi$comp) else "",
            if (!is.na(gi$aim  %||% NA))
              paste0("  aim = ", gi$aim, ",\n")             else ""
          )
        else "",
        ")"
      )
    })

    # Expose figures so mod_opts can register download handlers
    list(hc_fig = hc_fig, gg_fig = gg_fig)
  })
}
