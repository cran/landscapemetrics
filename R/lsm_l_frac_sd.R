#' FRAC_SD (landscape level)
#'
#' @description Standard deviation fractal dimension index (Shape metric)
#'
#' @param landscape A categorical raster object: SpatRaster; Raster* Layer, Stack, Brick; stars or a list of SpatRasters.
#' @param directions The number of directions in which patches should be
#' connected: 4 (rook's case) or 8 (queen's case).
#'
#' @details
#' \deqn{FRAC_{SD} = sd(FRAC[patch_{ij}])}
#' where \eqn{FRAC[patch_{ij}]} equals the fractal dimension index of each patch.
#'
#' FRAC_SD is a 'Shape metric'. The metric summarises the landscape
#' as the standard deviation of the fractal dimension index of all patches
#' in the landscape. The fractal dimension index is based on the patch perimeter and
#' the patch area and describes the patch complexity.
#'
#' Because the metric is based on distances or areas please make sure your data
#' is valid using \code{\link{check_landscape}}.
#'
#' \subsection{Units}{None}
#' \subsection{Range}{FRAC_SD>= 0 }
#' \subsection{Behaviour}{Equals FRAC_SD = 0 if the fractal dimension index is identical
#' for all patches. Increases, without limit, as the variation of the fractal dimension
#' indices increases.}
#'
#' @seealso
#' \code{\link{lsm_p_frac}},
#' \code{\link[stats]{sd}} \cr
#' \code{\link{lsm_c_frac_mn}},
#' \code{\link{lsm_c_frac_sd}},
#' \code{\link{lsm_c_frac_cv}}, \cr
#' \code{\link{lsm_l_frac_mn}},
#' \code{\link{lsm_l_frac_cv}}
#'
#' @return tibble
#'
#' @examples
#' landscape <- terra::rast(landscapemetrics::landscape)
#' lsm_l_frac_sd(landscape)
#'
#' @references
#' McGarigal K., SA Cushman, and E Ene. 2023. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical Maps. Computer software program produced by the authors;
#' available at the following web site: https://www.fragstats.org
#'
#' Mandelbrot, B. B. 1977. Fractals: Form, Chance, and Dimension.
#' San Francisco. W. H. Freeman and Company.
#'
#' @export
lsm_l_frac_sd <- function(landscape, directions = 8) {
    landscape <- landscape_as_list(landscape)

    result <- lapply(X = landscape,
                     FUN = lsm_l_frac_sd_calc,
                     directions = directions)

    layer <- rep(seq_along(result),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

lsm_l_frac_sd_calc <- function(landscape, directions, resolution, extras = NULL){

    frac_patch <- lsm_p_frac_calc(landscape,
                                  directions = directions,
                                  resolution = resolution,
                                  extras = extras)

    # all values NA
    if (all(is.na(frac_patch$value))) {
        return(tibble::new_tibble(list(level = "landscape",
                              class = as.integer(NA),
                              id = as.integer(NA),
                              metric = "frac_sd",
                              value = as.double(NA))))
    }

    frac_sd <- stats::sd(frac_patch$value)

    return(tibble::new_tibble(list(level = rep("landscape", length(frac_sd)),
                 class = rep(as.integer(NA), length(frac_sd)),
                 id = rep(as.integer(NA), length(frac_sd)),
                 metric = rep("frac_sd", length(frac_sd)),
                 value = as.double(frac_sd))))
}
