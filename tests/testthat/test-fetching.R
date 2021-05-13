library(DBI)
library(RSQLite)

test_that("Testing fetcher pulls arrests", {
  con <- DBI::dbConnect(RSQLite::SQLite(),
                        ps50sr:::.sys_file("extdata/ps50sr.sqlite"))
  expect_true({
    NROW(DBI::dbFetch(DBI::dbSendQuery(conn = con,
                             statement = "SELECT * FROM arrests"))) > 1
  })
  expect_true({
    is.data.frame(DBI::dbFetch(
      DBI::dbSendQuery(conn = con,
                       statement = "SELECT * FROM arrests")))
  })
  DBI::dbDisconnect(conn = con)
})

test_that("Testing fetcher pulls crimes", {
  con <- DBI::dbConnect(RSQLite::SQLite(),
                        ps50sr:::.sys_file("extdata/ps50sr.sqlite"))
  expect_true({
    NROW(DBI::dbFetch(DBI::dbSendQuery(conn = con,
                                       statement = "SELECT * FROM crimes"))) > 1
  })
  expect_true({
    is.data.frame(DBI::dbFetch(
      DBI::dbSendQuery(conn = con,
                       statement = "SELECT * FROM crimes")))
  })
  DBI::dbDisconnect(conn = con)
})

test_that("Testing fetcher pulls population areas", {
  con <- DBI::dbConnect(RSQLite::SQLite(),
                        ps50sr:::.sys_file("extdata/ps50sr.sqlite"))
  expect_true({
    NROW(DBI::dbFetch(DBI::dbSendQuery(conn = con,
                                       statement = "SELECT * FROM pop_area"))) > 1
  })
  expect_true({
    is.data.frame(DBI::dbFetch(
      DBI::dbSendQuery(conn = con,
                       statement = "SELECT * FROM pop_area")))
  })
  DBI::dbDisconnect(conn = con)
})

test_that("Testing fetcher pulls rates", {
  con <- DBI::dbConnect(RSQLite::SQLite(),
                        ps50sr:::.sys_file("extdata/ps50sr.sqlite"))
  expect_true({
    NROW(DBI::dbFetch(DBI::dbSendQuery(conn = con,
                                       statement = "SELECT * FROM rates"))) > 1
  })
  expect_true({
    is.data.frame(DBI::dbFetch(
      DBI::dbSendQuery(conn = con,
                       statement = "SELECT * FROM rates")))
  })
  DBI::dbDisconnect(conn = con)
})

test_that("Testing fetcher pulls bullets", {
  con <- DBI::dbConnect(RSQLite::SQLite(),
                        ps50sr:::.sys_file("extdata/ps50sr.sqlite"))
  expect_true({
    NROW(DBI::dbFetch(DBI::dbSendQuery(conn = con,
                                       statement = "SELECT * FROM bullets"))) > 1
  })
  expect_true({
    is.data.frame(DBI::dbFetch(
      DBI::dbSendQuery(conn = con,
                       statement = "SELECT * FROM bullets")))
  })
  DBI::dbDisconnect(conn = con)
})
