# Copy database ----------------------------------------------------------------
file.copy(from = "inst/extdata/ps50sr.sqlite",
          to   = "inst/ps50sr-dashboard/",
          overwrite = TRUE)

# Load libraries ---------------------------------------------------------------
library(data.table)
library(DBI)
library(ggplot2)
library(leaflet)
library(plotly)
library(RSQLite)
library(sf)
library(shiny)
library(shinydashboard)
library(shinycssloaders)

# Get states -------------------------------------------------------------------
con    <- dbConnect(RSQLite::SQLite(), "ps50sr.sqlite")
res    <- dbSendQuery(con, "SELECT State, Abbrev FROM arrests")
states <- dbFetch(res)
dbClearResult(res)
states <- unique(states)
dbDisconnect(con)

# Get State shape --------------------------------------------------------------
states_api <- function(state) {
  stopifnot("state must be character" = is.character(state))
  url <- paste0(
    "https://tigerweb.geo.census.gov/arcgis/rest/services/TIGERweb/State_County/MapServer/0/query?where=STUSAB='",
    state,
    "'&outFields=BASENAME&outSR=4326&f=json")
  sf::st_read(url)
}

# Does this work?
# test <- lapply(states[["Abbrev"]], function(x) {states_api(x)})
