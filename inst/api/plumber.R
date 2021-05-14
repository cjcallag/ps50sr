library(data.table)
library(DBI)
library(ggplot2)
library(plumber)
library(RSQLite)
library(scales)


#* @apiTitle ps50sr API
#* @apiDescription A web API from source code for the **{ps50sr}** package.

#* Echo back the input
#* @param msg The message to echo
#* @get /echo
function(msg = "") {
    list(msg = paste0("The message is: '", msg, "'"))
}

#* Fetch table
#* @param table a character vector naming the table to query (e.g., "arrests")
#* @param where a character vector for valid SQL WHERE query (e.g., "State = 'California' AND Variable = '2007'")
#* @param dt a logical, if true table will be coerced to `data.table`
#* @get /data
function(table = "", where = "", dt = TRUE) {
  con <- DBI::dbConnect(RSQLite::SQLite(), ps50sr:::.sys_file("extdata/ps50sr.sqlite"))
  out <- ps50sr::fetch_table(conn = con,
                             table = table,
                             where = where,
                             dt = dt)
  on.exit(DBI::dbDisconnect(con))
  return(list(out))
}

#* Fetch available tables
#* @get /tablenames
function(headers = FALSE) {
  con <- DBI::dbConnect(RSQLite::SQLite(), ps50sr:::.sys_file("extdata/ps50sr.sqlite"))
  on.exit(DBI::dbDisconnect(con))
  out <- DBI::dbListTables(con)
  if (headers) {
    temp <- lapply(out, function(x) {
      res <- DBI::dbFetch(DBI::dbSendQuery(conn      = con,
                                           statement = paste0("SELECT * FROM ",
                                                              x)))
      names(res)
    })
    names(temp) <- out
    out <- temp
      }
  return(out)
}

#* Fetch graph
#* @param table a character vector naming the table to query (e.g., "arrests")
#* @param where a character vector for valid SQL WHERE query (e.g., "State = 'California' AND Variable = '2007'")
#* @get /graph
#* @serializer png
function(table = "", where = "") {
  con <- DBI::dbConnect(RSQLite::SQLite(), ps50sr:::.sys_file("extdata/ps50sr.sqlite"))
  on.exit(DBI::dbDisconnect(con))
  res <- ps50sr::fetch_table(conn = con,
                             table = table,
                             where = where,
                             dt = TRUE)
  res <- res[!Variable %like% "Percent Change"
      ][, ':='("Variable" = as.POSIXct(paste(Variable, 1, 1, sep = "-")),
               "Value"    = as.numeric(Value),
               "Type"     = gsub("[-]+", " ", Type))]
  plot <- ggplot(data = res) +
    geom_line(aes(x = Variable, y = Value, group = Type, color = Type)) +
    theme_minimal() +
    scale_x_datetime(date_labels = "%Y", date_breaks  ="1 year") +
    xlab(NULL) +
    ylab(NULL) +
    labs(fill = "Crime Type") +
    theme(axis.text.x = element_text(angle = 45, vjust = 0.5),
          axis.text.y = element_text(angle = 45),
          legend.position = "right") +
    scale_y_continuous(labels = comma) +
    labs(caption = element_text("\n Data source: https://50statespublicsafety.us/"))
  print(plot)
}
