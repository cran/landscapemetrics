#' CA (class level)
#'
#' @description Total (class) area (Area and edge metric)
#'
#' @param landscape A categorical raster object: SpatRaster; Raster* Layer, Stack, Brick; stars or a list of SpatRasters.
#' @param directions The number of directions in which patches should be
#' connected: 4 (rook's case) or 8 (queen's case).
#'
#' @details
#' \deqn{CA = sum(AREA[patch_{ij}])}
#' where \eqn{AREA[patch_{ij}]} is the area of each patch in hectares.
#'
#' CA is an 'Area and edge metric' and a measure of composition.
#' The total (class) area sums the area of all patches belonging to class i.
#' It shows if the landscape is e.g. dominated by one class or if all classes
#' are equally present. CA is an absolute measure, making comparisons among
#' landscapes with different total areas difficult.
#'
#' Because the metric is based on distances or areas please make sure your data
#' is valid using \code{\link{check_landscape}}.
#'
#' \subsection{Units}{Hectares}
#' \subsection{Range}{CA > 0}
#' \subsection{Behaviour}{Approaches CA > 0 as the patch areas of class i
#' become small. Increases, without limit, as the patch areas of class i become
#' large. CA = TA if only one class is present.}
#'
#' @seealso
#' \code{\link{lsm_p_area}},
#' \code{\link{sum}}, \cr
#' \code{\link{lsm_l_ta}}
#'
#' @return tibble
#'
#' @examples
#' landscape <- terra::rast(landscapemetrics::landscape)
#' lsm_c_ca(landscape)
#'
#' @references
#' McGarigal K., SA Cushman, and E Ene. 2023. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical Maps. Computer software program produced by the authors;
#' available at the following web site: https://www.fragstats.org
#'
#' @export
lsm_c_ca <- function(landscape, directions = 8) {
    landscape <- landscape_as_list(landscape)

    result <- lapply(X = landscape,
                     FUN = lsm_c_ca_calc,
                     directions = directions)

    layer <- rep(seq_along(result),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

lsm_c_ca_calc <- function(landscape, directions, resolution, extras = NULL) {

    # calculate core area for each patch
    core_patch <- lsm_p_area_calc(landscape,
                                  directions = directions,
                                  resolution = resolution,
                                  extras = extras)

    # all values NA
    if (all(is.na(core_patch$value))) {
        return(tibble::new_tibble(list(level = "class",
                              class = as.integer(NA),
                              id = as.integer(NA),
                              metric = "ca",
                              value = as.double(NA))))
    }

    # summarise for each class
    ca <- stats::aggregate(x = core_patch[, 5], by = core_patch[, 2], FUN = sum)

    return(tibble::new_tibble(list(level = rep("class", nrow(ca)),
                          class = as.integer(ca$class),
                          id = rep(as.integer(NA), nrow(ca)),
                          metric = rep("ca", nrow(ca)),
                          value = as.double(ca$value))))
}
