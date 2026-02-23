test_that("fig_spec constructs correctly", {
  df <- data.frame(a = 1:3, b = 4:6)
  spec <- fig_spec(df, "a", "b")
  expect_s3_class(spec, "fig_spec")
  expect_equal(spec$xlab, "a")
})
