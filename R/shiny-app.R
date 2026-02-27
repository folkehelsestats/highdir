# shiny-app.R — Interactive Shiny GUI for highdir
#
# Launches a full GUI that wraps make_fig() without the user needing to write
# any R code. Designed as a teaching / exploration tool.
#
# New over v1:
#   * Style panel: HC theme selector, colour palette, title/subtitle/caption
#   * use_js toggle (checkbox)
#   * smooth / dot_size controls for line charts
#   * SVG download for ggplot2
#   * PNG download for highcharter (shown only when webshot2 is installed)
#   * "R code" tab: shows equivalent make_fig() call
#   * Uses bslib when available for a modern look
#   * All downloads route through hd_save() — single export code path

#' Launch the highdir Shiny GUI
#'
#' Opens an interactive browser-based application for building figures with
#' either the `highcharter` or `ggplot2` backend, without writing R code.
#'
#' @details
#' The app allows users to:
#' \itemize{
#'   \item Upload a dataset in any format supported by the **rio** package.
#'   \item Choose a geometry, axis variables, and rendering backend.
#'   \item Configure chart title, subtitle, caption, and colour theme.
#'   \item Toggle JavaScript hover effects and the accessibility module.
#'   \item Render the figure on demand with the **Draw** button.
#'   \item Download as JSON or self-contained HTML (highcharter), PNG
#'     (highcharter, requires **webshot2**), or PNG / SVG (ggplot2).
#'   \item Copy the equivalent `make_fig()` call from the **R code** tab.
#' }
#'
#' @return Does not return a value; launches a Shiny app in the browser.
#'
#' @seealso [make_fig()], [fig_spec()], [hd_save()], [hd_set_theme()]
#'
#' @importFrom shiny shinyApp fluidPage titlePanel sidebarLayout sidebarPanel
#'   mainPanel fileInput selectInput textInput checkboxInput numericInput
#'   uiOutput actionButton downloadButton conditionalPanel plotOutput
#'   tableOutput verbatimTextOutput reactive eventReactive renderUI
#'   renderPlot renderTable renderText downloadHandler req tags icon br hr
#'   tabsetPanel tabPanel
#' @importFrom highcharter highchartOutput renderHighchart
#' @importFrom htmlwidgets saveWidget
#' @importFrom jsonlite write_json
#' @importFrom ggplot2 ggsave labs
#'
#' @export
run_app <- function() {

  has_bslib    <- requireNamespace("bslib",    quietly = TRUE)
  has_webshot2 <- requireNamespace("webshot2", quietly = TRUE)
  has_rio      <- requireNamespace("rio",      quietly = TRUE)

  if (!has_rio)
    stop("The 'rio' package is required to run the highdir Shiny app.\n",
         "Install it with: install.packages('rio')", call. = FALSE)

  # ---------------------------------------------------------------------------
  # Sidebar controls
  # ---------------------------------------------------------------------------
  sidebar_controls <- shiny::tagList(

    # Data upload
    shiny::fileInput("file", "Upload dataset",
                     accept = c(".csv", ".xlsx", ".xls", ".rds",
                                ".sav", ".dta", ".json")),

    # Chart type
    shiny::selectInput("geom",    "Geometry",
                       choices  = list_geoms(),
                       selected = "column"),
    shiny::selectInput("backend", "Backend",
                       choices  = list_backends(),
                       selected = "highcharter"),

    # Axis mapping (populated once data are loaded)
    shiny::uiOutput("ui_mapping"),

    # Geom-specific required args
    shiny::uiOutput("ui_required"),

    shiny::tags$hr(),

    # Labels
    shiny::textInput("title",    "Title",    placeholder = "Optional"),
    shiny::textInput("subtitle", "Subtitle", placeholder = "Optional"),
    shiny::textInput("caption",  "Caption",  placeholder = "Optional"),

    shiny::tags$hr(),

    # Style — HC theme (highcharter only)
    shiny::conditionalPanel(
      condition = "input.backend == 'highcharter'",
      shiny::selectInput(
        "hc_theme", "Highcharts theme",
        choices  = c("default", "smpl", "economist", "darkunica",
                     "gridlight", "bloom", "flat", "flatdark", "ggplot2"),
        selected = getOption("highdir.hc_theme", "default")
      )
    ),

    # Colours (both backends)
    shiny::textInput("colors", "Colours (comma-sep hex)",
                     placeholder = "#025169, #7C145C, ..."),

    shiny::tags$hr(),

    # Line chart options (shown only when geom = line)
    shiny::conditionalPanel(
      condition = "input.geom == 'line'",
      shiny::checkboxInput("smooth",   "Smooth spline",   value = TRUE),
      shiny::numericInput("dot_size",  "Dot size (px)", value = 4, min = 1, max = 20)
    ),

    # JS toggle (highcharter only)
    shiny::conditionalPanel(
      condition = "input.backend == 'highcharter'",
      shiny::checkboxInput("use_js", "Enable JS hover band", value = TRUE)
    ),

    shiny::tags$hr(),

    # Draw + downloads
    shiny::actionButton("run", "Draw", icon = shiny::icon("palette"),
                         class = "btn-primary"),
    shiny::br(), shiny::br(),
    shiny::textInput("dl_filename", "Download filename (no extension)",
                     placeholder = paste0("highdir-figure_", Sys.Date())),
    shiny::uiOutput("ui_downloads")
  )

  # ---------------------------------------------------------------------------
  # Main panel tabs
  # ---------------------------------------------------------------------------
  main_tabs <- shiny::tabsetPanel(
    shiny::tabPanel(
      "Figure",
      shiny::br(),
      shiny::conditionalPanel(
        condition = "input.backend == 'highcharter'",
        highcharter::highchartOutput("hc_out", height = "460px")
      ),
      shiny::conditionalPanel(
        condition = "input.backend == 'ggplot2'",
        shiny::plotOutput("gg_out", height = "460px")
      )
    ),
    shiny::tabPanel(
      "Data preview",
      shiny::br(),
      shiny::tableOutput("tbl_head")
    ),
    shiny::tabPanel(
      "R code",
      shiny::br(),
      shiny::verbatimTextOutput("code_preview")
    )
  )

  # ---------------------------------------------------------------------------
  # Assemble UI
  # ---------------------------------------------------------------------------
  ui <- if (has_bslib) {
    bslib::page_sidebar(
      title   = "highdir \u2014 Figure Builder",
      sidebar = bslib::sidebar(sidebar_controls, width = 310),
      main_tabs
    )
  } else {
    shiny::fluidPage(
      shiny::titlePanel("highdir \u2014 Figure Builder"),
      shiny::sidebarLayout(
        shiny::sidebarPanel(sidebar_controls, width = 3),
        shiny::mainPanel(main_tabs)
      )
    )
  }

  # ---------------------------------------------------------------------------
  # Server
  # ---------------------------------------------------------------------------
  server <- function(input, output, session) {

    # -- Data ------------------------------------------------------------------
    dataset <- shiny::reactive({
      shiny::req(input$file)
      rio::import(input$file$datapath)
    })

    output$tbl_head <- shiny::renderTable({
      shiny::req(dataset())
      utils::head(dataset(), 10)
    })

    # -- Dynamic axis UI -------------------------------------------------------
    output$ui_mapping <- shiny::renderUI({
      shiny::req(dataset())
      cols <- names(dataset())
      shiny::tagList(
        shiny::selectInput("x",     "X variable",     choices = cols),
        shiny::selectInput("y",     "Y variable",     choices = cols),
        shiny::selectInput("group", "Group variable",
                           choices = c("(none)" = "", cols)),
        shiny::selectInput("n_col", "Count column (tooltip)",
                           choices = c("(none)" = "", cols))
      )
    })

    # Geom-specific required arg inputs
    output$ui_required <- shiny::renderUI({
      shiny::req(input$geom, dataset())
      req_args <- get_geom(input$geom)$required_args
      if (length(req_args) == 0) return(NULL)
      cols <- names(dataset())
      shiny::tagList(
        lapply(req_args, function(a)
          shiny::selectInput(a, paste("Select:", a), choices = cols))
      )
    })

    # -- Download UI -----------------------------------------------------------
    output$ui_downloads <- shiny::renderUI({
      shiny::req(input$backend)
      if (input$backend == "highcharter") {
        btns <- list(
          shiny::downloadButton("dl_json", "JSON"),
          shiny::downloadButton("dl_html", "HTML")
        )
        if (has_webshot2)
          btns <- c(btns, list(shiny::downloadButton("dl_hc_png", "PNG")))
        do.call(shiny::tagList, btns)
      } else {
        shiny::tagList(
          shiny::downloadButton("dl_gg_png", "PNG"),
          shiny::downloadButton("dl_gg_svg", "SVG")
        )
      }
    })

    # -- Helpers ---------------------------------------------------------------

    # Parse colour text field into a vector or NULL
    parsed_colors <- shiny::reactive({
      raw <- trimws(input$colors %||% "")
      if (!nzchar(raw)) return(NULL)
      strsplit(raw, "\\s*,\\s*")[[1]]
    })

    # Collect required-arg values from dynamic UI
    geom_args <- shiny::reactive({
      shiny::req(input$geom)
      ra <- get_geom(input$geom)$required_args
      if (length(ra) == 0) return(list())
      args        <- lapply(ra, function(a) input[[a]])
      names(args) <- ra
      args
    })

    # -- Build fig_spec --------------------------------------------------------
    spec <- shiny::reactive({
      shiny::req(dataset(), input$x, input$y)
      fig_spec(
        data     = dataset(),
        x        = input$x,
        y        = input$y,
        group    = if (nzchar(input$group  %||% "")) input$group   else NULL,
        n        = if (nzchar(input$n_col  %||% "")) input$n_col   else NULL,
        title    = if (nzchar(input$title   %||% "")) input$title   else NULL,
        subtitle = if (nzchar(input$subtitle %||% "")) input$subtitle else NULL,
        caption  = if (nzchar(input$caption  %||% "")) input$caption  else NULL
      )
    })

    # Apply UI theme settings before each render
    apply_theme <- function() {
      if (!is.null(input$hc_theme))   options(highdir.hc_theme = input$hc_theme)
      if (!is.null(parsed_colors()))  options(highdir.colors   = parsed_colors())
    }

    # -- Render ----------------------------------------------------------------
    hc_fig <- shiny::eventReactive(input$run, {
      shiny::req(input$backend == "highcharter", spec())
      apply_theme()
      do.call(make_fig, c(
        list(
          spec         = spec(),
          type         = input$geom,
          backend      = "highcharter",
          use_js       = isTRUE(input$use_js),
          smooth       = isTRUE(input$smooth),
          dot_size     = input$dot_size %||% 4L,
          line_symbols = NULL,
          colors       = parsed_colors()
        ),
        geom_args()
      ))
    })

    gg_fig <- shiny::eventReactive(input$run, {
      shiny::req(input$backend == "ggplot2", spec())
      apply_theme()
      do.call(make_fig, c(
        list(
          spec         = spec(),
          type         = input$geom,
          backend      = "ggplot2",
          smooth       = isTRUE(input$smooth),
          dot_size     = input$dot_size %||% 4L,
          line_symbols = NULL,
          colors       = parsed_colors()
        ),
        geom_args()
      ))
    })

    output$hc_out <- highcharter::renderHighchart(hc_fig())
    output$gg_out <- shiny::renderPlot(gg_fig())

    # -- R code preview --------------------------------------------------------
    output$code_preview <- shiny::renderText({
      shiny::req(input$x, input$y, input$geom, input$backend)

      group_line <- if (nzchar(input$group %||% ""))
        paste0('  group    = "', input$group, '",\n') else ""
      n_line <- if (nzchar(input$n_col %||% ""))
        paste0('  n        = "', input$n_col, '",\n') else ""
      title_line <- if (nzchar(input$title %||% ""))
        paste0('  title    = "', input$title, '",\n') else ""
      sub_line <- if (nzchar(input$subtitle %||% ""))
        paste0('  subtitle = "', input$subtitle, '",\n') else ""
      cap_line <- if (nzchar(input$caption %||% ""))
        paste0('  caption  = "', input$caption, '",\n') else ""

      extra <- geom_args()
      extra_str <- if (length(extra) > 0) {
        paste0(
          ",\n  ",
          paste(names(extra), paste0('"', unlist(extra), '"'),
                sep = " = ", collapse = ",\n  ")
        )
      } else ""

      js_line    <- if (input$backend == "highcharter")
        paste0(',\n  use_js   = ', isTRUE(input$use_js)) else ""
      smooth_line <- if (input$geom == "line")
        paste0(',\n  smooth   = ', isTRUE(input$smooth)) else ""

      paste0(
        "spec <- fig_spec(\n",
        "  data     = your_data,\n",
        '  x        = "', input$x, '",\n',
        '  y        = "', input$y, '",\n',
        group_line, n_line, title_line, sub_line, cap_line,
        ")\n\n",
        "make_fig(\n",
        "  spec    = spec,\n",
        '  type    = "', input$geom, '",\n',
        '  backend = "', input$backend, '"',
        js_line, smooth_line, extra_str,
        "\n)"
      )
    })

    # -- Downloads (all via hd_save()) -----------------------------------------

    # Resolve the base filename from user input:
    #   * strip any trailing extension the user may have typed
    #   * fall back to a dated default when the field is blank
    dl_basename <- shiny::reactive({
      raw <- trimws(input$dl_filename %||% "")
      if (!nzchar(raw)) {
        return(paste0("highdir-figure_", Sys.Date()))
      }
      # Remove extension if present (e.g. "chart.html" → "chart")
      tools::file_path_sans_ext(raw)
    })

    dl_handler <- function(ext, fig_reactive) {
      shiny::downloadHandler(
        filename = function() paste0(dl_basename(), ".", ext),
        content  = function(file) {
          shiny::req(fig_reactive())
          hd_save(fig_reactive(), file, type = ext)
        }
      )
    }

    output$dl_json   <- dl_handler("json", hc_fig)
    output$dl_html   <- dl_handler("html", hc_fig)
    output$dl_hc_png <- dl_handler("png",  hc_fig)
    output$dl_gg_png <- dl_handler("png",  gg_fig)
    output$dl_gg_svg <- dl_handler("svg",  gg_fig)
  }

  shiny::shinyApp(ui, server)
}
