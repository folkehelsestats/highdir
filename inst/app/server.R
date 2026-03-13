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
  # Builds input widgets for every optional_arg of the selected geometry.
  # Arg names come from names(optional_args) — e.g. "smooth", "dot_size".
  # The desc string is shown as small helper text below each widget.
  #
  # Widget type is chosen by the class of entry$default:
  #   logical   → checkboxInput
  #   numeric   → numericInput
  #   character → textInput  (selectInput for "level" special case)
  #   NULL      → textInput  (user types a value or leaves blank)
  #
  # The input IDs are set to nm exactly (e.g. inputId = "smooth") so that
  # geom_inputs_r() can read them back with input[[nm]] and pass them to
  # hd_make() — see the "Collect geom sidebar inputs" block below.
  output$ui_geom_opts <- shiny::renderUI({
    geom_def <- highdir:::.get_geom(input$geom)
    oa       <- geom_def$optional_args   # named list from registry

    if (length(oa) == 0L) {
      return(shiny::tags$p(
        style = "font-size:11px; color:#8b949e; margin:2px 0 0;",
        "No extra options for this geometry."
      ))
    }

    # names(oa) gives the exact arg names: "smooth", "dot_size", "comp", …
    inputs <- lapply(names(oa), function(nm) {
      entry <- oa[[nm]]
      def   <- entry$default

      # ── Label: the arg name, formatted for display ──────────────────────
      # nm  = "dot_size"  →  lbl = "dot_size"
      # Do NOT use entry$desc here — that is the long description string.
      lbl <- nm

      # ── Helper text: one-line version of entry$desc ─────────────────────
      # Truncated to 80 chars and shown as small grey text under the widget.
      desc_short <- entry$desc
      if (nchar(desc_short) > 80)
        desc_short <- paste0(substr(desc_short, 1, 80), "\u2026")
      helper <- shiny::tags$p(
        style = "font-size:10px; color:#8b949e; margin:-3px 0 5px;",
        desc_short
      )

      # ── Widget — special case first, then type dispatch ─────────────────
      widget <- if (nm == "level") {
        # "level" has a fixed set of valid values → selectInput
        shiny::selectInput(nm, lbl,
          choices  = c("County" = "county", "Municipality" = "municipality"),
          selected = def %||% "county")

      } else if (is.logical(def) ||
                 identical(def, TRUE) || identical(def, FALSE)) {
        shiny::checkboxInput(nm, lbl, value = isTRUE(def))

      } else if (is.numeric(def)) {
        shiny::numericInput(nm, lbl, value = def)

      } else {
        # character default or NULL → textInput
        # Show the default as both the initial value and the placeholder
        ph <- if (!is.null(def)) as.character(def) else lbl
        shiny::textInput(nm, lbl,
          value       = if (!is.null(def)) as.character(def) else "",
          placeholder = ph)
      }

      # Wrap widget + helper in a div so they stay together visually
      shiny::div(widget, helper)
    })

    shiny::tagList(inputs)
  })

  # ── Collect geom optional-arg inputs → forwarded to hd_make() ────────────
  # Reads ONLY optional_args for the current geometry from top-level input$.
  # Input IDs match because ui_geom_opts sets inputId = nm (the arg name from
  # names(optional_args)), so input[["smooth"]], input[["dot_size"]] etc. work.
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
