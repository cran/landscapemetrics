#' COHESION (class level)
#'
#' @description Patch Cohesion Index (Aggregation metric)
#'
#' @param landscape A categorical raster object: SpatRaster; Raster* Layer, Stack, Brick; stars or a list of SpatRasters.
#' @param directions The number of directions in which patches should be
#' connected: 4 (rook's case) or 8 (queen's case).
#'
#' @details
#' \deqn{COHESION = 1 - (\frac{\sum \limits_{j = 1}^{n} p_{ij}} {\sum \limits_{j = 1}^{n} p_{ij} \sqrt{a_{ij}}}) * (1 - \frac{1} {\sqrt{Z}}) ^ {-1} * 100}
#' where \eqn{p_{ij}} is the perimeter in meters, \eqn{a_{ij}} is the area in square
#' meters and \eqn{Z} is the number of cells.
#'
#' COHESION is an 'Aggregation metric'. It characterises the connectedness of patches
#' belonging to class i. It can be used to asses if patches of the same class are located
#' aggregated or rather isolated and thereby COHESION gives information about the
#' configuration of the landscape.
#'
#' Because the metric is based on distances or areas please make sure your data
#' is valid using \code{\link{check_landscape}}.
#'
#' \subsection{Units}{Percent}
#' \subsection{Ranges}{0 < COHESION < 100}
#' \subsection{Behaviour}{Approaches COHESION = 0 if patches of class i become more isolated.
#' Increases if patches of class i become more aggregated.}
#'
#' @seealso
#' \code{\link{lsm_p_perim}},
#' \code{\link{lsm_p_area}}, \cr
#' \code{\link{lsm_l_cohesion}}
#'
#' @return tibble
#'
#' @examples
#' landscape <- terra::rast(landscapemetrics::landscape)
#' lsm_c_cohesion(landscape)
#'
#' @references
#' McGarigal K., SA Cushman, and E Ene. 2023. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical Maps. Computer software program produced by the authors;
#' available at the following web site: https://www.fragstats.org
#'
#' Schumaker, N. H. 1996. Using landscape indices to predict habitat
#' connectivity. Ecology, 77(4), 1210-1225.
#'
#' @export
lsm_c_cohesion <- function(landscape, directions = 8) {
    landscape <- landscape_as_list(landscape)

    result <- lapply(X = landscape,
                     FUN = lsm_c_cohesion_calc,
                     directions = directions)

    layer <- rep(seq_along(result),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

lsm_c_cohesion_calc <- function(landscape, directions, resolution, extras = NULL) {

    if (missing(resolution)) resolution <- terra::res(landscape)

    if (is.null(extras)){
        metrics <- "lsm_c_cohesion"
        landscape <- terra::as.matrix(landscape, wide = TRUE)
        extras <- prepare_extras(metrics, landscape_mat = landscape,
                                            directions = directions, resolution = resolution)
    }

    # all values NA
    if (all(is.na(landscape))) {
        return(tibble::new_tibble(list(level = "class",
                              class = as.integer(NA),
                              id = as.integer(NA),
                              metric = "cohesion",
                              value = as.double(NA))))
    }

    # get number of cells (only not NAs)
    ncells_landscape <- length(landscape[!is.na(landscape)])

    # get patch area
    patch_area <- lsm_p_area_calc(landscape,
                                  directions = directions,
                                  resolution = resolution,
                                  extras = extras)

    # get number of cells for each patch -> area = n_cells * res / 10000
    patch_area$ncells <- patch_area$value * 10000 / prod(resolution)

    # get perim of patch
    perim_patch <- lsm_p_perim_calc(landscape,
                                    directions = directions,
                                    resolution = resolution,
                                    extras = extras)

    # calculate denominator of cohesion
    perim_patch$denominator <- perim_patch$value * sqrt(patch_area$ncells)

    # group by class and sum
    denominator <- stats::aggregate(x = perim_patch[, 6], by = perim_patch[, 2],
                                    FUN = sum)

    cohesion <- stats::aggregate(x = perim_patch[, 5], by = perim_patch[, 2],
                                 FUN = sum)

    # calculate cohesion
    cohesion$value <- (1 - (cohesion$value / denominator$denominator)) *
        ((1 - (1 / sqrt(ncells_landscape))) ^ -1) * 100

    return(tibble::new_tibble(list(
        level = rep("class", nrow(cohesion)),
        class = as.integer(cohesion$class),
        id = rep(as.integer(NA), nrow(cohesion)),
        metric = rep("cohesion", nrow(cohesion)),
        value = as.double(cohesion$value)
    )))
}
