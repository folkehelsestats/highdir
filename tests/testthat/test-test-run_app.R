test_that("run_app() constructs a shiny app object", {
  skip_on_cran()
  skip_if_not_installed("shiny")

  app <- highdir::run_app(.return_app = TRUE)

  expect_s3_class(app, "shiny.appobj")
})
