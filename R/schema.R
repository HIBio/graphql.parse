#' Default OpenTargets API endpoint
#'
#' @export
OT_API <- "https://api.platform.opentargets.org/api/v4/graphql"

#' Default OpenTargets Genetics API endpoint
#'
#' @export
OT_GENETICS_API <- "https://api.genetics.opentargets.org/graphql"

detect_class <- function(el) {
  # drop comments
  el <- strsplit(el, "\n")[[1]]
  el <- el[!grepl('^"', trimws(el))]
  el <- el[!trimws(el) == ""]
  # extract class
  strsplit(el[1], " ")[[1]][1]
}


base_formats <- c(
  Int = "integer",
  Long = "numeric",
  Float = "numeric",
  String = "character",
  Boolean = "logical"
)


#' Extract elements from the schema
#'
#' @param el element to process
#'
#' @return a list containing `object_class` (name of schema element) and
#'   arguments with associated class, description, and non_nullable flag
#' @export
#'
#' @examples
#' x <- parse_elements(types[21])
#' jsonview::json_tree_view(x)
parse_elements <- function(el, struct = "type", subquery = FALSE) {
  el <- trimws(strsplit(el, "\n")[[1]])
  # drop blank lines
  el <- el[el != ""]
  # strip comments
  el_clean <- el[!grepl('^"', el)]
  if (!subquery) {
    el_class <- strsplit(el_clean[1], " ")[[1]][[2]]
    el_id <- grep(paste0('^', struct, ' ',el_class), el)
    # strip to internal braces
    el <- el[-c(1:el_id, length(el))]
    res <- list(object_class = el_class)
  } else {
    el <- el[-c(1)]
    res <- list()
  }

  # expand lines
  for (l in seq_along(el)) {
    if (!grepl('^"', el[l]) && grepl(',', el[l], fixed = TRUE) && !grepl(',$', el[l])) {
      el_rep <- strsplit(el[l], ',[ ]*')[[1]]
      el[l] <- ""
      el <- append(el, el_rep, after = l-1)
    }
  }

  endpt_lines <- c()
  endpt <- FALSE

  for (l in seq_along(el)) {
    if (!endpt && !grepl('^"', el[l]) && grepl("(", el[l], fixed = TRUE)) {
      endpt <- TRUE
      description <- if (l > 1 && grepl('^"', el[l-1])) {
        el[l-1]
      } else {
        ""
      }
      ex_label <- list(
        name = sub('[(].*', '', el[l]),
        description = gsub('\"', "", description)
      )
    }

    if (endpt) {
      endpt_lines <- c(endpt_lines, el[l])
    } else {
      ex_class <- extract_class(el, l)
      ex_label <- extract_label(el, l)

      if (!is.null(ex_class)) {
        lst <- list(
          class = ex_class$class,
          description = ex_label$description,
          non_nullable = ex_class$non_nullable
        )
        res <- c(res, setNames(list(lst), ex_label$name))
      }
    }

    if (endpt && !grepl('^"', el[l]) && grepl(")", el[l], fixed = TRUE)) {
      endpt <- FALSE
      subquery <- paste(endpt_lines, collapse = "\n")
      lst <- list(
        subquery_class = gsub("[]!", "", sub('^.*[)]: ', '', endpt_lines[length(endpt_lines)]), fixed = TRUE),
        subquery_description = ex_label$description
      )
      lst <- c(lst, parse_elements(subquery, subquery = TRUE))
      nm <- sub("[(].*$", "", endpt_lines[1])
      res <- c(res, setNames(list(lst), nm))
      endpt_lines <- c()
    }
  }
  res
}


