context("value_replacer_fn")

test_that("it replaces unnamed values correctly", {
  column <- c("A", "B", NA, "D")
  column <- value_replacer_fn(column, list(list(c("A", "B", "D"), 1), list(NA, 0)))
  expect_equal(column, c("1", "1", "0", "1"))
})

test_that("it replaces named values correctly", {
  column <- c("A", "B", NA, "D")
  column <- value_replacer_fn(column, list(A = 1, B = 2, D = 3))
  expect_equal(column, c("1", "2", NA, "3"))
})

test_that("it replaces mixed values correctly", {
  column <- c("A", "B", NA, "D")
  column <- value_replacer_fn(column, list(A = 1, B = 2, D = 3, list(NA, 0)))
  expect_equal(column, c("1", "2", "0", "3"))
})

test_that("it replaces in-place correctly", {
  column <- c(0, 1, 0, 1)
  column <- value_replacer_fn(column, list(c(0, 1), c(1, 0)))
  expect_equal(column, c(1, 0, 1, 0))
})

test_that("it replaces numerics correctly", {
  column <- c(0, 1, 2, 3)
  column <- value_replacer_fn(column, list(list(c(0, 1), 0), list(c(2, 3), 1)))
  expect_equal(column, c(0, 0, 1, 1))
})

test_that("it replaces factors correctly", {
  column <- factor(c("a", "b", "c"))
  column <- value_replacer_fn(column, list(a = "b", b = "a", c = "d"))
  expect_true(identical(column,
                        factor(c("b", "a", "d"), levels = c("b", "a", "d"))))
})

# mungebit tests

mungebits_loaded <- 'mungebits' %in% loadedNamespaces(); suppressMessages(require(mungebits))

test_that("it restores unnamed values correctly", {
  column <- c("A", "B", NA, "D")
  testdf <- mungebits:::mungeplane(data.frame(column, column, stringsAsFactors = FALSE))
  mb <- mungebits:::mungebit(value_replacer)
  mb$run(testdf, 1, list(list(c("A", "B", "D"), 1), list(NA, 0)))
  expect_equal(testdf$data[[1]], c("1", "1", "0", "1"))
})

test_that("it restores named values correctly", {
  column <- c("A", "B", NA, "D")
  testdf <- mungebits:::mungeplane(data.frame(column, column, stringsAsFactors = FALSE))
  mb <- mungebits:::mungebit(value_replacer)
  mb$run(testdf, 1, list(A = 1, B = 2, D = 3))
  expect_equal(testdf$data[[1]], c("1", "2", NA, "3"))
})

test_that("it restores mixed values correctly", {
  column <- c("A", "B", NA, "D")
  testdf <- mungebits:::mungeplane(data.frame(column, column, stringsAsFactors = FALSE))
  mb <- mungebits:::mungebit(value_replacer)
  mb$run(testdf, 1, list(A = 1, B = 2, D = 3, list(NA, 0)))
  expect_equal(testdf$data[[1]], c("1", "2", "0", "3"))
})

test_that("it restores in-place correctly", {
  column <- c(0, 1, 0, 1)
  testdf <- mungebits:::mungeplane(data.frame(column, column, stringsAsFactors = FALSE))
  mb <- mungebits:::mungebit(value_replacer)
  mb$run(testdf, 1, list(c(0, 1), c(1, 0)))
  expect_equal(testdf$data[[1]], c(1, 0, 1, 0))
})

test_that("it restores numerics correctly", {
  column <- c(0, 1, 2, 3)
  testdf <- mungebits:::mungeplane(data.frame(column, column, stringsAsFactors = FALSE))
  mb <- mungebits:::mungebit(value_replacer)
  mb$run(testdf, 1, list(list(c(0, 1), 0), list(c(2, 3), 1)))
  expect_equal(testdf$data[[1]], c(0, 0, 1, 1))
})

test_that("it restores factors correctly", {
  column <- factor(c("a", "b", "c"))

  testdf <- mungebits:::mungeplane(data.frame(column, column, stringsAsFactors = FALSE))
  mb <- mungebits:::mungebit(value_replacer)
  mb$run(testdf, 1, list(a = "b", b = "a", c = "d"))
  expect_equal(class(testdf$data[[1]]), 'factor')
  expect_true(identical(testdf$data[[1]],
                        factor(c("b", "a", "d"), levels = c("b", "a", "d"))))

  # Have to test predicts as well to make sure levels are restored
  testdf <- mungebits:::mungeplane(data.frame(column, column, stringsAsFactors = FALSE))
  testdf$data <- testdf$data[1, ]
  mb$run(testdf, 1, list(a = "b", b = "a", c = "d"))
  expect_equal(class(testdf$data[[1]]), 'factor')
  expect_true(identical(testdf$data[1, 1],
                        factor('b', levels = c("b", "a", "d"))))
})

test_that("it leaves new levels alone", {
  ###TRAIN
  train_df <- data.frame(x = factor(c("a", "2", "3", "4", "5", "5")), y = factor(c("a", "b", NA,"c", "d", "d")))
  mb <- mungebits:::mungebit(value_replacer)
  mp <- mungebits::mungeplane(train_df)
  mb$run(mp, is.factor, list(list(NA, "Missing"), list("a", "was_a")))

  ###PREDICT
  pred_df <- data.frame(x = factor(c("2", "a", "2", "leave_alone")), y = factor(c("a", "b", NA, "leave_alone2")))
  mp <- mungebits::mungeplane(pred_df)
  mb$run(mp, is.factor, list(list(NA, "Missing"), list("a", "was_a")))
  
  expected_df <- data.frame(x = factor(c("2", "was_a", "2", "leave_alone")), y = factor(c("was_a", "b", "Missing", "leave_alone2")))
  expect_equal(as.character(mp$data[[1]]),as.character(expected_df[[1]]))
  expect_equal(as.character(mp$data[[2]]),as.character(expected_df[[2]]))
})

test_that("it replaces factor NA that it hasn't seen in training", {
  ###TRAIN
  train_df <- data.frame(x = factor(c("a", "2", "3", "4", "5", "5")), y = factor(c("a", "b", NA,"c", "d", "d")))
  mb <- mungebits:::mungebit(value_replacer)
  mp <- mungebits::mungeplane(train_df)
  mb$run(mp, is.factor, list(list(NA, "Missing"), list("a", "was_a")))

  ###PREDICT
  pred_df <- data.frame(x = factor(c("2", "a", NA)), y = factor(c("a", "b", NA)))
  mp <- mungebits::mungeplane(pred_df)
  mb$run(mp, is.factor, list(list(NA, "Missing"), list("a", "was_a")))
  
  expected_df <- data.frame(x = factor(c("2", "was_a", "Missing")), y = factor(c("was_a", "b", "Missing")))
  expect_equal(as.character(mp$data[[1]]),as.character(expected_df[[1]]))
  expect_equal(as.character(mp$data[[2]]),as.character(expected_df[[2]]))
})

if (!mungebits_loaded) unloadNamespace('mungebits')

