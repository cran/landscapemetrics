#' CONTIG_CV (landscape level)
#'
#' @description Coefficient of variation of Contiguity index (Shape metric)
#'
#' @param landscape A categorical raster object: SpatRaster; Raster* Layer, Stack, Brick; stars or a list of SpatRasters.
#' @param directions The number of directions in which patches should be connected: 4 (rook's case) or 8 (queen's case).
#'
#' @details
#' \deqn{CONTIG_{CV} =  cv(CONTIG[patch_{ij}])}
#'
#' where \eqn{CONTIG[patch_{ij}]} is the contiguity of each patch.
#'
#' CONTIG_CV is a 'Shape metric'. It summarises the landscape as the coefficient of variation of all patches
#' in the landscape. CONTIG_CV asses the spatial connectedness (contiguity) of
#' cells in patches. The metric coerces patch values to a value of 1 and the background
#' to NA. A nine cell focal filter matrix:
#'
#' ```
#' filter_matrix <- matrix(c(1, 2, 1,
#'                           2, 1, 2,
#'                           1, 2, 1), 3, 3, byrow = T)
#' ```
#' ... is then used to weight orthogonally contiguous pixels more heavily than
#' diagonally contiguous pixels. Therefore, larger and more connections between
#' patch cells in the rookie case result in larger contiguity index values.
#'
#' \subsection{Units}{None}
#' \subsection{Range}{CONTIG_CV >= 0}
#' \subsection{Behaviour}{CONTIG_CV = 0 if the contiguity index is
#' identical for all patches. Increases, without limit, as the variation of
#' CONTIG increases.}
#'
#' @seealso
#' \code{\link{lsm_p_contig}},
#' \code{\link{lsm_c_contig_sd}},
#' \code{\link{lsm_c_contig_cv}},
#' \code{\link{lsm_c_contig_mn}}, \cr
#' \code{\link{lsm_l_contig_sd}},
#' \code{\link{lsm_l_contig_mn}}
#'
#' @return tibble
#'
#' @examples
#' landscape <- terra::rast(landscapemetrics::landscape)
#' lsm_l_contig_cv(landscape)
#'
#' @references
#' McGarigal K., SA Cushman, and E Ene. 2023. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical Maps. Computer software program produced by the authors;
#' available at the following web site: https://www.fragstats.org
#'
#' LaGro, J. 1991. Assessing patch shape in landscape mosaics.
#' Photogrammetric Engineering and Remote Sensing, 57(3), 285-293
#'
#' @export
lsm_l_contig_cv <- function(landscape, directions = 8) {
    landscape <- landscape_as_list(landscape)

    result <- lapply(X = landscape,
                     FUN = lsm_l_contig_cv_calc,
                     directions = directions)

    layer <- rep(seq_along(result),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

lsm_l_contig_cv_calc <- function(landscape, directions, extras = NULL) {

    contig_patch <- lsm_p_contig_calc(landscape,
                                      directions = directions,
                                      extras = extras)

    # all values NA
    if (all(is.na(contig_patch$value))) {
        return(tibble::new_tibble(list(level = "landscape",
                              class = as.integer(NA),
                              id = as.integer(NA),
                              metric = "contig_cv",
                              value = as.double(NA))))
    }

    contig_cv <- stats::sd(contig_patch$value) / mean(contig_patch$value) * 100

    return(tibble::new_tibble(list(level = rep("landscape", length(contig_cv)),
                 class = rep(as.integer(NA), length(contig_cv)),
                 id = rep(as.integer(NA), length(contig_cv)),
                 metric = rep("contig_cv", length(contig_cv)),
                 value = as.double(contig_cv))))
}
