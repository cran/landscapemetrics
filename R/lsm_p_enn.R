#' ENN (patch level)
#'
#' @description Euclidean Nearest-Neighbor Distance (Aggregation metric)
#'
#' @param landscape Raster* Layer, Stack, Brick or a list of rasterLayers.
#' @param directions The number of directions in which patches should be
#' connected: 4 (rook's case) or 8 (queen's case).
#' @param verbose Print warning message if not sufficient patches are present
#'
#' @details
#' \deqn{ENN = h_{ij}}
#' where \eqn{h_{ij}} is the distance to the nearest neighbouring patch of
#' the same class i in meters
#'
#' ENN is an 'Aggregation metric'. The distance to the nearest neighbouring patch of
#' the same class i. The distance is measured from edge-to-edge. The range is limited by the
#' cell resolution on the lower limit and the landscape extent on the upper limit. The metric
#' is a simple way to describe patch isolation.
#'
#' \subsection{Units}{Meters}
#' \subsection{Range}{ENN > 0}
#' \subsection{Behaviour}{Approaches ENN = 0 as the distance to the nearest neighbour
#' decreases, i.e. patches of the same class i are more aggregated. Increases, without limit,
#' as the distance between neighbouring patches of the same class i increases, i.e. patches are
#' more isolated.}
#'
#' @seealso
#' \code{\link{lsm_c_enn_mn}},
#' \code{\link{lsm_c_enn_sd}},
#' \code{\link{lsm_c_enn_cv}}, \cr
#' \code{\link{lsm_l_enn_mn}},
#' \code{\link{lsm_l_enn_sd}},
#' \code{\link{lsm_l_enn_cv}}
#'
#' @return tibble
#'
#' @examples
#' lsm_p_enn(landscape)
#'
#' @aliases lsm_p_enn
#' @rdname lsm_p_enn
#'
#' @references
#' McGarigal, K., SA Cushman, and E Ene. 2012. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical and Continuous Maps. Computer software program produced by
#' the authors at the University of Massachusetts, Amherst. Available at the following
#' web site: http://www.umass.edu/landeco/research/fragstats/fragstats.html
#'
#' McGarigal, K., and McComb, W. C. (1995). Relationships between landscape
#' structure and breeding birds in the Oregon Coast Range.
#' Ecological monographs, 65(3), 235-260.
#'
#' @export
lsm_p_enn <- function(landscape, directions, verbose) UseMethod("lsm_p_enn")

#' @name lsm_p_enn
#' @export
lsm_p_enn.RasterLayer <- function(landscape, directions = 8, verbose = TRUE) {
    purrr::map_dfr(raster::as.list(landscape), lsm_p_enn_calc,
                   directions = directions,
                   verbose = verbose,
                   .id = "layer") %>%
        dplyr::mutate(layer = as.integer(layer))
}

#' @name lsm_p_enn
#' @export
lsm_p_enn.RasterStack <- function(landscape, directions = 8, verbose = TRUE) {
    purrr::map_dfr(raster::as.list(landscape), lsm_p_enn_calc,
                   directions = directions,
                   verbose = verbose,
                   .id = "layer") %>%
        dplyr::mutate(layer = as.integer(layer))

}

#' @name lsm_p_enn
#' @export
lsm_p_enn.RasterBrick <- function(landscape, directions = 8, verbose = TRUE) {
    purrr::map_dfr(raster::as.list(landscape), lsm_p_enn_calc,
                   directions = directions,
                   verbose = verbose,
                   .id = "layer") %>%
        dplyr::mutate(layer = as.integer(layer))

}

#' @name lsm_p_enn
#' @export
lsm_p_enn.list <- function(landscape, directions = 8, verbose = TRUE) {
    purrr::map_dfr(landscape, lsm_p_enn_calc,
                   directions = directions,
                   verbose = verbose,
                   .id = "layer") %>%
        dplyr::mutate(layer = as.integer(layer))

}

lsm_p_enn_calc <- function(landscape, directions, verbose) {

    landscape_labeled <- get_patches(landscape, directions = directions)

    enn_patch <- purrr::map_dfr(landscape_labeled, function(patches_class) {

        class_name <- patches_class %>%
            names() %>%
            sub("Class_", "", .)

        np_class <- patches_class %>%
            raster::values() %>%
            max(na.rm = TRUE)

        if(np_class == 1){
            enn <-  tibble::tibble(class = class_name,
                                   value = as.double(NA))

            if(isTRUE(verbose)){
                warning(paste0("Class ", class_name,
                               ": ENN = NA for class with only 1 patch"),
                        call. = FALSE)
            }
        }

        else{

            class_boundaries <- raster::boundaries(patches_class, directions = 4,
                                                   asNA = TRUE)

            raster::values(class_boundaries)[raster::values(!is.na(class_boundaries))] <- raster::values(patches_class)[raster::values(!is.na(class_boundaries))]

            points_class <- raster::rasterToPoints(class_boundaries)

            ord <- order(as.matrix(points_class)[, 1])
            num <- seq_along(ord)
            rank <- match(num, ord)

            res <- rcpp_get_nearest_neighbor(as.matrix(points_class)[ord,])

            min_dist <- unname(cbind(num, res[rank], as.matrix(points_class)[, 3]))

            tbl <- tibble::tibble(cell = min_dist[,1],
                          dist = min_dist[,2],
                          id = min_dist[,3])

            enn <- dplyr::group_by(tbl, by = id) %>%
                dplyr::summarise(value = min(dist))
        }

            tibble::tibble(class = class_name,
                           value = enn$value)


    })

    tibble::tibble(level = "patch",
                   class = as.integer(enn_patch$class),
                   id = as.integer(seq_len(nrow(enn_patch))),
                   metric = "enn",
                   value = as.double(enn_patch$value))
}