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
# Dynamic geom options (ui_geom_opts) are built here by reading optional_args
# from the geometry registry — no hard-coded conditionalPanels in ui.R.

server <- function(input, output, session) {

  # ── 1. Data ────────────────────────────────────────────────────────────────
  data_r <- mod_data_server(
    "data",
    geom_r = shiny::reactive(input$geom)
  )

  # ── 2. Opts ────────────────────────────────────────────────────────────────
  opts_m <- mod_opts_server("opts")

  # ── 3. Dynamic geom options ────────────────────────────────────────────────
  # Reads optional_args from the registry for the selected geometry and builds
  # the appropriate input widgets.  This replaces the previous hard-coded
  # conditionalPanel blocks and automatically shows ALL documented args.
  #
  # Input widget type is chosen by the class of the default value:
  #   logical   → checkboxInput
  #   numeric   → numericInput
  #   character → textInput  (or selectInput when choices are documented)
  #   NULL      → textInput  (user enters a value or leaves blank)
  output$ui_geom_opts <- shiny::renderUI({
    geom_def <- get_geom(input$geom)
    oa       <- geom_def$optional_args

    # Geoms with no optional args
    if (length(oa) == 0L) {
      return(shiny::tags$p(
        style = "font-size:11px; color:#8b949e; margin:2px 0 0;",
        "No extra options for this geometry."
      ))
    }

    inputs <- lapply(names(oa), function(nm) {
      entry   <- oa[[nm]]
      def     <- entry$default
      # Truncate long desc to a short label (first sentence / 60 chars)
      lbl     <- gsub("\\..*", "", entry$desc)
      if (nchar(lbl) > 60) lbl <- paste0(substr(lbl, 1, 57), "\u2026")

      # Special case: map "level" gets a selectInput
      if (nm == "level") {
        return(shiny::selectInput(nm, lbl,
          choices  = c("County" = "county", "Municipality" = "municipality"),
          selected = def %||% "county"))
      }

      # General type dispatch
      if (is.logical(def) || identical(def, TRUE) || identical(def, FALSE)) {
        shiny::checkboxInput(nm, lbl, value = isTRUE(def))

      } else if (is.numeric(def)) {
        shiny::numericInput(nm, lbl, value = def)

      } else {
        # character or NULL → textInput; show default as placeholder
        ph <- if (!is.null(def)) as.character(def) else lbl
        shiny::textInput(nm, lbl,
                         value       = if (!is.null(def)) as.character(def) else "",
                         placeholder = ph)
      }
    })

    shiny::tagList(inputs)
  })

  # ── Collect geom sidebar inputs ────────────────────────────────────────────
  # These are read dynamically: we look up the optional_args names for the
  # current geom and pull each from input$.  Unknown/missing inputs return
  # NULL gracefully.
  geom_inputs_r <- shiny::reactive({
    geom_def <- get_geom(input$geom)
    oa_names <- names(geom_def$optional_args)
    args <- lapply(stats::setNames(oa_names, oa_names), function(nm) input[[nm]])
    # Also include required args so mod_figure gets everything in one place
    ra_names <- geom_def$required_args
    ra_vals  <- lapply(stats::setNames(ra_names, ra_names), function(nm) input[[nm]])
    c(args, ra_vals)
  })

  # ── 4. Figure ──────────────────────────────────────────────────────────────
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
