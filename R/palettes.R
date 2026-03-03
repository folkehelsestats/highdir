# R/palettes.R ── Named colour palette registry
#
# Palettes are stored in a plain environment (.palette_registry).  Built-in
# palettes are registered in .onLoad() (see zzz.R).  Users and extension
# packages can add their own with register_palette().
#
# resolve_colors() is the *single* function every geom calls to obtain a
# colour vector — it respects both explicit overrides and session defaults.

# ── Registry environment ─────────────────────────────────────────────────────

#' @keywords internal
.palette_registry <- new.env(parent = emptyenv())

# ── Public API ───────────────────────────────────────────────────────────────

#' Register a Named Colour Palette
#'
#' Adds a named palette to the highdir palette registry so it can be
#' referenced by name wherever colours are accepted
#' (e.g. `fig_opts(colors = "my_palette")`).
#'
#' Built-in palettes registered at package load time:
#'
#' | Name     | Description |
#' |:---------|:------------|
#' | `"hdir"` | Helsedirektoratet 10-colour brand palette |
#' | `"hdir2"`| 2-colour teal / purple pair |
#'
#' @param name   Character. Unique palette identifier.
#' @param colors Non-empty character vector of CSS/hex colour strings.
#'
#' @return `name`, invisibly.
#'
#' @examples
#' register_palette("blues", c("#084594", "#2171b5", "#4292c6", "#6baed6"))
#' get_palette("blues")
#'
#' @export
register_palette <- function(name, colors) {
  if (!is.character(colors) || length(colors) == 0)
    stop("`colors` must be a non-empty character vector.", call. = FALSE)
  .palette_registry[[name]] <- colors
  invisible(name)
}

#' List Registered Palettes
#'
#' @return Character vector of registered palette names.
#' @examples
#' list_palettes()
#' @export
list_palettes <- function() sort(ls(.palette_registry))

#' Retrieve a Named Palette
#'
#' @param name Character. Palette name (see [list_palettes()]).
#' @return Character vector of colours, or `NULL` if not found.
#' @examples
#' get_palette("hdir")
#' @export
get_palette <- function(name) .palette_registry[[name]]

# ── Colour resolution (internal) ─────────────────────────────────────────────

#' Resolve a Colour Vector for n Groups
#'
#' Returns exactly `n` colours.  Priority order:
#'
#' 1. Explicit `colors` argument — vector or palette name string.
#' 2. `getOption("highdir.colors")` — set via [hd_set_theme()].
#' 3. Built-in hdir rules:
#'    * n == 2  → `"hdir2"` two-colour teal/purple pair
#'    * n <= 10 → `"hdir"` 10-colour brand palette
#'    * n > 10  → viridis continuous scale
#'
#' @param n      Integer. Number of colours required.
#' @param colors Character vector, palette name, or `NULL`.
#' @return Character vector of length `n`.
#' @keywords internal
resolve_colors <- function(n, colors = NULL) {
  # 1 — explicit or session-level override
  candidate <- colors %||% getOption("highdir.colors", default = NULL)
  if (!is.null(candidate)) {
    # accept palette name string
    if (is.character(candidate) && length(candidate) == 1 &&
        candidate %in% list_palettes()) {
      candidate <- get_palette(candidate)
    }
    if (length(candidate) >= n)
      return(candidate[seq_len(n)])
  }

  # 2 — built-in rules
  if (n == 2) {
    pal2 <- get_palette("hdir2")
    if (!is.null(pal2)) return(pal2)
  }
  hdir_pal <- get_palette("hdir")
  if (!is.null(hdir_pal) && n <= length(hdir_pal))
    return(hdir_pal[seq_len(n)])

  # 3 — viridis fallback
  viridis::viridis(n, option = "D")
}
