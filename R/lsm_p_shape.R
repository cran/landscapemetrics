#' SHAPE (patch level)
#'
#' @description Shape index (Shape metric)
#'
#' @param landscape A categorical raster object: SpatRaster; Raster* Layer, Stack, Brick; stars or a list of SpatRasters.
#' @param directions The number of directions in which patches should be
#' connected: 4 (rook's case) or 8 (queen's case).
#'
#' @details
#' \deqn{SHAPE = \frac{0.25 * p_{ij}} {\sqrt a_{ij}}}
#' where \eqn{p_{ij}} is the perimeter (m) and \eqn{a_{ij}} is the area (m2).
#'
#' SHAPE is a 'Shape metric'. It describes the ratio between the actual perimeter of
#' the patch and the square root of patch area and thus adjusting for a square standard.
#' Thus, it is a simple measure of shape complexity.
#'
#' Because the metric is based on distances or areas please make sure your data
#' is valid using \code{\link{check_landscape}}.
#'
#' \subsection{Units}{None}
#' \subsection{Range}{SHAPE >= 1}
#' \subsection{Behaviour}{Equals SHAPE = 1 for a squared patch and
#' increases, without limit, as the patch shape becomes more complex.}
#'
#' @seealso
#' \code{\link{lsm_p_perim}},
#' \code{\link{lsm_p_area}}, \cr
#' \code{\link{lsm_c_shape_mn}},
#' \code{\link{lsm_c_shape_sd}},
#' \code{\link{lsm_c_shape_cv}}, \cr
#' \code{\link{lsm_l_shape_mn}},
#' \code{\link{lsm_l_shape_sd}},
#' \code{\link{lsm_l_shape_cv}}
#'
#' @return tibble
#'
#' @examples
#' landscape <- terra::rast(landscapemetrics::landscape)
#' lsm_p_shape(landscape)
#'
#' @references
#' McGarigal K., SA Cushman, and E Ene. 2023. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical Maps. Computer software program produced by the authors;
#' available at the following web site: https://www.fragstats.org
#'
#' Patton, D. R. 1975. A diversity index for quantifying habitat "edge".
#' Wildl. Soc.Bull. 3:171-173.
#'
#' @export
lsm_p_shape <- function(landscape, directions = 8) {
    landscape <- landscape_as_list(landscape)

    result <- lapply(X = landscape,
                     FUN = lsm_p_shape_calc,
                     directions = directions)

    layer <- rep(seq_along(result),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

lsm_p_shape_calc <- function(landscape, directions, resolution, extras = NULL){

    if (missing(resolution)) resolution <- terra::res(landscape)

    if (is.null(extras)) {
        metrics <- "lsm_p_shape"
        landscape <- terra::as.matrix(landscape, wide = TRUE)
        extras <- prepare_extras(metrics, landscape_mat = landscape,
                                 directions = directions, resolution = resolution)
    }

    # all values NA
    if (all(is.na(landscape))) {
        return(tibble::new_tibble(list(level = "patch",
                              class = as.integer(NA),
                              id = as.integer(NA),
                              metric = "shape",
                              value = as.double(NA))))
    }

    # get perimeter of patches
    perimeter_patch <- lsm_p_perim_calc(landscape,
                                        directions = directions,
                                        resolution = resolution,
                                        extras = extras)

    # get area of patches
    area_patch <- lsm_p_area_calc(landscape,
                                  directions = directions,
                                  resolution = resolution,
                                  extras = extras)

    # calculate shape index
    shape_patch <- (0.25 * perimeter_patch$value) / sqrt(area_patch$value * 10000)

    tibble::new_tibble(list(
        level = rep("patch", nrow(perimeter_patch)),
        class = as.integer(perimeter_patch$class),
        id = as.integer(perimeter_patch$id),
        metric = "shape",
        value = as.double(shape_patch)
    ))
}
