#' CAI_SD (landscape level)
#'
#' @description Standard deviation of core area index (Core area metric)
#'
#' @param landscape A categorical raster object: SpatRaster; Raster* Layer, Stack, Brick; stars or a list of SpatRasters.
#' @param directions The number of directions in which patches should be
#' connected: 4 (rook's case) or 8 (queen's case).
#' @param consider_boundary Logical if cells that only neighbour the landscape
#' boundary should be considered as core
#' @param edge_depth Distance (in cells) a cell has the be away from the patch
#' edge to be considered as core cell
#'
#' @details
#' \deqn{CAI_{SD} = sd(CAI[patch_{ij}]}
#' where \eqn{CAI[patch_{ij}]} is the core area index of each patch.
#'
#' CAI_SD is a 'Core area metric'. The metric summarises the landscape
#' as the standard deviation of the core area index of all patches in the landscape.
#' The core area index is the percentage of core area in relation to patch area.
#' A cell is defined as core area if the cell has no neighbour with a different
#' value than itself (rook's case). The metric describes the differences among all patches
#' in the landscape.
#'
#' Because the metric is based on distances or areas please make sure your data
#' is valid using \code{\link{check_landscape}}.
#'
#' \subsection{Units}{Percent}
#' \subsection{Range}{CAI_SD >= 0}
#' \subsection{Behaviour}{Equals CAI_SD = 0 if the core area index is identical for
#' all patches. Increases, without limit, as the variation of core area
#' indices increases.}
#'
#' @seealso
#' \code{\link{lsm_p_cai}},
#' \code{\link[stats]{sd}} \cr
#' \code{\link{lsm_c_cai_mn}},
#' \code{\link{lsm_c_cai_sd}},
#' \code{\link{lsm_c_cai_cv}}, \cr
#' \code{\link{lsm_l_cai_mn}},
#' \code{\link{lsm_l_cai_cv}}
#'
#' @return tibble
#'
#' @examples
#' landscape <- terra::rast(landscapemetrics::landscape)
#' lsm_l_cai_sd(landscape)
#'
#' @references
#' McGarigal K., SA Cushman, and E Ene. 2023. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical Maps. Computer software program produced by the authors;
#' available at the following web site: https://www.fragstats.org
#'
#' @export
lsm_l_cai_sd <- function(landscape,
                              directions = 8,
                              consider_boundary = FALSE,
                              edge_depth = 1) {
    landscape <- landscape_as_list(landscape)

    result <- lapply(X = landscape,
                     FUN = lsm_l_cai_sd_calc,
                     directions = directions,
                     consider_boundary = consider_boundary,
                     edge_depth = edge_depth)

    layer <- rep(seq_along(result),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

lsm_l_cai_sd_calc <- function(landscape, directions, consider_boundary, edge_depth, resolution, extras = NULL){

    cai_patch <- lsm_p_cai_calc(landscape,
                                directions = directions,
                                consider_boundary = consider_boundary,
                                edge_depth = edge_depth,
                                resolution = resolution,
                                extras = extras)

    # all values NA
    if (all(is.na(cai_patch$value))) {
        return(tibble::new_tibble(list(level = "landscape",
                              class = as.integer(NA),
                              id = as.integer(NA),
                              metric = "cai_sd",
                              value = as.double(NA))))
    }

    cai_sd <- stats::sd(cai_patch$value)

    return(tibble::new_tibble(list(level = rep("landscape", length(cai_sd)),
                 class = rep(as.integer(NA), length(cai_sd)),
                 id = rep(as.integer(NA), length(cai_sd)),
                 metric = rep("cai_sd", length(cai_sd)),
                 value = as.double(cai_sd))))
}