extract_label <- function(el, line) {
  if (grepl('^"', el[line])) {
    return(NULL)
  }
  if (grepl('):', el[line], fixed = TRUE)) {
    el[line] <- sub('[)]:.*$', '', el[line])
  }
  name <- strsplit(el[line], ": ")[[1]][1]
  description <- if (line > 1 && grepl('^"', el[line-1])) {
    el[line-1]
  } else {
    ""
  }
  list(name = sub(")", "", name, fixed = TRUE), description = gsub('\"', "", description))
}

extract_class <- function(el, line) {
  if (grepl('^"', el[line])) {
    return(NULL)
  }
  if (grepl(',', el[line], fixed = TRUE)) {
    el <- append(el, strsplit(el[line], ',[ ]*')[[1]], after = line-1)
  }
  if (grepl('):', el[line], fixed = TRUE)) {
    el[line] <- sub('[)]:.*$', '', el[line])
  }
  if (grepl(":", el[line])) {
    class_str <- strsplit(el[line], ": ")[[1]]
    list(class = class_str[[2]], non_nullable = grepl("!$", class_str[[2]]))
  }
}

create_types <- function(types) {
 .NotYetImplemented()
}

list_elements <- function(type) {
 .NotYetImplemented()
}

#' Get the schema for a GraphQL API
#'
#' @param api_url API query endpoint
#'
#' @return a character string containing the schema, which can be used in
#'   [query_builder()] without re-fetching
#' @export
get_schema <- function(api_url = OT_API) {
  httr::content(httr::GET(paste0(api_url, "/schema")))
}

#' Build a GraphQL Query String
#'
#' @param api_url URL of the API from which to read schema. By default this will
#'   use the OpenTargets API
#' @param schema a local copy of the schema as a character string
#'
#' @return a query string, possibly to be used in [run_query()]
#' @export
query_builder <- function(schema = NULL, api_url = OT_API) {
  stopifnot(!is.null(api_url))
  if (is.null(schema)) {
    schema <- get_schema(api_url)
  }
  # drop union types
  schema <- gsub("\nunion EntityUnionType = Target | Drug | Disease", "", schema, fixed = TRUE)
  schema_els <- strsplit(schema, "(?<=})", perl = TRUE)[[1]]
  # drop blank lines
  schema_els <- gsub("\n\n", "\n", schema_els)
  classes <- sapply(schema_els, detect_class)
  splits <- split(schema_els, classes)
  types <- splits$type
  types2 <- setNames(types, sapply(sapply(types, parse_elements), \(x) x$object_class))
  # prompt user to select level
  this_level <- "Query"
  tlqry <- parse_elements(types2[names(types2) == this_level])
  tlqry <- tlqry[names(tlqry) != "object_class"]
  sel_stack <- list(tlqry)
  chosen <- 1
  subquery_args <- NULL
  built_query <- c("query gql(", "\nARGS", "\n) {")
  indent <- 1
  while (chosen != 0) {
    clean_html(built_query)
    avail_selections <- sel_stack[[length(sel_stack)]]
    chosen <- utils::menu(c(names(avail_selections), "up 1 level"), title = paste0("Options in ", this_level, "; Select next level, or 0 to finish"))
    if (chosen == 0) {
      built_query <- closed_braces(built_query, indent, close_all = TRUE)
      break
    }
    if (chosen > length(avail_selections)) {
      if (length(sel_stack) == 1) {
        built_query <- closed_braces(built_query, indent, close_all = TRUE)
        break
      } else {
        sel_stack <- sel_stack[-length(sel_stack)]
        built_query <- closed_braces(built_query, indent)
        indent <- indent - 1
      }
      next
    }
    res <- examine_sel(types2, avail_selections, chosen, this_level, indent)
    subquery_args <- c(subquery_args, process_sq_args(res$subquery_args))
    indent <- res$indent
    built_query <- c(built_query, res$query)
    if (res$is_sub) sel_stack <- c(sel_stack, list(res$next_avail))
    this_level <- res$level
  }
  # fill in subquery args
  built_query[2] <- sub("ARGS", paste(subquery_args, collapse = ",\n"), built_query[2])
  cat(built_query)
  clean_html(built_query)
  suggest_variables_template(subquery_args)
  built_query <- structure(
    paste(built_query, collapse = ""),
    api_url = api_url,
    class = c("query_string", "character")
  )
  invisible(built_query)
}

