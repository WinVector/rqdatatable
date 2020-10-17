check\_reverse\_dependencies
================

``` r
library("prrd")
td <- tempdir()
package = "rqdatatable"
date()
```

    ## [1] "Sat Oct 17 10:27:17 2020"

``` r
packageVersion(package)
```

    ## [1] '1.2.9'

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

    ## [1] "/var/folders/7f/sdjycp_d08n8wwytsbgwqgsw0000gn/T//RtmpGVPZNn"

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

    ## ## Reverse depends check of rqdatatable 1.2.9 
    ## cdata_1.1.8 started at 2020-10-17 10:27:19 success at 2020-10-17 10:27:40 (1/0/0) 
    ## WVPlots_1.3.1 started at 2020-10-17 10:27:40 success at 2020-10-17 10:28:28 (2/0/0)

    ## [1] id     title  status
    ## <0 rows> (or 0-length row.names)

``` r
summariseQueue(package=package, directory=td)
```

    ## Test of rqdatatable 1.2.9 had 2 successes, 0 failures, and 0 skipped packages. 
    ## Ran from 2020-10-17 10:27:19 to 2020-10-17 10:28:28 for 1.15 mins 
    ## Average of 34.5 secs relative to 34.522 secs using 1 runners
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
