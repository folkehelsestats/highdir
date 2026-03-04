# Norway County Reference Table

Returns a data frame of the 15 Norwegian counties (fylker) with official
SSB `fylkesnummer`, Norwegian names, and the Highcharts `hc_key` values
used to join data to the `"countries/no/no-all"` map topology.

## Usage

``` r
no_counties()
```

## Value

A `data.frame` with columns:

- fylkesnummer:

  Character. 2-digit SSB code, e.g. `"03"`.

- name:

  Character. Norwegian county name.

- hc_key:

  Character. Highcharts join key, e.g. `"no-03"`.

## Details

Use this to prepare your data for
`hd_make(..., type = "map", level = "county")`:

    library(dplyr)
    my_data %>%
      left_join(no_counties(), by = "fylkesnummer") %>%
      hd_spec(x = "fylkesnummer", y = "rate") %>%
      hd_make("map", level = "county")

## Examples

``` r
no_counties()
#>    fylkesnummer                 name hc_key
#> 1            03                 Oslo  no-03
#> 2            11             Rogaland  no-11
#> 3            15      Møre og Romsdal  no-15
#> 4            18             Nordland  no-18
#> 5            30                Viken  no-30
#> 6            34            Innlandet  no-34
#> 7            38 Vestfold og Telemark  no-38
#> 8            42                Agder  no-42
#> 9            46             Vestland  no-46
#> 10           50            Trøndelag  no-50
#> 11           54    Troms og Finnmark  no-54
#> 12           55            Jan Mayen  no-55
#> 13           56             Svalbard  no-56
#> 14           57            Bouvetøya  no-57
#> 15           58         Peter I’s øy  no-58
```
