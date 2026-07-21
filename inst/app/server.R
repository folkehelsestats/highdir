# inst/app/server.R
# ── highdir Shiny app — Server ────────────────────────────────────────────────
#
# Module call order:
#   1. mod_data_server   — upload + column mapping
#   2. mod_opts_server   — labels + style (returns opts_r, use_js_r)
#   3. mod_figure_server — figures + code preview (returns hc_fig, gg_fig)
#
# Download handlers are registered directly here against top-level output IDs
# that match the static downloadButtons declared in ui.R.  No module
# namespace, no renderUI delay, no reactiveVal bridge needed.
#
# Geom options are built STATICALLY by geom_opts_ui() in global.R at startup
# (one conditionalPanel per geom).  No renderUI — zero server round-trips.

server <- function(input, output, session) {

  # ── 1. Data ────────────────────────────────────────────────────────────────
  data_r <- mod_data_server(
    "data",
    geom_r = shiny::reactive(input$geom)
  )

  # ── 2. Opts ────────────────────────────────────────────────────────────────
  opts_m <- mod_opts_server("opts")

  # ── 3. Geom options — inputs are static (built by geom_opts_ui() in global.R)
  # No renderUI here.  All geom option inputs are in the DOM from page load,
  # wrapped in conditionalPanels keyed on input$geom.  geom_inputs_r() reads
  # them by name exactly as before — the input IDs are identical.

  # ── Collect geom optional-arg inputs → forwarded to hd_make() ────────────
  # Reads ONLY optional_args for the current geometry from top-level input$.
  # Input IDs match because geom_opts_ui() sets inputId = nm (the arg name
  # from names(optional_args)), so input[["smooth"]], input[["dot_size"]] etc. work.
  #
  # Required args (e.g. ymin/ymax for arearange) are NOT collected here.
  # They are rendered inside the data module under namespaced IDs ("data-ymin"),
  # so input[[nm]] at top-level would return NULL.  mod_figure_server() merges
  # required args via data_r$req_args() which reads them in the correct namespace.
  geom_inputs_r <- shiny::reactive({
    oa_names <- names(highdir:::.get_geom(input$geom)$optional_args)
    lapply(stats::setNames(oa_names, oa_names), function(nm) input[[nm]])
  })

  # ── 4. Figure ──────────────────────────────────────────────────────────────
  fig_m <- mod_figure_server(
    id            = "fig",
    run_r         = shiny::reactive(input$run),
    data_r        = data_r,
    opts_r        = opts_m$opts_r,
    use_js_r      = opts_m$use_js_r,
    geom_r        = shiny::reactive(input$geom),
    backend_r     = shiny::reactive(input$mode),
    geom_inputs_r = geom_inputs_r
  )

  # ── 5. Download handlers ────────────────────────────────────────────────────
  # Registered against the top-level IDs that exactly match the static
  # downloadButtons in ui.R.  No module namespace involved — simple and direct.
  dl_basename <- shiny::reactive({
    raw <- trimws(input$dl_filename %||% "")
    if (!nzchar(raw)) return(paste0("highdir-figure_", Sys.Date()))
    tools::file_path_sans_ext(raw)
  })

  .dl <- function(ext, fig_r) {
    shiny::downloadHandler(
      filename = function() paste0(dl_basename(), ".", ext),
      content  = function(file) {
        fig <- fig_r()
        shiny::req(!is.null(fig))
        hd_save(fig, file, type = ext)
      }
    )
  }

  output$dl_json   <- .dl("json", fig_m$hc_fig)
  output$dl_html   <- .dl("html", fig_m$hc_fig)
  output$dl_gg_png <- .dl("png",  fig_m$gg_fig)
  output$dl_gg_svg <- .dl("svg",  fig_m$gg_fig)
}
