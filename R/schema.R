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
        subquery_class = sub('^.*[)]: ', '', endpt_lines[length(endpt_lines)]),
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

query_builder <- function() {
  schema <- httr::content(httr::GET("https://api.platform.opentargets.org/api/v4/graphql/schema"))
  schema_els <- strsplit(schema, "(?<=})", perl = TRUE)[[1]]
  # drop blank lines
  schema_els <- gsub("\n\n", "\n", schema_els)
  classes <- sapply(schema_els, graphql.parse:::detect_class)
  splits <- split(schema_els, classes)
  types <- splits$type
  types2 <- setNames(types, sapply(sapply(types, parse_elements), \(x) x$object_class))
  # prompt user to select level
  this_level <- "Query"
  tlqry <- parse_elements(types2[names(types2) == this_level])
  # avail_selections <- prev_selections <- tlqry
  sel_stack <- list(tlqry)
  chosen <- 1
  built_query <- "query gql(FILL_THESE_ARGS) {\n"
  while (chosen != 0) {
    avail_selections <- sel_stack[[length(sel_stack)]]
    chosen <- utils::menu(c(names(avail_selections), "up 1 level"), title = paste0("Options in ", this_level, "; Select next level, or 0 to finish"))
    if (chosen == 0) {
      built_query <- c(built_query, "}")
      break
    }
    if (chosen > length(avail_selections)) {
      if (length(sel_stack) == 1) {
        built_query <- c(built_query, "\n}")
        break
      } else {
        sel_stack <- sel_stack[-length(sel_stack)]
      }
      built_query <- c(built_query, "\n}")
      next
    }
    res <- examine_sel(types2, avail_selections, chosen, this_level)
    built_query <- c(built_query, res$query)
    if (res$is_sub) sel_stack <- c(sel_stack, list(res$next_avail))
    this_level <- res$level
  }
  cat(built_query)
  invisible(built_query)
}

examine_sel <- function(types, x, i, lvl) {
  res <- list()
  # browser()
  if (utils::hasName(x[[i]], "subquery_class")) {
    res$is_sub <- TRUE
    next_class <- parse_elements(types[names(types) == x[[i]]$subquery_class])
    next_class <- next_class[names(next_class) != "object_class"]
    res$next_avail <- next_class
    # identify mandatory arguments
    all_args <- tibble::enframe(x[[i]][-c(1:2)]) |> tidyr::unnest_wider(value)
    mand_args <- all_args[, all_args$non_nullable]
    res$query <- if (nrow(mand_args) > 0) {
      paste0(names(x)[[i]], "(\n  ", paste0(mand_args$name, ": $", mand_args$name, " # ", mand_args$class, "\n"), " ) {\n")
    } else {
      paste0(names(x)[[i]], "() {\n")
    }
    res$level <- x[[i]]$subquery_class
  } else if (! gsub("\\[|\\]|!", "", x[[i]]$class) %in% names(base_formats)) {
    # non-atomic classes can be further subset
    res$is_sub <- TRUE
    clean_class <- gsub("\\[|\\]|!", "", x[[i]]$class)
    next_class <- parse_elements(types[names(types) == clean_class])
    next_class <- next_class[names(next_class) != "object_class"]
    res$next_avail <- next_class
    res$query <- paste0(names(x)[[i]], " {\n")
    res$level <- clean_class
  } else {
    # browser()
    res$is_sub <- FALSE
    res$next_avail <- x
    res$level <- lvl
    res$query <- paste0(names(x)[[i]], "\n")
  }
  res
}
