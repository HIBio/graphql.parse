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
#'   arguments with associated class, description, and nullable flag
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
          nullable = ex_class$nullable
        )
        res <- c(res, setNames(list(lst), ex_label$name))
      }
    }

    if (endpt && !grepl('^"', el[l]) && grepl(")", el[l], fixed = TRUE)) {
      endpt <- FALSE
      subquery <- paste(endpt_lines, collapse = "\n")
      lst <- list(subquery_class = sub('^.*[)]: ', '', endpt_lines[length(endpt_lines)]))
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
    list(class = class_str[[2]], nullable = grepl("!$", class_str[[2]]))
  }
}

create_types <- function(types) {
 .NotYetImplemented()
}

list_elements <- function(type) {
 .NotYetImplemented()
}
