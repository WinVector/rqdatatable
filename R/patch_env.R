
# build an environment that is a child of the global environment
# as data.table eval needs that for some things such as := and extensions
# and copy in items from environment
patch_global_child_env <- function(env) {
  force(env)
  nms <- ls(envir = env, all.names = TRUE)
  tmpenv <- new.env(parent = globalenv())
  for(ni in nms) {
    assign(ni, get(ni, envir = env), envir = tmpenv)
  }
  tmpenv
}
