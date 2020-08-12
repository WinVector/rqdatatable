check\_reverse\_dependencies
================

``` r
library("prrd")
td <- tempdir()
package = "rqdatatable"
date()
```

    ## [1] "Wed Aug 12 07:56:28 2020"

``` r
packageVersion(package)
```

    ## [1] '1.2.8'

``` r
parallelCluster <- NULL
ncores <- 0
# # parallel doesn't work due to https://github.com/r-lib/liteq/issues/22
#ncores <- parallel::detectCores()
#parallelCluster <- parallel::makeCluster(ncores)

orig_dir <- getwd()
print(orig_dir)
```

    ## [1] "/Users/johnmount/Documents/work/rqdatatable/extras"

``` r
setwd(td)
print(td)
```

    ## [1] "/var/folders/7f/sdjycp_d08n8wwytsbgwqgsw0000gn/T//RtmpgF9o9K"

``` r
options(repos = c(CRAN="https://cloud.r-project.org"))
jobsdfe <- enqueueJobs(package=package, directory=td)

mk_fn <- function(package, directory) {
  force(package)
  force(directory)
  function(i) {
    library("prrd")
    options(repos = c(CRAN="https://cloud.r-project.org"))
    setwd(directory)
    Sys.sleep(1*i)
    dequeueJobs(package=package, directory=directory)
  }
}
f <- mk_fn(package=package, directory=td)

if(!is.null(parallelCluster)) {
  parallel::parLapply(parallelCluster, seq_len(ncores), f)
} else {
  f(0)
}
```

    ## ## Reverse depends check of rqdatatable 1.2.8 
    ## cdata_1.1.6 started at 2020-08-12 07:56:30 success at 2020-08-12 07:56:52 (1/0/0) 
    ## WVPlots_1.2.6 started at 2020-08-12 07:56:52 success at 2020-08-12 07:57:47 (2/0/0)

    ## [1] id     title  status
    ## <0 rows> (or 0-length row.names)

``` r
summariseQueue(package=package, directory=td)
```

    ## Test of rqdatatable 1.2.8 had 2 successes, 0 failures, and 0 skipped packages. 
    ## Ran from 2020-08-12 07:56:30 to 2020-08-12 07:57:47 for 1.283 mins 
    ## Average of 38.5 secs relative to 38.579 secs using 1 runners
    ## 
    ## Failed packages:   
    ## 
    ## Skipped packages:   
    ## 
    ## None still working
    ## 
    ## None still scheduled

``` r
setwd(orig_dir)
if(!is.null(parallelCluster)) {
  parallel::stopCluster(parallelCluster)
}
```
