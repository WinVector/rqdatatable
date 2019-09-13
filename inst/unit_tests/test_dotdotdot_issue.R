
test_dotdotdot_issue <- function() {
  invisible(NULL)


  f <- function(...) {
    t = extend(data.frame(x=2), one=1)
    return(t)
  }

  f()
  f(y=7)
}
