# tests/testthat/helper.R ── Shared test fixtures (auto-loaded by testthat)

#' Standard health-survey data frame used across tests
survey_df <- data.frame(
  age = rep(c("18-24", "25-34", "35-44", "45-54"), each = 2),
  sex = rep(c("Male", "Female"), 4),
  pct = c(42, 38, 55, 61, 48, 52, 60, 57),
  lo  = c(37, 33, 50, 56, 43, 47, 55, 52),
  hi  = c(47, 43, 60, 66, 53, 57, 65, 62),
  n   = c(120, 115, 200, 210, 180, 175, 160, 155)
)

#' Standard pie data frame
pie_df <- data.frame(
  category = c("Aldri", "Sjelden", "Av og til", "Ofte"),
  value    = c(35, 25, 25, 15)
)