suggest_variables_template <- function(args) {
  cat("\n\nTemplate for variables:\n\n")
  args <- trimws(strsplit(paste(args, collapse = ",\n"), ",\n")[[1]])
  args <- strsplit(args, ": ")
  args <- lapply(args, function(x) {
    x[1] <- sub("$", "", x[1], fixed = TRUE)
    x
  })
  args <- lapply(args, function(x) {
    x[3] <- grepl("!", x[2])
    x
  })
  args <- lapply(args, function(x) {
    x[2] <- base_formats[match(sub("!", "", x[2], fixed = TRUE), names(base_formats))]
    x
  })
  cat("variables = list(\n")
  args <- lapply(args, function(x) {
    paste0(ifelse(x[3], "   ", "  #"), x[1], " = ", x[2], "(1)")
    })
  cat(paste(args, collapse = ",\n"))
  cat("\n)\n")
}

closed_braces <- function(qry, indent, close_all = FALSE) {
  if (close_all) {
    for (i in rev(seq_len(indent))) {
      qry <- c(qry, paste0("\n", strrep(" ", (i-1)*3L), "}", collapse = ""))
    }
  } else {
    qry <- c(qry, paste0("\n", strrep(" ", (indent-1)*3L), "}", collapse = ""))
  }
  qry
}

process_sq_args <- function(x) {
  if (nrow(x) == 0) return(NULL)
  paste(paste0("  $", x$name, ": ", x$class), collapse = ",\n")
}

examine_sel <- function(types, x, i, lvl, indent) {
  res <- list()
  res$subquery_args <- data.frame()
  if (utils::hasName(x[[i]], "subquery_class")) {
    res$is_sub <- TRUE
    next_class <- parse_elements(types[names(types) == gsub("\\[|\\]|!", "", x[[i]]$subquery_class)])
    next_class <- next_class[names(next_class) != "object_class"]
    res$next_avail <- next_class
    # identify mandatory arguments
    all_args <- tibble::enframe(x[[i]][-c(1:2)]) |> tidyr::unnest_wider(value)
    res$subquery_args <- all_args
    res$query <- write_args(names(x)[[i]], all_args, indent)
    res$level <- x[[i]]$subquery_class
    res$indent <- indent + 1
  } else if (! gsub("\\[|\\]|!", "", x[[i]]$class) %in% names(base_formats)) {
    # non-atomic classes can be further subset
    res$is_sub <- TRUE
    clean_class <- gsub("\\[|\\]|!", "", x[[i]]$class)
    if (!clean_class %in% names(types)) {
      stop(paste0("Unable to find any entity of type `", clean_class, "` in the schema"))
    }
    next_class <- parse_elements(types[names(types) == clean_class])
    next_class <- next_class[names(next_class) != "object_class"]
    res$next_avail <- next_class
    res$query <- paste0("\n", strrep(" ", indent*3), names(x)[[i]], " {")
    res$level <- clean_class
    res$indent <- indent + 1
  } else {
    res$is_sub <- FALSE
    res$next_avail <- x
    res$level <- lvl
    res$indent <- indent
    res$query <- paste0("\n", strrep(" ", indent*3), names(x)[[i]])
  }
  res
}

write_args <- function(subqry_name, all_args, indent) {
  if (nrow(all_args) > 0) {
    paste0("\n",
           strrep(" ", indent*3),
           subqry_name, "(",
           paste0(
             paste0(
               all_args$name, ": $", all_args$name
             ),
             collapse = ", "
           ),
           ") {")
  } else {
    paste0("\n", strrep(" ", indent*3), subqry_name, "() {")
  }
}

