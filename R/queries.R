#' (Canned Query) dataVersion
#'
#' @param api_url API URL
#'
#' @return API name and dataVersion
#' @export
dataVersion <- function(api_url = OT_API) {
  qs <- if (api_url == OT_API) {
  "
  query gql(
  $queryString: String!,
  $entityNames: [String!],
  $page: Pagination
) {
   search(queryString: $queryString, entityNames: $entityNames, page: $page) {
     total
   }
   meta {
      name
      dataVersion {
         year
         month
         iteration
      }
   }
}"
  } else if (api_url == OT_GENETICS_API) {
  "
  query gql(
  $queryString: String!,
  $page: Pagination
) {
   search(queryString: $queryString, page: $page) {
     totalGenes
   }
   meta {
      name
   dataVersion {
      major
      minor
      patch
    }
   }
}"
  } else {
    stop("Not clear how to search this API")
  }
  res <- run_query(qs, variables = list(queryString = "a"), api_url = api_url)
  res$meta$dataVersion <- unlist(res$meta$dataVersion)
  res$meta
}
