#' Select variables in a dataframe.
#'
#' @param dataframe a data.frame
#' @param cols an atomic vector. Drop all but these columns.
#' @return NULL ensures the column gets removed
#' @export
#' @examples
#' select_variables(iris, 1) # Select only first variable
#' select_variables(iris, c('Sepal.Length', 'Petal.Length'))
#' select_variables(iris, c(T,T,F,F,T)) # Exclude cols 3 and 4
select_variables <- function(dataframe, cols) {
  cols <- standard_column_format(cols, dataframe)
  eval(substitute({
    dataframe <- dataframe[, cols, drop = FALSE]
  }), envir = parent.frame())
}

