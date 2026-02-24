#' Run Highdir Shiny Application
#'
#' Launches an interactive GUI for building figures without
#' writing R commands manually.
#'
#' @export
run_app <- function() {

  ui <- shiny::fluidPage(

    shiny::titlePanel("Highdir Figure Builder"),

    shiny::sidebarLayout(

      shiny::sidebarPanel(

        shiny::fileInput("file", "Upload CSV file"),

        shiny::selectInput("geom",
                           "Geometry",
                           choices = list_geoms()),

        shiny::selectInput("backend",
                           "Backend",
                           choices = list_backends()),

        shiny::uiOutput("dynamic_mapping"),
        shiny::uiOutput("dynamic_required")

      ),

      shiny::mainPanel(
        shiny::conditionalPanel(
          condition = "input.backend == 'ggplot2'",
          shiny::plotOutput("ggplot_out")
        ),

        shiny::conditionalPanel(
          condition = "input.backend == 'highcharter'",
          highcharter::highchartOutput("hc_out")
        )
      )
    )
  )

  server <- function(input, output, session) {

    dataset <- shiny::reactive({
      shiny::req(input$file)
      rio::import(input$file$datapath)
    })

    output$dynamic_mapping <- shiny::renderUI({
      shiny::req(dataset())

      cols <- names(dataset())

      shiny::tagList(
        shiny::selectInput("x", "X variable", choices = cols),
        shiny::selectInput("y", "Y variable", choices = cols)
      )
    })

    output$dynamic_required <- shiny::renderUI({
      shiny::req(input$geom)

      geom <- get_geom(input$geom)
      req_args <- geom$required_args

      if (length(req_args) == 0)
        return(NULL)

      cols <- names(dataset())

      shiny::tagList(
        lapply(req_args, function(arg) {
          shiny::selectInput(arg,
                             paste("Select", arg),
                             choices = cols)
        })
      )
    })

    spec <- shiny::reactive({
      shiny::req(dataset(), input$x, input$y)

      fig_spec(
        data = dataset(),
        x = input$x,
        y = input$y
      )
    })

    output$ggplot_out <- shiny::renderPlot({
      shiny::req(input$backend == "ggplot2")

      args <- lapply(
        get_geom(input$geom)$required_args,
        function(a) input[[a]]
      )
      names(args) <- get_geom(input$geom)$required_args

      do.call(
        make_fig,
        c(
          list(
            spec = spec(),
            type = input$geom,
            backend = "ggplot2"
          ),
          args
        )
      )
    })

    output$hc_out <- highcharter::renderHighchart({
      shiny::req(input$backend == "highcharter")

      args <- lapply(
        get_geom(input$geom)$required_args,
        function(a) input[[a]]
      )
      names(args) <- get_geom(input$geom)$required_args

      do.call(
        make_fig,
        c(
          list(
            spec = spec(),
            type = input$geom,
            backend = "highcharter"
          ),
          args
        )
      )
    })
  }

  shiny::shinyApp(ui, server)
}
