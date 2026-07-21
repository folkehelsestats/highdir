# inst/app/modules/mod_figure.R
# -- Figure module -------------------------------------------------------------
#
# Responsibilities:
#   • Build hd_spec() and hd_opts() from reactive inputs
#   • Render highcharter figure  (hc_out)
#   • Render ggplot2 figure      (gg_out)
#   • Generate R code preview    (code_preview)
#
# geom_inputs_r is a reactive named list containing ALL optional_args AND
# required_args for the current geometry, assembled in server.R by reading
# the registry.  mod_figure passes this directly to hd_make() via do.call.
# There is no need to know which args belong to which geom here.

# -- UI ------------------------------------------------------------------------

#' @keywords internal
mod_figure_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tabsetPanel(
    id   = "out_tabs",
    type = "tabs",

    shiny::tabPanel("Data",
      shiny::br(),
      # "data-tbl_head" = module id "data" + output id "tbl_head"
      DT::DTOutput("data-tbl_head")
    ),

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

    shiny::tabPanel("R code",
      shiny::br(),
      shiny::verbatimTextOutput(ns("code_preview"))
    )
  )
}

# -- Server --------------------------------------------------------------------

#' @keywords internal
#' @param id            Module id.
#' @param run_r         Reactive integer - input$run click counter.
#' @param data_r        Named list from mod_data_server().
#' @param opts_r        Reactive list of hd_opts() arguments (no use_js).
#' @param use_js_r      Reactive logical - JS hover band (hd_make arg).
#' @param geom_r        Reactive string - selected geometry name.
#' @param backend_r     Reactive string - "dynamic" or "static".
#' @param geom_inputs_r Reactive named list - ALL optional + required args for
#'                      the current geometry, keyed by arg name as they appear
#'                      in optional_args / required_args in the registry.
#'                      Assembled in server.R from input$ values.
mod_figure_server <- function(id,
                              run_r,
                              data_r,
                              opts_r,
                              use_js_r,
                              geom_r,
                              backend_r,
                              geom_inputs_r) {

  shiny::moduleServer(id, function(input, output, session) {

    # -- hd_spec ---------------------------------------------------------------
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

    # -- hd_opts ---------------------------------------------------------------
    the_opts <- shiny::eventReactive(run_r(), {
      do.call(hd_opts, opts_r())
    })

    # -- Build extra args for hd_make() --------------------------------------
    # Merges two sources:
    #   • geom_inputs_r() - optional args read from top-level input$ in server.R
    #                        keyed by names(optional_args) from the registry
    #   • data_r$req_args() - required args (e.g. ymin/ymax) read inside the
    #                          data module with the correct "data-" namespace
    # .sanitise() converts empty strings -> NULL and NA numerics -> NULL so
    # hd_make() never receives a blank textInput value as a real argument.
    .sanitise <- function(args) {
      lapply(args, function(v) {
        if (is.null(v))                     return(NULL)
        if (is.character(v) && !nzchar(v))  return(NULL)
        if (is.numeric(v)   && is.na(v))    return(NULL)
        v
      })
    }

    .build_extra <- function() {
      # optional args from top-level geom option inputs (server.R)
      opt <- .sanitise(geom_inputs_r())
      # required args from the data module (correct namespace)
      req <- .sanitise(data_r$req_args())
      c(opt, req)
    }

    # -- Highcharter figure ----------------------------------------------------
    # .build_extra() merges optional + required geom args -> hd_make() via ...
    # do.call() splices extra as named args, so hd_make receives e.g.:
    #   hd_make(spec, type, opts, backend, use_js, smooth=TRUE, dot_size=4,
    #           ymin="lo_col", ymax="hi_col")
    hc_fig <- shiny::eventReactive(run_r(), {
      shiny::req(backend_r() == "dynamic", the_spec())
      do.call(hd_make, c(
        list(spec    = the_spec(),
             type    = geom_r(),
             opts    = the_opts(),
             backend = "dynamic",
             use_js  = use_js_r()),
        .build_extra()   # <- optional + required geom args -> hd_make(...)
      ))
    })

    # -- ggplot2 figure --------------------------------------------------------
    # Same flow: .build_extra() -> hd_make(...)
    gg_fig <- shiny::eventReactive(run_r(), {
      shiny::req(backend_r() == "static", the_spec())
      do.call(hd_make, c(
        list(spec    = the_spec(),
             type    = geom_r(),
             opts    = the_opts(),
             backend = "static"),
        .build_extra()   # <- optional + required geom args -> hd_make(...)
      ))
    })

    output$hc_out <- highcharter::renderHighchart(hc_fig())
    output$gg_out <- shiny::renderPlot(gg_fig())

    # -- R code preview --------------------------------------------------------
    # Renders live (not only on Draw) so the code box reflects the current UI.
    output$code_preview <- shiny::renderText({
      shiny::req(data_r$x(), data_r$y(), geom_r(), backend_r())

      o  <- opts_r()
      # Merge optional + required geom args for code preview (same as .build_extra())
      gi <- c(.sanitise(geom_inputs_r()), .sanitise(data_r$req_args()))

      # Helper: emit one "  name = value,\n" line, or "" if value is absent
      L <- function(nm, val, quote = TRUE) {
        if (is.null(val) || !nzchar(as.character(val) %||% "")) return("")
        v <- if (quote) paste0('"', val, '"') else as.character(val)
        paste0("  ", nm, " = ", v, ",\n")
      }

      # Build geom-specific extra arg lines from whatever is in gi
      extra_lines <- paste0(
        mapply(function(nm, val) {
          if (is.null(val)) return("")
          if (is.character(val)) L(nm, val)
          else                   L(nm, val, quote = FALSE)
        }, names(gi), gi),
        collapse = ""
      )

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
        print_opt("xlab", o$xlab),
        print_opt("ylab", o$ylab),
        print_val("ylim", o$ylim),
        L("yint", o$yint, quote = FALSE),
        L("ysuffix",  o$ysuffix),
        L("xtick_labels",  o$xtick_labels),
        L("decimals", o$decimals, quote = FALSE),
        L("description",  o$description),
        if (isTRUE(o$flip))
          paste0("  flip  = ", isTRUE(o$flip)),
        ")\n\n",
        "hd_make(\n",
        "  spec    = spec,\n",
        "  opts    = opts,\n",
        L("type",    geom_r()),
        L("backend", backend_r()),
        if (backend_r() == "dynamic")
          paste0("  use_js  = ", isTRUE(use_js_r()), ",\n") else "",
        extra_lines,
        ")"
      )
    })

    # Expose figures so server.R can wire download handlers
    list(hc_fig = hc_fig, gg_fig = gg_fig)
  })
}


print_opt <- function(name, val) {
  if (is.null(val)) {
    paste0("  ", name, " = NULL,\n")
  } else if (is.character(val)) {
    paste0("  ", name, ' = "', val, '",\n')
  }
}

print_val <- function(name, val){
  if (is.null(val)) return("")
  paste0("  ", name, " = ", deparse(val), ",\n")
}
