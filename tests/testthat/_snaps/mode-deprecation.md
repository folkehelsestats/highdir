# normalize_mode rejects invalid values

    Code
      normalize_mode("foobar")
    Condition
      Error in `normalize_mode()`:
      ! `mode` must be one of "dynamic" or "static", not "foobar".

