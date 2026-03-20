# inst/app/modules/mod_opts.R
# ── Opts module ───────────────────────────────────────────────────────────────
#
# Responsibilities:
#   • Labels  (title, subtitle, caption, xlab, ylab)
#   • Style   (colours, HC theme, JS hover toggle)
#
# Downloads have been moved OUT of this module entirely.
# Download buttons are declared statically in ui.R (no renderUI, no module
# namespace) and handlers are registered in server.R.  This eliminates:
#   • The server round-trip that caused the button delay
#   • The namespace mismatch that made buttons grey/inactive
#   • The reactiveVal bridge that was needed to pass figures back here

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

      shiny::div(class = "hd-label", style = "margin-top:4px;", "Labels"),
      shiny::textInput(ns("title"),    NULL, placeholder = "Title"),
      shiny::textInput(ns("subtitle"), NULL, placeholder = "Subtitle"),
      shiny::textInput(ns("caption"),  NULL, placeholder = "Caption"),
      shiny::textInput(ns("xlab"),     NULL, placeholder = "X-axis label"),
      shiny::textInput(ns("ylab"),     NULL, placeholder = "Y-axis label"),
      shiny::textInput(ns("ysuffix"),  NULL, placeholder = "Y-tick suffix: %, km, mg ..."),
      shiny::textInput(ns("xtick_labels"),  NULL, placeholder = "x-tick labels, if different than x col"),
      shiny::textInput(ns("decimals"), NULL, placeholder = "Decimals points else as.is eg. 2"),

      shiny::div(class = "hd-label", "Style"),
      shiny::textInput(ns("colors"), NULL,
                       placeholder = "Colours: #025169, #7C145C, \u2026"),

      # flip belongs in opts (not geom_inputs) because base_fig reads opts$flip
      # for BOTH backends — ggplot2 via coord_flip(), highcharter via inverted.
      # It is shown for all geoms; for most it has no visible effect.
      shiny::checkboxInput(ns("flip"), "Flip axes", value = FALSE),

      # ggplot2 themes
      shiny::conditionalPanel(
        condition = "input.backend == 'ggplot2'",
        shiny::selectInput(ns("gg_theme"), NULL,
                           choices  = c("classic", "minimal", "bw",
                                        "light", "dark", "void",
                                        "grey"),
                           selected = "classic")
        ),

    # HC-only options — client-side conditionalPanel, no server cost
      shiny::conditionalPanel(
        condition = "input.backend == 'highcharter'",
        shiny::selectInput(ns("hc_theme"), NULL,
                           choices  = c("default", "smpl", "economist",
                                        "darkunica", "gridlight", "bloom",
                                        "flat", "flatdark", "ggplot2"),
                           selected = "default"),
        shiny::checkboxInput(ns("use_js"), "JS hover band", value = TRUE)
      )
    )
  )
}

# ── Server ────────────────────────────────────────────────────────────────────

#' @keywords internal
mod_opts_server <- function(id) {

  shiny::moduleServer(id, function(input, output, session) {

    parsed_colors <- shiny::reactive({
      raw <- trimws(input$colors %||% "")
      if (!nzchar(raw)) return(NULL)
      unname(strsplit(raw, "\\s*,\\s*")[[1]])
    })

    # Return only hd_opts() arguments + use_js separately (it goes to hd_make)
    list(
      opts_r = shiny::reactive(list(
        title    = if (nzchar(input$title    %||% "")) input$title    else NULL,
        subtitle = if (nzchar(input$subtitle %||% "")) input$subtitle else NULL,
        caption  = if (nzchar(input$caption  %||% "")) input$caption  else NULL,
        xlab     = if (nzchar(input$xlab     %||% "")) input$xlab     else " ",
        ylab     = if (nzchar(input$ylab     %||% "")) input$ylab     else " ",
        ysuffix  = if (nzchar(input$ysuffix  %||% "")) input$ysuffix  else NULL,
        xtick_labels  = if (nzchar(input$xtick_labels  %||% "")) input$xtick_labels  else NULL,
        decimals = {
          raw <- suppressWarnings(as.numeric(input$decimals))
          if (!is.null(raw) && !is.na(raw) && is.numeric(raw))
            as.integer(raw)
          else
            NULL
        },
        colors   = parsed_colors(),
        hc_theme = input$hc_theme %||% NULL,
        gg_theme = input$gg_theme %||% NULL,
        flip     = isTRUE(input$flip)
      )),
      use_js_r = shiny::reactive(isTRUE(input$use_js))
    )
  })
}
