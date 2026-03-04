# Norway Municipality Reference Table

Returns a data frame of Norwegian municipalities (kommuner) with SSB
`kommunenummer`, names, Highcharts `hc_key` values for the
`"countries/no/no-all-all"` topology, and parent `fylkesnummer`.

## Usage

``` r
no_municipalities()
```

## Value

A `data.frame` with columns:

- kommunenummer:

  Character. 4-digit SSB code, e.g. `"0301"`.

- name:

  Character. Municipality name.

- hc_key:

  Character. Highcharts join key, e.g. `"no-03-0301"`.

- fylkesnummer:

  Character. Parent county 2-digit code.

## Examples

``` r
head(no_municipalities())
#>   kommunenummer         name     hc_key fylkesnummer
#> 1          0301         Oslo no-03-0301           03
#> 2          1103    Stavanger no-11-1103           11
#> 3          1106    Haugesund no-11-1106           11
#> 4          1108      Sandnes no-11-1108           11
#> 5          1149       Karmøy no-11-1149           11
#> 6          1505 Kristiansund no-15-1505           15
subset(no_municipalities(), fylkesnummer == "46")  # Vestland
#>    kommunenummer     name     hc_key fylkesnummer
#> 26          4601   Bergen no-46-4601           46
#> 27          4615 Øygarden no-46-4615           46
#> 28          4616    Askøy no-46-4616           46
```
