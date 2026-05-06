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

    # Auto-resize behavior
    shiny::tags$script(sprintf("
      document.addEventListener('DOMContentLoaded', function() {
        const el = document.getElementById('%s');
        if (!el) return;

        const maxHeight = 200;

        function resize() {
          el.style.height = 'auto';
          el.style.height = Math.min(el.scrollHeight, maxHeight) + 'px';
        }

        el.addEventListener('input', resize);
        resize();
      });
    ", ns("description"))),

    
    shiny::tags$button(
      class         = "hd-toggle",
      `data-target` = paste0("#", ns("panel-opts")),
      shiny::span("Opts \u2014 labels & style"),
      shiny::span(class = "hd-arrow", "\u25bc")
    ),

    shiny::div(
      id    = ns("panel-opts"),
      class = "hd-collapse",

      # Use of textInput to be able to describe the functions
      shiny::div(class = "hd-label", style = "margin-top:4px;", "Labels"),
      shiny::textInput(ns("title"),    NULL, placeholder = "Title"),
      shiny::textInput(ns("subtitle"), NULL, placeholder = "Subtitle"),
      shiny::textInput(ns("caption"),  NULL, placeholder = "Caption"),
      shiny::textInput(ns("xlab"),     NULL, placeholder = "X-axis label"),
      shiny::textInput(ns("ylab"),     NULL, placeholder = "Y-axis label"),
      shiny::textInput(ns("ylim"),     NULL, placeholder = "Y-axis limits eg. c(10, 80)"),
      shiny::textInput(ns("yint"),     NULL, placeholder = "Y-axis interval"),
      shiny::textInput(ns("ysuffix"),  NULL, placeholder = "Y-tick suffix: %, km, mg ..."),
      shiny::textInput(ns("xtick_labels"),  NULL, placeholder = "x-tick labels, if different than x col"),
      shiny::textInput(ns("decimals"), NULL, placeholder = "Decimals points else as.is eg. 2"),
      shiny::textInput(ns("description"), NULL, placeholder = "Figure description for screen readers"),
      

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
        xlab     = input_labs(input$xlab),
        ylab     = input_labs(input$ylab),
        ylim = parse_ylim(input$ylim),
        yint = parse_yint(input$yint, default = 10),
        ysuffix  = if (nzchar(input$ysuffix  %||% "")) input$ysuffix  else NULL,
        xtick_labels  = if (nzchar(input$xtick_labels  %||% "")) input$xtick_labels  else NULL,
        decimals = {
          raw <- suppressWarnings(as.numeric(input$decimals))
          if (!is.null(raw) && !is.na(raw) && is.numeric(raw))
            as.integer(raw)
          else
            NULL
        },
        description = if (nzchar(input$description  %||% "")) input$description  else NULL,
        colors   = parsed_colors(),
        hc_theme = input$hc_theme %||% NULL,
        gg_theme = input$gg_theme %||% NULL,
        flip     = isTRUE(input$flip)
      )),
      use_js_r = shiny::reactive(isTRUE(input$use_js))
    )
  })
}


input_labs <- function(input) {
    x <- input %||% "" # x is always a character now ("" if NULL)

    # Case: user wants to hide (accept "NULL" in any case, with optional surrounding space)
    is_hide <- is.character(x) && length(x) == 1 &&
        grepl("^\\s*NULL\\s*$", x, ignore.case = TRUE)

    # Case: default sentinel (" ") OR the user cleared the box to empty ""
    is_default <- identical(x, " ") || identical(x, "")

    if (is_hide) {
        NULL # pass NULL to labs() to remove the title
    } else if (is_default) {
        " " # keep sentinel so you can detect "default" upstream if needed
    } else {
        x # use the entered text as-is
    }
}

# Able to write eg. c(10, 60)
parse_ylim <- function(x) {
  x <- x %||% ""
  if (!nzchar(x)) return(NULL)

  x <- gsub("\\s+", "", x)

  # Accept only c(num, num)
  if (!grepl("^c\\(-?[0-9.]+,-?[0-9.]+\\)$", x)) return(NULL)

  out <- tryCatch(eval(parse(text = x)), error = function(e) NULL)

  if (is.numeric(out) && length(out) == 2) out else NULL
}

# For numberic value
parse_yint <- function(x, default = 10) {
  x <- x %||% ""
  if (!nzchar(x)) return(default)

  val <- suppressWarnings(as.numeric(x))
  if (is.na(val)) default else val
}
