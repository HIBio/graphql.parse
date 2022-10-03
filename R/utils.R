clean_html <- function(qs) {
  qs <- gsub("\n", "<br>", qs)
  qs <- gsub(" ", "&nbsp;", qs)
  htmltools::html_print(htmltools::div(htmltools::HTML(qs), style = "font-family:courier"))
}
