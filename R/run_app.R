#' Run the highdir Shiny app
#'
#' Launches the interactive app for creating charts with highdir functions.
#' Use parameters to change defaults or pass feature flags.
#'
#' @param ... Named options passed to the app (optional).
#' @param .return_app logical. If `TRUE`, return the `shiny.appobj` instead of launching it. Default is `FALSE`.
#' @param host Host to listen on (default "127.0.0.1").
#' @param port Port to listen on (default: random).
#' @param launch.browser Open browser automatically? (default: interactive())
#'
#' @return A \code{shiny.appobj}; called for its side effects.
#' @export
#' @examples
#' \dontrun{ highdir::run_app() }
run_app <- function(...,
                    .return_app = FALSE,
                    host = getOption("shiny.host", "127.0.0.1"),
                    port = getOption("shiny.port"),
                    launch.browser = getOption("shiny.launch.browser", interactive())) {

  app <- shiny::shinyApp(
    ui     = app_ui(),
    server = function(input, output, session) app_server(input, output, session, ...)
  )

  if (.return_app) {
    return(app)
  }

  shiny::runApp(app, host = host, port = port, launch.browser = launch.browser)
}
