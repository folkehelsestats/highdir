spec_st <- hd_spec(
  olympics,
  x = "Medal",
  y = "Count",
  group = "Country",
  n = "pros"
)

opts_st <- hd_opts(
  title = "Olympic Games all-time medal table, grouped by continent",
  subtitle = "Source: Olympics",
  ylab = "Count medals"
)

fig <- hd_make(
  spec_st,
  "stacked_column",
  opts_st,
  stack = "Continent"
)
# ------------------------------------------------------------------------------
# Test tooltip formatting for stacked column chart
# ------------------------------------------------------------------------------

test_that("HC: Norway series has correct data values with %(n)", {
  series <- fig$x$hc_opts$series
  norway <- Filter(function(s) s$name == "Norway", series)[[1]]

  expect_equal(
    unlist(norway$data),
    c(
      y = 148, pros = 36.5,
      y = 133, pros = 32.8,
      y = 124, pros = 30.6
    )
  )
})
