% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/make_dt_lookup_by_column.R
\name{make_dt_lookup_by_column}
\alias{make_dt_lookup_by_column}
\title{Lookup by column function factory.}
\usage{
make_dt_lookup_by_column(pick, result)
}
\arguments{
\item{pick}{character scalar, name of column to control value choices.}

\item{result}{character scalar, name of column to place values in.}
}
\value{
f_dt() function.
}
\description{
Build data.table implementation of lookup_by_column.  We do this here as rqdatatable is
a data.table aware package (and rquery is not).
}
\examples{

df = data.frame(x = c(1, 2, 3, 4),
                y = c(5, 6, 7, 8),
                choice = c("x", "y", "x", "z"),
                stringsAsFactors = FALSE)
make_dt_lookup_by_column("choice", "derived")(df)

# # base-R implementation
# df \%.>\% lookup_by_column(., "choice", "derived")
# # # data.table implementation (requies rquery 1.1.0, or newer)
# # df \%.>\% lookup_by_column(., "choice", "derived",
# #                          f_dt_factory = rqdatatable::make_dt_lookup_by_column)

}
