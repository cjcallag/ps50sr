#' @title Query Table
#'
#' @param conn connection to a database.
#' @param table a character vector naming the table to query (e.g., "arrests")
#' @param where a character vector for valid SQL WHERE query (e.g., "State = 'California' AND Variable = '2007'")
#' @param dt a logical, if true table will be coerced to `data.table`
#' @param verbose a logical, if true the function prints the SQL query
#'
#' @importFrom data.table setDT
#' @importFrom DBI dbIsValid dbFetch dbSendQuery dbListTables
#'
#' @examples
#' \dontrun{fetch_arrests(conn = con, table = "arrests", where = "State = 'California' AND Variable = '2007'")}
#'
#' @export
fetch_table <- function(conn, table, where = "", dt = TRUE, verbose = TRUE) {
  stopifnot("conn must be a valid database connection." = DBI::dbIsValid(conn))
  stopifnot("table must be a character" = is.character(table),
            "table must exist in database" = table %in% DBI::dbListTables(conn))
  stopifnot("where must be character" = is.character(where))
  query <- paste(
    "SELECT * FROM",
    table,
    ifelse(nchar(where) >= 1, paste0("WHERE ", where), "")
  )
  out <- tryCatch(
    {
      res <- DBI::dbSendQuery(conn = conn, statement = query)
      DBI::dbFetch(res)
      },
    error   = function(cond) {message(cond); return(NA)},
    # TODO handle warnings more efficiently...
    # warning = function(cond) {message(cond); return(2)},
    finally = function(cond) {message("No attempts worked.")}
  )
  if (verbose) cat("\n\t", query, "\n")
  if (isTRUE(dt) && NROW(out) > 1) setDT(out)
  return(out)
}
