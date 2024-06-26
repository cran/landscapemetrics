#' ENN_SD (landscape level)
#'
#' @description Standard deviation of euclidean nearest-neighbor distance (Aggregation metric)
#'
#' @param landscape A categorical raster object: SpatRaster; Raster* Layer, Stack, Brick; stars or a list of SpatRasters.
#' @param directions The number of directions in which patches should be connected: 4 (rook's case) or 8 (queen's case).
#' @param verbose Print warning message if not sufficient patches are present
#'
#' @details
#' \deqn{ENN_{SD} = sd(ENN[patch_{ij}])}
#' where \eqn{ENN[patch_{ij}]} is the euclidean nearest-neighbor distance
#' of each patch.
#'
#' ENN_CV is an 'Aggregation metric'. It summarises in the landscape as the standard
#' deviation of all patches in the landscape. ENN measures the distance to the  nearest
#' neighbouring patch of the same class i. The distance is measured from edge-to-edge.
#' The range is limited by the cell resolution on the lower limit and the landscape extent
#' on the upper limit. The metric is a simple way to describe patch isolation. Because it is
#' scaled to the mean, it is easily comparable among different landscapes.
#'
#' Because the metric is based on distances or areas please make sure your data
#' is valid using \code{\link{check_landscape}}.
#'
#' \subsection{Units}{Meters}
#' \subsection{Range}{ENN_SD >= 0}
#' \subsection{Behaviour}{Equals ENN_SD = 0 if the euclidean nearest-neighbor distance is
#' identical for all patches. Increases, without limit, as the variation of ENN increases.}
#'
#' @seealso
#' \code{\link{lsm_p_enn}},
#' \code{\link[stats]{sd}} \cr
#' \code{\link{lsm_c_enn_mn}},
#' \code{\link{lsm_c_enn_sd}},
#' \code{\link{lsm_c_enn_cv}}, \cr
#' \code{\link{lsm_l_enn_mn}},
#' \code{\link{lsm_l_enn_cv}}
#'
#' @return tibble
#'
#' @examples
#' landscape <- terra::rast(landscapemetrics::landscape)
#' lsm_l_enn_sd(landscape)
#'
#' @references
#' McGarigal K., SA Cushman, and E Ene. 2023. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical Maps. Computer software program produced by the authors;
#' available at the following web site: https://www.fragstats.org
#'
#' McGarigal, K., and McComb, W. C. (1995). Relationships between landscape
#' structure and breeding birds in the Oregon Coast Range.
#' Ecological monographs, 65(3), 235-260.
#'
#' @export
lsm_l_enn_sd <- function(landscape, directions = 8, verbose = TRUE) {
    landscape <- landscape_as_list(landscape)

    result <- lapply(X = landscape,
                     FUN = lsm_l_enn_sd_calc,
                     directions = directions,
                     verbose = verbose)

    layer <- rep(seq_along(result),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

lsm_l_enn_sd_calc <- function(landscape, directions, verbose, resolution, extras = NULL) {

    enn_patch <- lsm_p_enn_calc(landscape,
                                directions = directions, verbose = verbose,
                                resolution = resolution, extras = extras)

    # all values NA
    if (all(is.na(enn_patch$value))) {
        return(tibble::new_tibble(list(level = "landscape",
                              class = as.integer(NA),
                              id = as.integer(NA),
                              metric = "enn_sd",
                              value = as.double(NA))))
    }

    enn_sd <- stats::sd(enn_patch$value)

    return(tibble::new_tibble(list(level = rep("landscape", length(enn_sd)),
                 class = rep(as.integer(NA), length(enn_sd)),
                 id = rep(as.integer(NA), length(enn_sd)),
                 metric = rep("enn_sd", length(enn_sd)),
                 value = as.double(enn_sd))))
}
