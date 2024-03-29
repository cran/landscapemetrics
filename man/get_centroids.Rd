% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_centroids.R
\name{get_centroids}
\alias{get_centroids}
\title{get_centroids}
\usage{
get_centroids(
  landscape,
  directions = 8,
  cell_center = FALSE,
  return_vec = FALSE,
  verbose = TRUE
)
}
\arguments{
\item{landscape}{A categorical raster object: SpatRaster; Raster* Layer, Stack, Brick; stars or a list of SpatRasters.}

\item{directions}{The number of directions in which patches should be
connected: 4 (rook's case) or 8 (queen's case).}

\item{cell_center}{If true, the coordinates of the centroid are forced to be
a cell center within the patch.}

\item{return_vec}{If true, a sf object is returned.}

\item{verbose}{Print warning messages}
}
\description{
Centroid of patches
}
\details{
Get the coordinates of the centroid of each patch. The centroid is by default
defined as the mean location of all cell centers. To force the centroid to be
located within each patch, use the \code{cell_center} argument. In this case, the
centroid is defined as the cell center that is the closest to the mean location.
}
\examples{
# get centroid location
landscape <- terra::rast(landscapemetrics::landscape)
get_centroids(landscape)

}
