#' CIRCLE_CV (landscape level)
#'
#' @description Coefficient of variation of related circumscribing circle (Shape metric)
#'
#' @param landscape A categorical raster object: SpatRaster; Raster* Layer, Stack, Brick; stars or a list of SpatRasters.
#' @param directions The number of directions in which patches should be connected: 4 (rook's case) or 8 (queen's case).
#'
#' @details
#' \deqn{CIRCLE_{CV} = cv(CIRCLE[patch_{ij}])}
#' where \eqn{CIRCLE[patch_{ij}]} is the related circumscribing circle of each patch.
#'
#' CIRCLE_CV is a 'Shape metric' and summarises the landscape as the Coefficient of variation
#' of the related circumscribing circle of all patches in the landscape. CIRCLE describes
#' the ratio between the patch area and the smallest circumscribing circle of the patch
#' and characterises the compactness of the patch. CIRCLE_CV describes the differences among
#' all patches in the landscape. Because it is scaled to the mean, it is easily comparable.
#'
#' Because the metric is based on distances or areas please make sure your data
#' is valid using \code{\link{check_landscape}}.
#'
#' \subsection{Units}{None}
#' \subsection{Range}{CIRCLE_CV >= 0}
#' \subsection{Behaviour}{Equals CIRCLE_CV if the related circumscribing circle is identical
#' for all patches. Increases, without limit, as the variation of related circumscribing
#' circles increases.}
#'
#' @seealso
#' \code{\link{lsm_p_circle}},
#' \code{\link[base]{mean}}, \cr
#' \code{\link{lsm_c_circle_mn}},
#' \code{\link{lsm_c_circle_sd}},
#' \code{\link{lsm_c_circle_cv}}, \cr
#' \code{\link{lsm_l_circle_mn}},
#' \code{\link{lsm_l_circle_sd}}
#'
#' @return tibble
#'
#' @examples
#' landscape <- terra::rast(landscapemetrics::landscape)
#' lsm_l_circle_cv(landscape)
#'
#' @references
#' McGarigal K., SA Cushman, and E Ene. 2023. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical Maps. Computer software program produced by the authors;
#' available at the following web site: https://www.fragstats.org
#'
#' Baker, W. L., and Y. Cai. 1992. The r.le programs for multiscale analysis of
#' landscape structure using the GRASS geographical information system.
#' Landscape Ecology 7: 291-302.
#'
#' Based on C++ code from Project Nayuki (https://www.nayuki.io/page/smallest-enclosing-circle).
#'
#' @export
lsm_l_circle_cv <- function(landscape, directions = 8) {
    landscape <- landscape_as_list(landscape)

    result <- lapply(X = landscape,
                     FUN = lsm_l_circle_cv_calc,
                     directions = directions)

    layer <- rep(seq_along(result),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

lsm_l_circle_cv_calc <- function(landscape, directions, resolution, extras = NULL) {

    circle_patch <- lsm_p_circle_calc(landscape,
                                      directions = directions,
                                      resolution = resolution,
                                      extras = extras)

    # all values NA
    if (all(is.na(circle_patch$value))) {
        return(tibble::new_tibble(list(level = "landscape",
                              class = as.integer(NA),
                              id = as.integer(NA),
                              metric = "circle_cv",
                              value = as.double(NA))))
    }

    circle_cv <- stats::sd(circle_patch$value) / mean(circle_patch$value) * 100

    return(tibble::new_tibble(list(level = rep("landscape", length(circle_cv)),
                 class = rep(as.integer(NA), length(circle_cv)),
                 id = rep(as.integer(NA), length(circle_cv)),
                 metric = rep("circle_cv", length(circle_cv)),
                 value = as.double(circle_cv))))
}

