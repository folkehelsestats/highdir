# inst/app/modules/mod_opts.R
# ── Opts module ───────────────────────────────────────────────────────────────
#
# Responsibilities:
#   • Labels     (title, subtitle, caption, xlab, ylab)
#   • Style      (colours, HC theme, JS hover toggle)
#   • Downloads  (filename input + download buttons + handlers)
#
# Download handlers are registered HERE (not in server.R) because
# downloadButton IDs rendered inside a moduleServer are already namespaced
# by the module's session.  Registering output$dl_json inside this module
# means Shiny matches "opts-dl_json" → output[["opts-dl_json"]] correctly.
# If we register them in server.R with output[["opts-dl_json"]] it appears
# to work, but the handler never fires because Shiny's internal routing
# looks for the handler under the *local* ID within the module context.
#
# The figures needed by the handlers (hc_fig, gg_fig) are passed in as
# reactive arguments — this module never builds figures itself.

# ── UI ────────────────────────────────────────────────────────────────────────

#' @keywords internal
mod_opts_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(

    shiny::tags$button(
      class         = "hd-toggle",
      `data-target` = paste0("#", ns("panel-opts")),
      shiny::span("Opts \u2014 labels & style"),
      shiny::span(class = "hd-arrow", "\u25bc")
    ),

    shiny::div(
      id    = ns("panel-opts"),
      class = "hd-collapse",

      # Labels
      shiny::div(class = "hd-label", style = "margin-top:4px;", "Labels"),
      shiny::textInput(ns("title"),    NULL, placeholder = "Title"),
      shiny::textInput(ns("subtitle"), NULL, placeholder = "Subtitle"),
      shiny::textInput(ns("caption"),  NULL, placeholder = "Caption"),
      shiny::textInput(ns("xlab"),     NULL, placeholder = "X-axis label"),
      shiny::textInput(ns("ylab"),     NULL, placeholder = "Y-axis label"),

      # Style
      shiny::div(class = "hd-label", "Style"),
      shiny::textInput(ns("colors"), NULL,
                       placeholder = "Colours: #025169, #7C145C, \u2026"),

      # HC-only — shown/hidden client-side; condition uses top-level input$backend
      shiny::conditionalPanel(
        condition = "input.backend == 'highcharter'",
        shiny::selectInput(ns("hc_theme"), NULL,
                           choices  = c("default", "smpl", "economist",
                                        "darkunica", "gridlight", "bloom",
                                        "flat", "flatdark", "ggplot2"),
                           selected = "default"),
        shiny::checkboxInput(ns("use_js"), "JS hover band", value = TRUE)
      ),

      # Download
      shiny::div(class = "hd-label", "Download"),
      shiny::textInput(ns("dl_filename"), NULL,
                       placeholder = paste0("highdir-figure_", Sys.Date())),
      shiny::div(class = "hd-dl-row", shiny::uiOutput(ns("ui_downloads")))
    )
  )
}

# ── Server ────────────────────────────────────────────────────────────────────

#' @keywords internal
#' @param id         Module id.
#' @param backend_r  Reactive string — "highcharter" or "ggplot2".
#' @param hc_fig_r   Reactive — highcharter figure (from mod_figure_server).
#' @param gg_fig_r   Reactive — ggplot2 figure    (from mod_figure_server).
#'
#' hc_fig_r and gg_fig_r are passed in so this module can register download
#' handlers for the figures without owning figure-building logic itself.
#' They may be NULL until the user clicks Draw — req() inside the handler
#' guards against premature downloads.
mod_opts_server <- function(id, backend_r, hc_fig_r = NULL, gg_fig_r = NULL) {

  shiny::moduleServer(id, function(input, output, session) {

    # ── Download button UI (changes with backend) ──────────────────────────
    # downloadButton() IDs here are LOCAL (un-prefixed).  Shiny automatically
    # prepends the module namespace when resolving them.
    output$ui_downloads <- shiny::renderUI({
      if (backend_r() == "highcharter") {
        shiny::tagList(
          shiny::downloadButton("dl_json", "JSON"),
          shiny::downloadButton("dl_html", "HTML")
        )
      } else {
        shiny::tagList(
          shiny::downloadButton("dl_gg_png", "PNG"),
          shiny::downloadButton("dl_gg_svg", "SVG")
        )
      }
    })

    # ── Download handlers ──────────────────────────────────────────────────
    # Registered here (not in server.R) so IDs are resolved in this module's
    # namespace.  hc_fig_r / gg_fig_r are updated after mod_figure_server
    # returns — see the note in server.R about two-phase wiring.
    .dl <- function(ext, fig_r) {
      shiny::downloadHandler(
        filename = function() paste0(dl_basename(), ".", ext),
        content  = function(file) {
          shiny::req(!is.null(fig_r) && !is.null(fig_r()))
          hd_save(fig_r(), file, type = ext)
        }
      )
    }

    output$dl_json   <- .dl("json", hc_fig_r)
    output$dl_html   <- .dl("html", hc_fig_r)
    output$dl_gg_png <- .dl("png",  gg_fig_r)
    output$dl_gg_svg <- .dl("svg",  gg_fig_r)

    # ── Helpers ────────────────────────────────────────────────────────────
    parsed_colors <- shiny::reactive({
      raw <- trimws(input$colors %||% "")
      if (!nzchar(raw)) return(NULL)
      unname(strsplit(raw, "\\s*,\\s*")[[1]])
    })

    dl_basename <- shiny::reactive({
      raw <- trimws(input$dl_filename %||% "")
      if (!nzchar(raw)) return(paste0("highdir-figure_", Sys.Date()))
      tools::file_path_sans_ext(raw)
    })

    # ── Return values ──────────────────────────────────────────────────────
    # opts_r contains ONLY hd_opts() arguments — use_js belongs to hd_make()
    # and is returned separately so mod_figure can pass it correctly.
    list(
      opts_r = shiny::reactive(list(
        title    = if (nzchar(input$title    %||% "")) input$title    else NULL,
        subtitle = if (nzchar(input$subtitle %||% "")) input$subtitle else NULL,
        caption  = if (nzchar(input$caption  %||% "")) input$caption  else NULL,
        xlab     = if (nzchar(input$xlab %||% "")) input$xlab else " ",
        ylab     = if (nzchar(input$ylab %||% "")) input$ylab else " ",
        colors   = parsed_colors(),
        hc_theme = input$hc_theme %||% NULL
        # use_js is NOT here — hd_opts() does not accept it
      )),
      # use_js returned separately for hd_make()
      use_js_r    = shiny::reactive(isTRUE(input$use_js)),
      dl_basename = dl_basename
    )
  })
}
