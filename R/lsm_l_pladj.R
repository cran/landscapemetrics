#' PLADJ (landscape level)
#'
#' @description Percentage of Like Adjacencies (Aggregation metric)
#'
#' @param landscape A categorical raster object: SpatRaster; Raster* Layer, Stack, Brick; stars or a list of SpatRasters.
#'
#' @details
#' \deqn{PLADJ = (\frac{g_{ij}} {\sum \limits_{k = 1}^{m} g_{ik}}) * 100}
#' where \eqn{g_{ii}} is the number of adjacencies between cells of class i
#' and \eqn{g_{ik}} is the number of adjacencies between cells of class i and k.
#'
#' PLADJ is an 'Aggregation metric'. It calculates the frequency how often patches of
#' different classes i (focal class) and k are next to each other, and following is a
#' measure of class aggregation. The adjacencies are counted using the double-count method.
#'
#' \subsection{Units}{Percent}
#' \subsection{Ranges}{0 <= PLADJ <= 100}
#' \subsection{Behaviour}{Equals PLADJ = 0 if class i is maximal disaggregated,
#' i.e. every cell is a different patch. Equals PLADJ = 100 when the only one patch
#' is present.}
#'
#' @return tibble
#'
#' @examples
#' landscape <- terra::rast(landscapemetrics::landscape)
#' lsm_l_pladj(landscape)
#'
#' @references
#' McGarigal K., SA Cushman, and E Ene. 2023. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical Maps. Computer software program produced by the authors;
#' available at the following web site: https://www.fragstats.org.
#'
#' @export
lsm_l_pladj <- function(landscape) {
    landscape <- landscape_as_list(landscape)

    result <- lapply(X = landscape,
                     FUN = lsm_l_pladj_calc)

    layer <- rep(seq_along(result),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

lsm_l_pladj_calc <- function(landscape) {

    if (!inherits(x = landscape, what = "matrix")) {
        landscape <- terra::as.matrix(landscape, wide = TRUE)
    }

    # all values NA
    if (all(is.na(landscape))) {
        return(tibble::new_tibble(list(level = "landscape",
                              class = as.integer(NA),
                              id = as.integer(NA),
                              metric = "pladj",
                              value = as.double(NA))))
    }

    landscape_padded <- pad_raster_internal(landscape,
                                            pad_raster_value = -999,
                                            pad_raster_cells = 1,
                                            global = FALSE)

    tb <- rcpp_get_coocurrence_matrix(landscape_padded, directions = as.matrix(4))

    like_adjacencies <- sum(diag(tb)[-1])
    total_adjacencies <- sum(tb[,-1])

    pladj <- like_adjacencies / total_adjacencies * 100

    return(tibble::new_tibble(list(level = rep("landscape", length(pladj)),
                          class = rep(as.integer(NA), length(pladj)),
                          id = rep(as.integer(NA), length(pladj)),
                          metric = rep("pladj", length(pladj)),
                          value = as.double(pladj))))
}
