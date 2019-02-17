
# package to check
pkg = "rqdatatable"

# This file is distributed without license requirements, feel free to alter/copy.
if(requireNamespace("RUnit", quietly = TRUE) &&
   requireNamespace("wrapr", quietly = TRUE)) {
  # library("RUnit") # uncomment this if you want RUnit attached during testing
  library(pkg, character.only = TRUE)
  rqdatatable::run_rqdatatable_tests(verbose = TRUE, require_RUnit_attached = FALSE)
}
