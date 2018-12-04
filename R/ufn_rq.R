
#' @importMethodsFrom wrapr ApplyTo
#' @importClassesFrom wrapr UnaryFn UnaryFnList PartialNamedFn PartialFunction
NULL

#' @importFrom methods new setClass setMethod signature show is
NULL



is_list_of_1_rqpipeline <- function(object) {
  rqpipeline <- object@rqpipeline
  if(!is.list(rqpipeline)) {
    return("object@rqpipeline must be a list")
  }
  if(length(rqpipeline)!=1) {
    return("length of object@rqpipeline must be 1")
  }
  if(!("relop" %in% class(rqpipeline[[1]]))) {
    return("object@rqpipeline must contain an rquery pipeline")
  }
  return(character(0))
}

#' rquery step as a new partial function.
#' @export
setClass(
  "rq_u_fn_w",
  contains = "UnaryFn",
  slots = c(rqpipeline = "list"),
  validity = is_list_of_1_rqpipeline)

#' Wrap an rquery pipeline exprssion as a function.
#'
#' @param rqpipeline rquery pipeline.
#' @return rq_u_fn_w
#'
#' @export
#'
rq_fn_wrapper <- function(rqpipeline) {
  new(
    "rq_u_fn_w",
    rqpipeline = list(rqpipeline)
  )
}


#' Apply a single argument function to its argument.
#'
#'
#' @param f object of S4 class derived from UnaryFn.
#' @param x argument.
#' @param env environment to work in.
#' @return f(x) if x is not a UnaryFn else f composed with x.
#'
#' @export
#'
#' @rdname ApplyTo
#' @export
setMethod(
  "ApplyTo",
  signature(f = "rq_u_fn_w", x = "data.frame"),
  function(f, x, env = parent.frame()) {
    force(env)
    rqpipeline <- (f@rqpipeline)[[1]]
    rquery_apply_to_data_frame(x, rqpipeline, env = env)
  })

#' @rdname ApplyTo
#' @export
setMethod(
  "ApplyTo",
  signature(f = "rq_u_fn_w", x = "UnaryFnList"),
  function(f, x, env = parent.frame()) {
    new("UnaryFnList",
        items = wrapr::concat_items_rev(list(f), x@items))
  })

#' @rdname ApplyTo
#' @export
setMethod(
  "ApplyTo",
  signature(f = "rq_u_fn_w", x = "UnaryFn"),
  function(f, x, env = parent.frame()) {
    new("UnaryFnList",
        items = wrapr::concat_items_rev(list(f), list(x)))
  })


#' format step
#'
#' @param x object to format
#' @param ... additional aguments (not used)
#' @return character
#'
#' @export
format.rq_u_fn_w <- function(x, ...) {
  paste0("rq_u_fn_w{ ",
         paste(format(x@rqpipeline[[1]]), collapse = "\n   "),
         " }")
}

#' S4 print method
#'
#' @param object item to print
#'
#' @export
setMethod(
  f = "show",
  signature = "rq_u_fn_w",
  definition = function(object) {
    print(format(object))
  })

