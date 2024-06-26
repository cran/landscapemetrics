% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lsm_l_te.R
\name{lsm_l_te}
\alias{lsm_l_te}
\title{TE (landscape level)}
\usage{
lsm_l_te(landscape, count_boundary = FALSE)
}
\arguments{
\item{landscape}{A categorical raster object: SpatRaster; Raster* Layer, Stack, Brick; stars or a list of SpatRasters.}

\item{count_boundary}{Include landscape boundary in edge length}
}
\value{
tibble
}
\description{
Total edge (Area and Edge metric)
}
\details{
\deqn{TE = \sum \limits_{k = 1}^{m} e_{ik}}
where \eqn{e_{ik}} is the edge lengths in meters.
TE is an 'Area and edge metric'. Total edge includes all edges. It measures the
configuration of the landscape because a highly fragmented landscape will have many
edges. However, total edge is an absolute measure, making comparisons among landscapes
with different total areas difficult. If \code{count_boundary = TRUE} also edges to the
landscape boundary are included.

Because the metric is based on distances or areas please make sure your data
is valid using \code{\link{check_landscape}}.

\subsection{Units}{Meters}
\subsection{Range}{TE >= 0}
\subsection{Behaviour}{Equals TE = 0 if all cells are edge cells. Increases, without limit,
as landscape becomes more fragmented}
}
\examples{
landscape <- terra::rast(landscapemetrics::landscape)
lsm_l_te(landscape)

}
\references{
McGarigal K., SA Cushman, and E Ene. 2023. FRAGSTATS v4: Spatial Pattern Analysis
Program for Categorical Maps. Computer software program produced by the authors;
available at the following web site: https://www.fragstats.org
}
\seealso{
\code{\link{lsm_p_perim}}
\code{\link{lsm_l_te}}
}
