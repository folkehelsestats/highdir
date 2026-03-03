# R/shiny-app.R ── Shiny GUI launcher

#' Launch the highdir Shiny GUI
#'
#' Opens an interactive browser-based application for building figures with
#' `highcharter` or `ggplot2` without writing R code.
#'
#' The UI (`inst/app/ui.R`), server (`inst/app/server.R`) and shared setup
#' (`inst/app/global.R`) live in `inst/app/` so the folder can be deployed
#' independently to Shiny Server or shinyapps.io.
#'
#' @section Features:
#' \itemize{
#'   \item Upload datasets in any format supported by **rio** (CSV, XLSX,
#'     SPSS, Stata, RDS, …).
#'   \item Choose geometry (`column`, `line`, `scatter`, `arearange`, `pie`),
#'     backend, axis variables, and group column.
#'   \item Set title, subtitle, caption, colour palette, and HC theme.
#'   \item Toggle JS hover band per figure.
#'   \item Render on demand with the **Draw** button.
#'   \item Download as HTML / JSON / PNG (highcharter) or PNG / SVG (ggplot2).
#'   \item Copy the equivalent `hd_make()` call from the **R code** tab.
#' }
#'
#' @return Launches a Shiny app; does not return a value.
#' @seealso [hd_make()], [hd_spec()], [hd_opts()], [hd_save()]
#' @export
hd_app <- function() {
  app_dir <- system.file("app", package = "highdir")
  if (!nzchar(app_dir) || !dir.exists(app_dir))
    stop("Could not find inst/app/. Is highdir installed?", call. = FALSE)
  shiny::runApp(app_dir)
}
