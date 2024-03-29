#' Show core area
#'
#' @description Show core area
#'
#' @param landscape Raster object
#' @param directions The number of directions in which patches should be
#' connected: 4 (rook's case) or 8 (queen's case).
#' @param class How to show the core area: "global" (single map), "all" (every class as facet), or a vector with the specific classes one wants to show (every selected class as facet).
#' @param consider_boundary Logical if cells that only neighbour the landscape
#' boundary should be considered as core.
#' @param labels Logical flag indicating whether to print or not to print core labels.
#' boundary should be considered as core
#' @param nrow,ncol Number of rows and columns for the facet.
#' @param edge_depth Distance (in cells) a cell has the be away from the patch
#' edge to be considered as core cell
#'
#' @details The functions plots the core area of patches labeled with the
#' corresponding patch id. The edges are the grey cells surrounding the patches and are always shown.
#'
#' @return ggplot
#'
#' @examples
#' landscape <- terra::rast(landscapemetrics::landscape)
#'
#' # show "global" core area
#' show_cores(landscape, class = "global", labels = FALSE)
#'
#' # show the core area of every class as facet
#' show_cores(landscape, class = "all", labels = FALSE)
#'
#' # show only the core area of class 1 and 3
#' show_cores(landscape, class = c(1, 3), labels = TRUE)
#'
#' @export
show_cores <- function(landscape,
                       directions = 8,
                       class = "all",
                       labels = FALSE,
                       nrow = NULL,
                       ncol = NULL,
                       consider_boundary = TRUE,
                       edge_depth = 1) {

    landscape <- landscape_as_list(landscape)

    result <- lapply(X = landscape,
                     FUN = show_cores_internal,
                     directions = directions,
                     class = class,
                     labels = labels,
                     nrow = nrow,
                     ncol = ncol,
                     consider_boundary = consider_boundary,
                     edge_depth = edge_depth)

    names(result) <- paste0("layer_", 1:length(result))

    return(result)
}

show_cores_internal <- function(landscape, directions, class, labels, nrow, ncol,
                                consider_boundary, edge_depth ) {

    if (any(!(class %in% c("all", "global")))) {

        if (!any(class %in% unique(terra::values(landscape, mat = FALSE)))) {

            stop("class must at least contain one value of a class contained in the landscape.", call. = FALSE)
        }
    }

    if (length(class) > 1 & any(class %in% c("all", "global"))) {

        warning("'global' and 'all' can't be combined with any other class-argument.", call. = FALSE)
    }

    landscape_labeled <- get_patches(landscape, directions = directions)[[1]]

    boundary <- lapply(X = landscape_labeled, FUN = function(patches_class) {

        class_edge <- get_boundaries(patches_class,
                                     consider_boundary = consider_boundary)[[1]]

        full_edge <- class_edge

        if (edge_depth > 1) {

            for (i in seq_len(edge_depth - 1)) {

                terra::values(class_edge)[terra::values(class_edge) == 1] <- NA

                class_edge <- get_boundaries(class_edge,
                                             consider_boundary)[[1]]

                full_edge[which(class_edge[] == 1)] <- 1
            }
        }

        terra::crop(full_edge, y = landscape)
    })

    # reset boundaries
    boundary <- lapply(X = seq_along(boundary),
                       FUN = function(i){
                           terra::values(boundary[[i]])[terra::values(!is.na(boundary[[i]])) & terra::values(boundary[[i]] == 1)] <- -999

                           terra::values(boundary[[i]])[terra::values(!is.na(boundary[[i]])) & terra::values(boundary[[i]] == 0)] <-
                               terra::values(landscape_labeled[[i]])[terra::values(!is.na(boundary[[i]])) & terra::values(boundary[[i]] == 0)]

                           return(boundary[[i]])
                       }
    )

    boundary_labeled_stack <- terra::as.data.frame(sum(terra::rast(boundary), na.rm = TRUE), xy = TRUE)
    names(boundary_labeled_stack) <- c("x", "y", "values")

    boundary_labeled_stack$class <-  terra::values(landscape, mat = FALSE)
    boundary_labeled_stack$core_label <- boundary_labeled_stack$values

    boundary_labeled_stack$values <-  ifelse(boundary_labeled_stack$values == -999, 0, 1)
    boundary_labeled_stack$core_label <- ifelse(boundary_labeled_stack$core_label == -999, as.numeric(NA), boundary_labeled_stack$core_label)

    if (!labels) {
        boundary_labeled_stack$core_label <- NA
    }

    if (any(class == "global")) {
        boundary_labeled_stack$class <- "global"
    }

    if (any(class != "global")) {

        if (any(!(class %in% "all"))) {
            class_index <- which(boundary_labeled_stack$class %in% class)
            boundary_labeled_stack <- boundary_labeled_stack[class_index, ]
        }
    }

    plot <- ggplot2::ggplot(boundary_labeled_stack, ggplot2::aes(x, y)) +
        ggplot2::geom_raster(ggplot2::aes(fill = factor(values))) +
        ggplot2::geom_text(ggplot2::aes(x = .data[["x"]], y = .data[["y"]], label = .data[["core_label"]]),
                           colour = "white", na.rm = TRUE) +
        ggplot2::facet_wrap(~ class, nrow = nrow, ncol = ncol) +
        ggplot2::scale_fill_manual(values = c("grey60", "#E17C05"), na.value = "grey85") +
        ggplot2::scale_x_continuous(expand = c(0, 0)) +
        ggplot2::scale_y_continuous(expand = c(0, 0)) +
        ggplot2::coord_fixed() +
        ggplot2::guides(fill = "none") +
        ggplot2::labs(titel = NULL, x = NULL, y = NULL) +
        ggplot2::theme(
            axis.title  = ggplot2::element_blank(), axis.ticks  = ggplot2::element_blank(),
            axis.text   = ggplot2::element_blank(), axis.line   = ggplot2::element_blank(),
            panel.grid  = ggplot2::element_blank(), panel.background = ggplot2::element_rect(fill = "grey85"),
            strip.background = ggplot2::element_rect(fill = "grey80"), strip.text = ggplot2::element_text(hjust  = 0),
            plot.margin = ggplot2::unit(c(0, 0, 0, 0), "lines"))

    return(plot)
}
