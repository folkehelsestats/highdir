#' Draw Highdir Shiny Application
#'
#' Launches an interactive Shiny GUI for building figures using either the
#' \pkg{highcharter} or \pkg{ggplot2} backend, without writing R commands manually.
#'
#' The app allows users to:
#' \itemize{
#'   \item Upload a dataset in almost any format and preview its contents.
#'   \item Select a geometry, axis variables, and rendering backend.
#'   \item Render the figure on demand via a \strong{Draw} button.
#'   \item Download the figure as JSON or self-contained HTML (highcharter)
#'     or PNG (ggplot2).
#' }
#'
#' @return Launches a Shiny app; does not return a value.
#'
#' @seealso [make_fig()], [fig_spec()], [list_geoms()], [list_backends()]
#'
#' @importFrom shiny fluidPage titlePanel sidebarLayout sidebarPanel mainPanel
#'   fileInput selectInput uiOutput actionButton downloadButton conditionalPanel
#'   plotOutput tableOutput reactive renderUI renderPlot renderTable
#'   downloadHandler req tags shinyApp
#' @importFrom highcharter highchartOutput renderHighchart
#' @importFrom htmlwidgets saveWidget
#' @importFrom jsonlite write_json
#' @importFrom rio import
#' @importFrom ggplot2 ggsave
#'
#' @export
run_app <- function() {

  # ---------------------------------------------------------------------------
  # UI
  # ---------------------------------------------------------------------------
  ui <- shiny::fluidPage(
    shiny::titlePanel("Highdir GUI"),
    shiny::sidebarLayout(
      shiny::sidebarPanel(

        shiny::fileInput("file", "Upload dataset"),

        shiny::selectInput(
          "geom",
          "Geometry",
          choices = list_geoms(),
          selected = "column"
        ),

        shiny::selectInput(
          "backend",
          "Backend",
          choices  = list_backends(),
          selected = "highcharter" #default
        ),

        # Axis variable selectors — populated once data are loaded.
        shiny::uiOutput("dynamic_mapping"),

        # Geometry-specific extra arguments — populated based on geom choice.
        shiny::uiOutput("dynamic_required"),

        # Render is triggered explicitly so the user controls when computation runs.
        shiny::actionButton("run", "Draw", icon = shiny::icon("palette"),
                            class = "btn-primary"),

        shiny::tags$hr(),

        # Download button label and file options depend on the active backend.
        # Rendered dynamically in the server so it can react to input$backend.
        shiny::uiOutput("download_ui")
      ),

      shiny::mainPanel(

        # Highcharter output — shown only when highcharter backend is active.
        shiny::conditionalPanel(
          condition = "input.backend == 'highcharter'",
          highcharter::highchartOutput("hc_out")
        ),

        # ggplot2 output — shown only when ggplot2 backend is active.
        shiny::conditionalPanel(
          condition = "input.backend == 'ggplot2'",
          shiny::plotOutput("ggplot_out")
        ),

        shiny::tags$hr(),

        # First ten rows of the uploaded dataset for quick inspection.
        shiny::tableOutput("head")
      )
    )
  )

  # ---------------------------------------------------------------------------
  # Server
  # ---------------------------------------------------------------------------
  server <- function(input, output, session) {

    # -- Data ------------------------------------------------------------------

    # Load and cache the uploaded file reactively.
    dataset <- shiny::reactive({
      shiny::req(input$file)
      rio::import(input$file$datapath)
    })

    # Preview the first 10 rows whenever data change.
    output$head <- shiny::renderTable({
      shiny::req(dataset())
      utils::head(dataset(), 10)
    })

    # -- Dynamic UI ------------------------------------------------------------

    # Populate X / Y selectors from the column names of the loaded dataset.
    output$dynamic_mapping <- shiny::renderUI({
      shiny::req(dataset())
      cols <- names(dataset())
      shiny::tagList(
        shiny::selectInput("x", "X variable", choices = cols),
        shiny::selectInput("y", "Y variable", choices = cols)
      )
    })

    # Populate geometry-specific required argument selectors.
    output$dynamic_required <- shiny::renderUI({
      shiny::req(input$geom)
      geom     <- get_geom(input$geom)
      req_args <- geom$required_args
      if (length(req_args) == 0) return(NULL)
      cols <- names(dataset())
      shiny::tagList(
        lapply(req_args, function(arg) {
          shiny::selectInput(arg, paste("Select", arg), choices = cols)
        })
      )
    })

    # Render the download button with format choices appropriate for the backend.
    output$download_ui <- shiny::renderUI({
      shiny::req(input$backend)
      if (input$backend == "highcharter") {
        shiny::tagList(
          shiny::downloadButton("download_json", "JSON"),
          shiny::downloadButton("download_html", "HTML")
        )
      } else {
        # ggplot2 supports raster export via ggsave.
        shiny::downloadButton("download_png", "PNG")
      }
    })

    # -- Figure specification --------------------------------------------------

    # Build the figure spec; only recomputes when upstream inputs change,
    # not on every button click — the render outputs handle the Draw button.
    spec <- shiny::reactive({
      shiny::req(dataset(), input$x, input$y)
      fig_spec(data = dataset(), x = input$x, y = input$y)
    })

    # Helper: collect optional geometry arguments from dynamic UI inputs.
    geom_args <- shiny::reactive({
      shiny::req(input$geom)
      req_args <- get_geom(input$geom)$required_args
      args      <- lapply(req_args, function(a) input[[a]])
      names(args) <- req_args
      args
    })

    # -- Rendering (gated on the Draw button) -----------------------------------

    # eventReactive ties rendering to the Draw button; isolate() prevents
    # re-rendering whenever individual inputs change mid-session.
    hc_figure <- shiny::eventReactive(input$run, {
      shiny::req(input$backend == "highcharter", spec())
      do.call(
        make_fig,
        c(list(spec = spec(), type = input$geom, backend = "highcharter"),
          geom_args())
      )
    })

    gg_figure <- shiny::eventReactive(input$run, {
      shiny::req(input$backend == "ggplot2", spec())
      do.call(
        make_fig,
        c(list(spec = spec(), type = input$geom, backend = "ggplot2"),
          geom_args())
      )
    })

    output$hc_out <- highcharter::renderHighchart({
      hc_figure()
    })

    output$ggplot_out <- shiny::renderPlot({
      gg_figure()
    })

    # -- Downloads -------------------------------------------------------------

    # JSON: serialise the figure specification (data + mapping + options).
    output$download_json <- shiny::downloadHandler(
      filename = function() paste0("fig_", Sys.Date(), ".json"),
      content  = function(file) {
        shiny::req(input$backend == "highcharter")
        jsonlite::write_json(hc_figure()$x$hc_opts,
                             path = file,
                             pretty = TRUE,
                             auto_unbox = TRUE)
      }
    )

    # HTML: save the highcharter widget as a self-contained HTML file so that
    # the interactive chart can be shared without a running R session.
    output$download_html <- shiny::downloadHandler(
      filename = function() paste0("fig_", Sys.Date(), ".html"),
      content  = function(file) {
        shiny::req(input$backend == "highcharter", hc_figure())
        # selfcontained = TRUE embeds all JS/CSS so the file is portable.
        htmlwidgets::saveWidget(hc_figure(), file = file, selfcontained = TRUE)
      }
    )

    # PNG: render the ggplot2 figure to a temporary file and stream it.
    output$download_png <- shiny::downloadHandler(
      filename = function() paste0("fig_", Sys.Date(), ".png"),
      content  = function(file) {
        shiny::req(input$backend == "ggplot2", gg_figure())
        ggplot2::ggsave(file, plot = gg_figure(), device = "png",
                        width = 8, height = 6, dpi = 300)
      }
    )
  }

  shiny::shinyApp(ui, server)
}
