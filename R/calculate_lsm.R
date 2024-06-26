#' calculate_lsm
#'
#' @description Calculate a selected group of metrics
#'
#' @param landscape A categorical raster object: SpatRaster; Raster* Layer, Stack, Brick; stars or a list of SpatRasters.
#' @param level Level of metrics. Either 'patch', 'class' or 'landscape' (or vector with combination).
#' @param metric Abbreviation of metrics (e.g. 'area').
#' @param name Full name of metrics (e.g. 'core area').
#' @param type Type according to FRAGSTATS grouping (e.g. 'aggregation metrics').
#' @param what Selected level of metrics: either "patch", "class" or "landscape".
#' It is also possible to specify functions as a vector of strings, e.g. `what = c("lsm_c_ca", "lsm_l_ta")`.
#' @param directions The number of directions in which patches should be
#' connected: 4 (rook's case) or 8 (queen's case).
#' @param count_boundary Include landscape boundary in edge length.
#' @param consider_boundary Logical if cells that only neighbour the landscape
#' boundary should be considered as core.
#' @param edge_depth Distance (in cells) a cell has to be away from the patch
#' edge to be considered as core cell.
#' @param cell_center If true, the coordinates of the centroid are forced to be
#' a cell center within the patch.
#' @param classes_max Potential maximum number of present classes.
#' @param neighbourhood The number of directions in which cell adjacencies are considered as neighbours:
#' 4 (rook's case) or 8 (queen's case). The default is 4.
#' @param ordered The type of pairs considered. Either ordered (TRUE) or unordered (FALSE).
#' The default is TRUE.
#' @param base The unit in which entropy is measured. The default is "log2",
#' which compute entropy in "bits". "log" and "log10" can be also used.
#' @param full_name Should the full names of all functions be included in the
#' tibble.
#' @param verbose Print warning messages.
#' @param progress Print progress report.
#'
#' @details
#' Wrapper to calculate several landscape metrics. The metrics can be specified
#' by the arguments `what`, `level`, `metric`, `name` and/or `type` (combinations
#' of different arguments are possible (e.g. `level = "class", type = "aggregation metric"`).
#' If an argument is not provided, automatically all possibilities are
#' selected. Therefore, to get **all** available metrics, don't specify any of the
#' above arguments.
#'
#' For all metrics based on distances or areas please make sure your data is valid
#' using \code{\link{check_landscape}}.
#'
#' @seealso
#' \code{\link{list_lsm}}
#'
#' @return tibble
#'
#' @examples
#' \dontrun{
#' landscape <- terra::rast(landscapemetrics::landscape)
#' calculate_lsm(landscape, progress = TRUE)
#' calculate_lsm(landscape, what = c("patch", "lsm_c_te", "lsm_l_pr"))
#' calculate_lsm(landscape, level = c("class", "landscape"),
#' type = "aggregation metric")
#' }
#'
#' @references
#' McGarigal K., SA Cushman, and E Ene. 2023. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical Maps. Computer software program produced by the authors;
#' available at the following web site: https://www.fragstats.org
#'
#' @export
calculate_lsm <- function(landscape,
                          level = NULL,
                          metric = NULL,
                          name = NULL,
                          type = NULL,
                          what = NULL,
                          directions = 8,
                          count_boundary = FALSE,
                          consider_boundary = FALSE,
                          edge_depth = 1,
                          cell_center = FALSE,
                          classes_max = NULL,
                          neighbourhood = 4,
                          ordered = TRUE,
                          base = "log2",
                          full_name = FALSE,
                          verbose = TRUE,
                          progress = FALSE) {

    landscape <- landscape_as_list(landscape)

    result <- lapply(X = seq_along(landscape), FUN = function(x) {

        if (progress) {

            cat("\r> Progress nlayers: ", x , "/", length(landscape))
        }

        calculate_lsm_internal(landscape = landscape[[x]],
                               level = level,
                               metric = metric,
                               name = name,
                               type = type,
                               what = what,
                               directions = directions,
                               count_boundary = count_boundary,
                               consider_boundary = consider_boundary,
                               edge_depth = edge_depth,
                               cell_center = cell_center,
                               classes_max = classes_max,
                               neighbourhood = neighbourhood,
                               ordered = ordered,
                               base = base,
                               full_name = full_name,
                               verbose = verbose,
                               progress = FALSE)
    })

    layer <- rep(seq_along(result),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    result <- result[with(result, order(layer, level, metric, class, id)), ]

    if (progress) {cat("\n")}

    tibble::add_column(result, layer, .before = TRUE)
}

calculate_lsm_internal <- function(landscape,
                                   level,
                                   metric,
                                   name,
                                   type,
                                   what,
                                   directions,
                                   count_boundary,
                                   consider_boundary,
                                   edge_depth,
                                   cell_center,
                                   classes_max,
                                   neighbourhood,
                                   ordered,
                                   base,
                                   full_name,
                                   verbose,
                                   progress) {

    # check if landscape is ok...
    # ...print warning if not
    if (verbose) {

        check <- check_landscape(landscape, verbose = FALSE)

        if (check$OK != cli::symbol$tick) {
            warning("Please use 'check_landscape()' to ensure the input data is valid.",
                    call. = FALSE)
        }
    }
    landscape <- terra::as.int(landscape)

    # get name of metrics
    metrics <- list_lsm(level = level, metric = metric, name = name,
                        type = type, what = what, simplify = TRUE, verbose = verbose)

    # use internal functions for calculation
    metrics_calc <- paste0(metrics, "_calc")

    # how many metrics need to be calculated?
    number_metrics <- length(metrics_calc)

    # prepare extras
    resolution <- terra::res(landscape)
    landscape <- terra::as.matrix(landscape, wide = TRUE)
    extras <- prepare_extras(metrics, landscape, directions, neighbourhood,
                                        ordered, base, resolution)

    result <- do.call(rbind, lapply(seq_along(metrics_calc), FUN = function(current_metric) {
        # print progress using the non-internal name
        if (progress) {
            cat("\r> Progress metrics: ", current_metric, "/", number_metrics)
        }

        # match function name
        foo <- get(metrics_calc[[current_metric]], mode = "function")

        # get argument
        arguments <- names(formals(foo))

        # run function
        #start_time = Sys.time()
        resultint <- tryCatch(do.call(what = foo,
                         args = mget(arguments, envir = parent.env(environment()))),
                 error = function(e){
                     message("")
                     stop(e)})

        #end_time = Sys.time()
        #resultint$time <- as.numeric(difftime(end_time, start_time, units = "secs"))
        resultint
        })
    )

    if (full_name == TRUE) {

        col_ordering <- c("level", "class", "id", "metric", "value",
                          "name", "type", "function_name"#,"time"
                          )

        result <- merge(x = result,
                        y = lsm_abbreviations_names,
                        by = c("level", "metric"),
                        all.x = TRUE, sort = FALSE, suffixes = c("", ""))

        result <- tibble::as_tibble(result[, col_ordering])
    }

    if (progress) {

        cat("\n")
    }

    return(result)
}
