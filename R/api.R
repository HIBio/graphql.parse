#' Run a GraphQL query
#'
#' @param query_string query string, possibly built with [query_builder()]
#' @param variables `list` of variables to be used in the query
#'
#' @return returned data from the API
#' @export
run_query <- function(query_string, variables, api_url = OT_API) {
  # if query_string has an attached api_url, use that
  if (!is.null(qs_api_url <- api_url(query_string))) {
    api_url <- qs_api_url
  }
  # Construct POST request body object with query string and variables
  post_body <- list(query = query_string, variables = jsonlite::toJSON(variables, auto_unbox = TRUE))
  # Perform POST request
  r <- httr::POST(url = api_url, body = post_body, encode = 'json')
  # extract output
  httr::content(r)$data
}
