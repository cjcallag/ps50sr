#' @title `system.file()` wrapper
#'
#' @description  Use to access files in `inst/`
#'
#' @param file_path Character of target file relative to `/inst`
#'
.sys_file <- function(file_path) {
  stopifnot(is.character(file_path) && length(file_path) == 1L)
  system.file(file_path, package = "ps50sr", mustWork = TRUE)
}
