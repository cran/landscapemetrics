% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lsm_c_split.R
\name{lsm_c_split}
\alias{lsm_c_split}
\title{SPLIT (class level)}
\usage{
lsm_c_split(landscape, directions = 8)
}
\arguments{
\item{landscape}{A categorical raster object: SpatRaster; Raster* Layer, Stack, Brick; stars or a list of SpatRasters.}

\item{directions}{The number of directions in which patches should be
connected: 4 (rook's case) or 8 (queen's case).}
}
\value{
tibble
}
\description{
Splitting index (Aggregation metric)
}
\details{
\deqn{SPLIT = \frac{A^2} {\sum \limits_{j = 1}^{n} a_{ij}^2}}
where \eqn{a_{ij}} is the patch area in square meters and \eqn{A} is the
total landscape area.

SPLIT is an 'Aggregation metric'. It describes the number of patches if all patches of
class i would be divided into equally sized patches.

Because the metric is based on distances or areas please make sure your data
is valid using \code{\link{check_landscape}}.

\subsection{Units}{None}
\subsection{Range}{1 <= SPLIT <= Number of cells squared}
\subsection{Behaviour}{Equals SPLIT = 1 if only one patch is present. Increases as
the number of patches of class i increases and is limited if all cells are a patch}
}
\examples{
landscape <- terra::rast(landscapemetrics::landscape)
lsm_c_split(landscape)

}
\references{
McGarigal K., SA Cushman, and E Ene. 2023. FRAGSTATS v4: Spatial Pattern Analysis
Program for Categorical Maps. Computer software program produced by the authors;
available at the following web site: https://www.fragstats.org

Jaeger, J. A. 2000. Landscape division, splitting index, and effective mesh
size: new measures of landscape fragmentation.
Landscape ecology, 15(2), 115-130.
}
\seealso{
\code{\link{lsm_p_area}},
\code{\link{lsm_l_ta}}, \cr
\code{\link{lsm_l_split}}
}
