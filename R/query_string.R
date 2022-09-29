#' Print a query_string object
#'
#' @param x query_string object
#' @param ... ignored
#'
#' @return the query_string object
#' @export
print.query_string <- function(x, ...) {
  cat("# query_string targeting ")
  if (!is.null(api_url <- api_url(x))) {
    cat(api_url, "\n")
  } else {
    cat("unknown endpoint\n")
  }
  cat(paste(x, collapse = "\n"))
  x
}

#' Extract `api_url` from an object
#'
#' @rdname api_url
#'
#' @param x object from which to extract `api_url`
#' @param ... ignored
#'
#' @return the `api_url` (if available)
#' @export
api_url <- function(x, ...) {
  UseMethod("api_url")
}

#' @rdname api_url
#' @export
api_url.default <- function(x, ...) {
  warning("No api_url detected on this object")
  NULL
}

#' @rdname api_url
#' @export
api_url.query_string <- function(x, ...) {
  attr(x, "api_url")
}

