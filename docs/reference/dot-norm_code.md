# Convert any supported Norway region code to a zero-padded string

Accepts integers (301), numerics (301.0), or character ("0301",
"no-0301"). Strips any "no-XX-" or "no-" prefix and zero-pads to the
required width.

## Usage

``` r
.norm_code(codes, level = c("county", "municipality"))
```

## Arguments

- codes:

  Vector of region codes (integer, numeric, or character).

- level:

  `"county"` (width 2) or `"municipality"` (width 4).

## Value

Character vector of zero-padded codes, e.g. "0301", "03".
