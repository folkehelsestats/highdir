test_that("registry lists geoms", {
  expect_true("line" %in% list_geoms())
})
