test_that("register_palette round-trips through get/list", {
  register_palette("test_blue", c("#084594", "#2171b5", "#4292c6"))
  expect_true("test_blue" %in% list_palettes())
  expect_equal(get_palette("test_blue"),
               c("#084594", "#2171b5", "#4292c6"))
})

test_that("register_palette: rejects non-character or empty", {
  expect_error(register_palette("x", 1:3),            "character")
  expect_error(register_palette("x", character(0)),   "non-empty")
})

test_that("list_palettes returns sorted names", {
  p <- list_palettes()
  expect_equal(p, sort(p))
})

test_that("built-in hdir palette has 10 hex colours", {
  pal <- get_palette("hdir")
  expect_length(pal, 10)
  expect_true(all(grepl("^#", pal)))
})

test_that("built-in hdir2 palette has 2 entries", {
  expect_length(get_palette("hdir2"), 2)
})

test_that("resolve_colors: correct length for various n", {
  for (n in c(1, 2, 5, 10, 14)) {
    expect_length(resolve_colors(n), n,
                  label = paste("n =", n))
  }
})

test_that("resolve_colors: explicit override used when long enough", {
  pal <- c("#AABBCC", "#DDEEFF", "#001122")
  expect_equal(resolve_colors(2, pal), pal[1:2])
  expect_equal(resolve_colors(3, pal), pal)
})

test_that("resolve_colors: palette name string resolved correctly", {
  register_palette("named_test", c("#000001", "#000002", "#000003"))
  expect_equal(resolve_colors(2, "named_test"), c("#000001", "#000002"))
})

test_that("resolve_colors: getOption override respected", {
  withr::with_options(
    list(highdir.colors = c("#AA0000", "#00AA00", "#0000AA")),
    expect_equal(resolve_colors(2), c("#AA0000", "#00AA00"))
  )
})
