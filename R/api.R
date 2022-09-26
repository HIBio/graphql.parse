#' Run a GraphQL query
#'
#' @param query_string query string, possibly built with [query_builder()]
#' @param variables `list` of variables to be used in the query
#'
#' @return returned data from the API
#' @export
run_query <- function(query_string, variables, api_url = OPENTARGETS_API) {
  # Construct POST request body object with query string and variables
  post_body <- list(query = query_string, variables = jsonlite::toJSON(variables, auto_unbox = TRUE))
  # Perform POST request
  r <- httr::POST(url = api_url, body = post_body, encode = 'json')
  # extract output
  httr::content(r)$data
}
