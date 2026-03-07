# tests/testthat/helper-layers.R

#' Find layer indices by geom class name
#' @param fig  A ggplot object
#' @param geom_class  Character. e.g. "GeomCol", "GeomLine", "GeomPoint"
#' @return Integer vector of matching layer indices
.find_layers <- function(fig, geom_class) {
  which(vapply(fig$layers, function(l) inherits(l$geom, geom_class),
               logical(1)))
}

#' Get fixed aesthetic value from a specific layer
.layer_aes <- function(fig, geom_class, aes_name) {
  idx <- .find_layers(fig, geom_class)
  if (!length(idx)) return(NULL)
  fig$layers[[idx[1]]]$aes_params[[aes_name]]
}
