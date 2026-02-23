test_that("build_fig returns highchart", {
  df <- data.frame(a = 1:3, b = 4:6)
  spec <- fig_spec(df, "a", "b")
  chart <- build_fig(spec, "line")
  expect_s3_class(chart, "highchart")
})
