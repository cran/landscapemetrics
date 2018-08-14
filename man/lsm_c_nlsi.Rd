% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lsm_c_nlsi.R
\name{lsm_c_nlsi}
\alias{lsm_c_nlsi}
\alias{lsm_c_nlsi.RasterLayer}
\alias{lsm_c_nlsi.RasterStack}
\alias{lsm_c_nlsi.RasterBrick}
\alias{lsm_c_nlsi.list}
\title{nLSI (class level)}
\usage{
lsm_c_nlsi(landscape, directions)

\method{lsm_c_nlsi}{RasterLayer}(landscape, directions = 8)

\method{lsm_c_nlsi}{RasterStack}(landscape, directions = 8)

\method{lsm_c_nlsi}{RasterBrick}(landscape, directions = 8)

\method{lsm_c_nlsi}{list}(landscape, directions = 8)
}
\arguments{
\item{landscape}{Raster* Layer, Stack, Brick or a list of rasterLayers.}

\item{directions}{The number of directions in which patches should be
connected: 4 (rook's case) or 8 (queen's case).}
}
\value{
tibble
}
\description{
Normalized landscape shape index (Aggregation metric)
}
\details{
\deqn{nLSI = \frac{e_{i}} {\min e_{i}}}
where \eqn{e_{i}} is the total edge length in cell surfaces and \eqn{\min e_{i}}
is the minimum total edge length in cell surfaces

nLSI is an 'Aggregation metric'. It is the ratio between the actual edge length of
class i and the hypothetical minimum edge length of class i. The minimum edge length equals
the edge length if class i would be maximally aggregated.

\subsection{Units}{None}
\subsection{Ranges}{nlsi >= 1}
\subsection{Behaviour}{Equals nlsi = 1 when only one squared patch is present or all
patches are maximally aggregated. Increases, without limit, as the length of the
actual edges increases, i.e. the patches become less compact.}
}
\examples{
lsm_c_nlsi(landscape)

}
\references{
McGarigal, K., SA Cushman, and E Ene. 2012. FRAGSTATS v4: Spatial Pattern Analysis
Program for Categorical and Continuous Maps. Computer software program produced by
the authors at the University of Massachusetts, Amherst. Available at the following
web site: http://www.umass.edu/landeco/research/fragstats/fragstats.html

Patton, D. R. 1975. A diversity index for quantifying habitat "edge".
Wildl. Soc.Bull. 3:171-173.
}
\seealso{
\code{\link{lsm_p_shape}}
}