test_that("fig_spec creates object", {
  df <- data.frame(x = 1:3, y = 4:6)
  spec <- fig_spec(df, "x", "y")
  expect_s3_class(spec, "fig_spec")
})
