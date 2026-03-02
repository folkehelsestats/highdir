test_that("ggplot backend works", {
  df <- data.frame(x = 1:3, y = 4:6)
  spec <- fig_spec(df, "x", "y")
  fig <- make_fig(spec, "line", backend = "ggplot2")
  expect_s3_class(fig, "ggplot")
})
