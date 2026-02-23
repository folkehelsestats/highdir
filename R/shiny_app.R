#' Run Figure Builder App
#'
#' Launch interactive Shiny interface.
#'
#' @export
run_app <- function() {

  shiny::shinyApp(
    ui = shiny::fluidPage(
      shiny::titlePanel("Highdir Figure Builder"),
      shiny::sidebarLayout(
        shiny::sidebarPanel(
          shiny::fileInput("file", "Upload CSV"),
          shiny::uiOutput("column_select"),
          shiny::selectInput("geom", "Chart Type", choices = list_geoms()),
          shiny::uiOutput("extra_args")
        ),
        shiny::mainPanel(
          highcharter::highchartOutput("chart")
        )
      )
    ),
    server = function(input, output, session) {

      dataset <- shiny::reactive({
        req(input$file)
        read.csv(input$file$datapath)
      })

      output$column_select <- shiny::renderUI({
        req(dataset())
        cols <- names(dataset())
        tagList(
          shiny::selectInput("x", "X variable", cols),
          shiny::selectInput("y", "Y variable", cols)
        )
      })

      output$extra_args <- shiny::renderUI({
        req(input$geom, dataset())
        geom <- get_geom(input$geom)
        if (length(geom$required_args) == 0) return(NULL)

        lapply(geom$required_args, function(arg) {
          shiny::selectInput(arg, arg, names(dataset()))
        })
      })

      spec <- shiny::reactive({
        fig_spec(dataset(), input$x, input$y)
      })

      output$chart <- highcharter::renderHighchart({
        req(spec(), input$geom)
        geom <- get_geom(input$geom)
        args <- lapply(geom$required_args, function(arg) input[[arg]])
        names(args) <- geom$required_args
        do.call(build_fig, c(list(spec(), input$geom), args))
      })
    }
  )
}
