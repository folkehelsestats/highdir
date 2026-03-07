# tests/testthat/test-palettes.R

test_that("resolve_colors: correct length for various n", {
  skip_if_not_installed("viridis")
  for (n in c(1, 2, 5, 10, 14)) {
    result <- resolve_colors(n)
    expect_equal(
      length(result), n,
      label = paste0("resolve_colors(", n, ")")
    )
  }
})

test_that("resolve_colors: n=2 returns hdir2 not hdir[1:2]", {
  result <- resolve_colors(2)
  hdir2  <- get_palette("hdir2")
  expect_equal(result, hdir2[1:2])
  expect_false(identical(result, get_palette("hdir")[1:2]))
})

test_that("resolve_colors: n=1 returns first hdir colour", {
  result <- resolve_colors(1)
  expect_equal(length(result), 1L)
  expect_equal(result, get_palette("hdir")[1])
})

test_that("resolve_colors: n=10 returns full hdir palette", {
  result <- resolve_colors(10)
  expect_equal(result, get_palette("hdir"))
})

test_that("resolve_colors: n=11 uses viridis with no duplicates", {
  skip_if_not_installed("viridis")
  result <- resolve_colors(11)
  expect_length(result, 11)
  expect_equal(length(unique(result)), 11)
})

test_that("resolve_colors: explicit colours used when long enough", {
  cols   <- c("#AA0000", "#00AA00", "#0000AA")
  result <- resolve_colors(3, colors = cols)
  expect_equal(result, cols)
})

test_that("resolve_colors: too-short explicit palette warns and falls through", {
  expect_warning(
    result <- resolve_colors(5, colors = c("#FF0000", "#00FF00")),
    regexp = "2 colour"
  )
  expect_equal(result, get_palette("hdir")[1:5])
})

test_that("resolve_colors: palette name string resolved correctly", {
  result <- resolve_colors(3, colors = "hdir")
  expect_equal(result, get_palette("hdir")[1:3])
})

test_that("resolve_colors: all returned values are character strings", {
  for (n in c(1, 2, 5, 10)) {
    result <- resolve_colors(n)
    expect_type(result, "character")
  }
})

test_that("all registered palette colours are valid R colour strings", {
  for (name in list_palettes()) {
    pal <- get_palette(name)
    for (col in pal) {
      expect_true(
        tryCatch({ grDevices::col2rgb(col); TRUE }, error = function(e) FALSE),
        label = paste0("palette '", name, "' colour '", col,
                       "' must be a valid R colour")
      )
    }
  }
})

test_that("hdir2 colours parse in both ggplot2 and as hex", {
  hdir2 <- get_palette("hdir2")
  expect_equal(length(hdir2), 2L)
  # Both must be valid R colours
  expect_no_error(grDevices::col2rgb(hdir2[1]))
  expect_no_error(grDevices::col2rgb(hdir2[2]))
  # Both should be hex format
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", hdir2)))
})
