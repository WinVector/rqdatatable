
test_assoc <- function() {

  d <- data.frame(t = 1:2)

  target <- data.frame(t = 1:2, u = 2:3, v = 3:4, w = 4:5)

  # rquery/rqdatatable gets associativity by leaving value in "." and
  # evaluating right-hand-sides as expresions.

  r1 <- d %.>% extend(., u = t+1) %.>% extend(., v = u+1) %.>% extend(., w = v+1)
  expect_equal(r1, target)

  r2 <- d %.>% extend(., u = t+1) %.>% ( extend(., v = u+1) %.>% extend(., w = v+1) )
  expect_equal(r2, target)

  r3 <- d %.>% ( extend(., u = t+1) %.>% extend(., v = u+1) %.>% extend(., w = v+1) )
  expect_equal(r3, target)

  r4 <- d %.>% ( extend(., u = t+1) %.>% extend(., v = u+1) ) %.>% extend(., w = v+1)
  expect_equal(r4, target)

  r5 <- d %.>% extend(., u = t+1) %.>% { extend(., v = u+1) %.>% extend(., w = v+1) }
  expect_equal(r5, target)

  r6 <- d %.>% { extend(., u = t+1) %.>% extend(., v = u+1) %.>% extend(., w = v+1) }
  expect_equal(r6, target)

  r7 <- d %.>% { extend(., u = t+1) %.>% extend(., v = u+1) } %.>% extend(., w = v+1)
  expect_equal(r7, target)

  invisible(NULL)
}

test_assoc()

