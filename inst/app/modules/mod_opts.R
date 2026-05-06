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

      shiny::textInput(ns("ylim"), NULL, placeholder = "Y-axis limits eg. c(10, 80)"),
      shiny::uiOutput(ns("ylim_warn")),

      shiny::textInput(ns("yint"), NULL, placeholder = "Y-axis interval"),
      shiny::uiOutput(ns("yint_warn")),

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

    ## -------- live validation messages --------
    output$ylim_warn <- shiny::renderUI({
      x <- input$ylim %||% ""
      if (!nzchar(x)) return(NULL)

      if (!is_valid_ylim(x)) {
        shiny::div(
          class = "text-danger small",
          "Invalid format. Use: c(min, max), e.g. c(10, 80)"
        )
      }
    })

    output$yint_warn <- shiny::renderUI({
      x <- input$yint %||% ""
      if (!nzchar(x)) return(NULL)

      if (!is_valid_yint(x)) {
        shiny::div(
          class = "text-danger small",
          "Must be a numeric value (e.g. 5 or 10)"
        )
      }
    })

    # --- colors
    parsed_colors <- shiny::reactive({
      raw <- trimws(input$colors %||% "")
      if (!nzchar(raw)) return(NULL)
      strsplit(raw, "\\s*,\\s*")[[1]]
    })

    list(
      opts_r = shiny::reactive(list(
        title    = parse_input(input$title),
        subtitle = parse_input(input$subtitle),
        caption  = parse_input(input$caption),

        xlab = input_labs(input$xlab),
        ylab = input_labs(input$ylab),

        ylim = parse_ylim(input$ylim),
        yint = parse_yint(input$yint, default = 10),

        ysuffix = parse_input(input$ysuffix),
        xtick_labels = parse_input(input$xtick_labels),

        decimals = parse_input(
          input$decimals,
          coerce  = coerce_numeric,
          default = NULL
        ),

        description = parse_input(input$description),

        colors   = parsed_colors(),
        hc_theme = input$hc_theme %||% NULL,
        gg_theme = input$gg_theme %||% NULL,
        flip     = isTRUE(input$flip)
      )),
      use_js_r = shiny::reactive(isTRUE(input$use_js))
    )
  })
}

# Helper -----------------------------------------------------------------------

parse_input <- function(
  x,
  coerce       = identity,
  default      = NULL,
  empty_is     = NULL,
  allow_null   = TRUE,
  sentinel     = NULL
) {
  x <- x %||% ""

  # Hide value explicitly requested
  if (allow_null && grepl("^\\s*NULL\\s*$", x, ignore.case = TRUE))
    return(NULL)

  # Empty input
  if (!nzchar(x))
    return(empty_is)

  # Sentinel (e.g. " ")
  if (!is.null(sentinel) && identical(x, sentinel))
    return(sentinel)

  # Try coercion
  out <- tryCatch(coerce(x), error = function(e) default)

  if (is.null(out) || (is.atomic(out) && anyNA(out)))
    default
  else
    out
}

# logic
coerce_label <- function(x) x

coerce_numeric <- function(x)
  suppressWarnings(as.numeric(x))

coerce_ylim <- function(x) {
  x <- gsub("\\s+", "", x)
  if (!grepl("^c\\(-?[0-9.]+,-?[0-9.]+\\)$", x))
    stop("Invalid ylim")

  y <- eval(parse(text = x))
  if (!is.numeric(y) || length(y) != 2)
    stop("ylim must be length 2")

  y
}

# Validator
is_valid_ylim <- function(x) {
  !is.null(parse_ylim(x))
}

is_valid_yint <- function(x) {
  val <- suppressWarnings(as.numeric(x))
  nzchar(x) && !is.na(val)
}


# Functions
input_labs <- function(x) {
  parse_input(
    x,
    coerce     = coerce_label,
    empty_is   = " ",
    sentinel   = " ",
    allow_null = TRUE
  )
}

parse_ylim <- function(x) {
  parse_input(
    x,
    coerce     = coerce_ylim,
    empty_is   = NULL,
    allow_null = TRUE
  )
}

parse_yint <- function(x, default = 10) {
  parse_input(
    x,
    coerce     = coerce_numeric,
    default    = default,
    empty_is   = default,
    allow_null = FALSE
  )
}
