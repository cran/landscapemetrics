#' TE (landscape level)
#'
#' @description Total edge (Area and Edge metric)
#'
#' @param landscape A categorical raster object: SpatRaster; Raster* Layer, Stack, Brick; stars or a list of SpatRasters.
#' @param count_boundary Include landscape boundary in edge length
#'
#' @details
#' \deqn{TE = \sum \limits_{k = 1}^{m} e_{ik}}
#' where \eqn{e_{ik}} is the edge lengths in meters.

#' TE is an 'Area and edge metric'. Total edge includes all edges. It measures the
#' configuration of the landscape because a highly fragmented landscape will have many
#' edges. However, total edge is an absolute measure, making comparisons among landscapes
#' with different total areas difficult. If \code{count_boundary = TRUE} also edges to the
#' landscape boundary are included.
#'
#' Because the metric is based on distances or areas please make sure your data
#' is valid using \code{\link{check_landscape}}.
#'
#' \subsection{Units}{Meters}
#' \subsection{Range}{TE >= 0}
#' \subsection{Behaviour}{Equals TE = 0 if all cells are edge cells. Increases, without limit,
#' as landscape becomes more fragmented}
#'
#' @seealso
#' \code{\link{lsm_p_perim}}
#' \code{\link{lsm_l_te}}
#'
#' @return tibble
#'
#' @examples
#' landscape <- terra::rast(landscapemetrics::landscape)
#' lsm_l_te(landscape)
#'
#' @references
#' McGarigal K., SA Cushman, and E Ene. 2023. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical Maps. Computer software program produced by the authors;
#' available at the following web site: https://www.fragstats.org
#'
#' @export
lsm_l_te <- function(landscape, count_boundary = FALSE) {
    landscape <- landscape_as_list(landscape)

    result <- lapply(X = landscape,
                     FUN = lsm_l_te_calc,
                     count_boundary = count_boundary)

    layer <- rep(seq_along(result),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

lsm_l_te_calc <- function(landscape, count_boundary, resolution, extras = NULL){

    if (missing(resolution)) resolution <- terra::res(landscape)

    if (is.null(extras)){
        metrics <- "lsm_l_te"
        landscape <- terra::as.matrix(landscape, wide = TRUE)
        extras <- prepare_extras(metrics, landscape_mat = landscape,
                                            neighbourhood = 4, resolution = resolution)
    }

    # all values NA
    if (all(is.na(landscape))) {
        return(tibble::new_tibble(list(level = "landscape",
                              class = as.integer(NA),
                              id = as.integer(NA),
                              metric = "te",
                              value = as.double(NA))))
    }

    # get resolution in x-y directions
    resolution_x <- resolution[[1]]
    resolution_y <- resolution[[2]]

    if (count_boundary) {

        # get background value not present as class
        background_value <- max(landscape, na.rm = TRUE) + 1

        # add row/col around raster
        landscape <- pad_raster_internal(landscape = landscape,
                                         pad_raster_value = background_value,
                                         pad_raster_cells = 1, global = FALSE)

        # set NA to background value
        landscape[is.na(landscape)] <- background_value

        neighbor_matrix <- rcpp_get_coocurrence_matrix(landscape, directions = as.matrix(4))

    } else {

        neighbor_matrix <- extras$neighbor_matrix

    }

    if (resolution_x == resolution_y) {

        edge_total <- sum(neighbor_matrix[lower.tri(neighbor_matrix)]) * resolution_x

    } else {

        top_bottom_matrix <- matrix(c(NA, NA, NA,
                                      1,  0, 1,
                                      NA, NA, NA), 3, 3, byrow = TRUE)

        left_right_matrix <- matrix(c(NA, 1, NA,
                                      NA, 0, NA,
                                      NA, 1, NA), 3, 3, byrow = TRUE)

        left_right_neighbours <-
            rcpp_get_coocurrence_matrix(landscape,
                                        directions = as.matrix(left_right_matrix))

        edge_left_right <-
            sum(left_right_neighbours[lower.tri(left_right_neighbours)]) * resolution_x

        top_bottom_neighbours <-
            rcpp_get_coocurrence_matrix(terra::as.matrix(landscape, wide = TRUE),
                                        directions = as.matrix(top_bottom_matrix))

        edge_top_bottom <-
            sum(top_bottom_neighbours[lower.tri(top_bottom_neighbours)]) * resolution_y

        edge_total <- edge_left_right + edge_top_bottom
    }

    return(tibble::new_tibble(list(level = rep("landscape", length(edge_total)),
                          class = rep(as.integer(NA), length(edge_total)),
                          id = rep(as.integer(NA), length(edge_total)),
                          metric = rep("te", length(edge_total)),
                          value = as.double(edge_total))))
}
