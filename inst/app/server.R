# inst/app/server.R
# ── highdir Shiny app — Server ────────────────────────────────────────────────
#
# Wiring order:
#   1. mod_data_server   — upload + column mapping
#   2. mod_figure_server — figures (returns hc_fig / gg_fig reactives)
#   3. mod_opts_server   — labels, style, downloads
#                          (receives hc_fig / gg_fig to register handlers)
#
# mod_opts is called AFTER mod_figure so it can receive the figure reactives
# and register the download handlers internally with the correct namespace.

server <- function(input, output, session) {

  # ── 1. Data module ──────────────────────────────────────────────────────────
  data_r <- mod_data_server(
    "data",
    geom_r = shiny::reactive(input$geom)
  )

  # ── Geom-specific sidebar inputs ────────────────────────────────────────────
  # Inputs declared in ui.R (top-level namespace) are collected here and
  # passed to mod_figure_server so that module never reads input$ directly.
  geom_inputs_r <- shiny::reactive(list(
    smooth        = input$smooth,
    dot_size      = input$dot_size,
    inner_size    = input$inner_size,
    ascending     = input$ascending,
    comp          = input$comp,
    aim           = input$aim,
    map_level     = input$map_level,
    map_value_lab = input$map_value_lab,
    map_low_col   = input$map_low_col,
    map_high_col  = input$map_high_col,
    map_na_fill   = input$map_na_fill
  ))

  # ── 2a. Opts — first pass (no figures yet) ──────────────────────────────────
  # We call mod_opts_server twice: once now to get opts_r / use_js_r for
  # mod_figure, and once after figures exist to wire the download handlers.
  # Shiny modules are NOT re-callable — instead we call it once and pass
  # reactive placeholder (reactiveVal) containers for the figures, then fill
  # them after mod_figure_server returns.
  #
  # A reactiveVal starts as NULL.  The download handlers use req() to guard
  # against NULL, so clicking Download before drawing just silently waits.
  hc_fig_rv <- shiny::reactiveVal(NULL)
  gg_fig_rv <- shiny::reactiveVal(NULL)

  opts_m <- mod_opts_server(
    "opts",
    backend_r = shiny::reactive(input$backend),
    # Pass wrapper reactives around the reactiveVals so mod_opts receives
    # standard reactive objects (not reactiveVal directly).
    hc_fig_r  = shiny::reactive(hc_fig_rv()),
    gg_fig_r  = shiny::reactive(gg_fig_rv())
  )

  # ── 2b. Figure module ────────────────────────────────────────────────────────
  fig_m <- mod_figure_server(
    id            = "fig",
    run_r         = shiny::reactive(input$run),
    data_r        = data_r,
    opts_r        = opts_m$opts_r,
    use_js_r      = opts_m$use_js_r,
    geom_r        = shiny::reactive(input$geom),
    backend_r     = shiny::reactive(input$backend),
    geom_inputs_r = geom_inputs_r
  )

  # ── 3. Fill figure containers so download handlers become active ─────────────
  # observeEvent propagates new figure values into the reactiveVals.
  # mod_opts' download handlers (which wrap reactive(hc_fig_rv())) will
  # automatically see the new value on the next reactive flush.
  shiny::observeEvent(fig_m$hc_fig(), {
    hc_fig_rv(fig_m$hc_fig())
  }, ignoreNULL = TRUE)

  shiny::observeEvent(fig_m$gg_fig(), {
    gg_fig_rv(fig_m$gg_fig())
  }, ignoreNULL = TRUE)
}
