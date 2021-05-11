shinyServer(function(input, output) {
    # Set up observers =========================================================
    modal_about()

    get_rates_data <- eventReactive(input$rates_state, {
        con    <- dbConnect(RSQLite::SQLite(), "ps50sr.sqlite")
        on.exit(dbDisconnect(con))
        out <- list(
            "bullets" = dbFetch(dbSendQuery(conn = con,
                                            statement = paste0("SELECT * FROM bullets WHERE State = '",
                                                               input$rates_state,
                                                               "'"))),
            "rates" = dbFetch(dbSendQuery(conn = con,
                                          statement = paste0("SELECT * FROM rates WHERE State = '",
                                                             input$rates_state,
                                                             "'"))),
            "pop_area" = dbFetch(dbSendQuery(conn = con,
                                             statement = paste0("SELECT * FROM pop_area WHERE State = '",
                                                                toupper(input$rates_state),
                                                                "'")))
        )
        out
    })
    get_arrests_data <- eventReactive(input$arrests_state, {
        con    <- dbConnect(RSQLite::SQLite(), "ps50sr.sqlite")
        on.exit(dbDisconnect(con))
        out <- list(
            "bullets" = dbFetch(dbSendQuery(conn = con,
                                            statement = paste0("SELECT * FROM bullets WHERE State = '",
                                                               input$arrests_state,
                                                               "'"))),
            "crimes" = dbFetch(dbSendQuery(conn = con,
                                           statement = paste0("SELECT * FROM crimes WHERE State = '",
                                                              input$arrests_state,
                                                              "'"))),
            "arrests" = dbFetch(dbSendQuery(conn = con,
                                           statement = paste0("SELECT * FROM arrests WHERE State = '",
                                                              input$arrests_state,
                                                              "'")))
        )
        out
    })
    # tab_rates ================================================================
    output$rates_map <- renderLeaflet({
        req <- states[states$State == input$rates_state, "Abbrev"]
        res <- states_api(state = req)
        leaflet() %>%
            addProviderTiles(providers$OpenStreetMap) %>%
            addPolygons(data = res)
    })
    output$rates_text1 <- renderUI({
        text <- setDT(get_rates_data()[["bullets"]])[Type == 'crime-rates-bullets']
        HTML(
            ifelse(!identical(text[['""Title""']], character(0)),
                   paste0("<h4>", text[['""Title""']], "</h4>"), ""),
             "<br/>",
            ifelse(!identical(text[['""Description""']], character(0)),
                   paste0("<p>", text[['""Description""']], "</p>"), "")
            )
        })
    output$rates_text2 <- renderUI({
        text <- setDT(get_rates_data()[["bullets"]])[Type == 'crime-rates-bullets']
        HTML("<ul>",
             ifelse(!identical(text[['""Bullet1""']], character(0)) ,
                    paste0("<li>", text[['""Bullet1""']], "</li>"), ""),
             ifelse(!identical(text[['""Bullet1""']], character(0)) ,
                    paste0("<li>", text[['""Bullet2""']], "</li>"), ""),
             ifelse(!identical(text[['""Bullet1""']], character(0)) ,
                    paste0("<li>", text[['""Footnote1""']], "</li>"), ""),
             "</ul>")
    })
    output$rates_chart1 <- renderUI({
        res <- setDT(get_rates_data()[["rates"]])[, Type := sub("-rates|-rate", "", Type)]
        changes <- res[res[["Variable"]] == "2007-17 Percent Change", ]
        yearly  <- res[res[["Variable"]] != "2007-17 Percent Change",
                       ][, ':='("Variable" = as.Date(paste(Variable, 1, 1, sep = "-")),
                                "Value" = as.numeric(Value))]
        fluidPage(
            fluidRow(plot_ly(yearly[Type %chin% c("homicide")],
                             x = ~Variable, y = ~Value, type = 'scatter',
                             mode = 'lines+markers', hoverinfo = 'y',
                             showlegend = F) %>%
                         layout(title = paste0("Homicide (",
                                               changes[Type %chin% c("homicide"), Value],
                                               ")"),
                                xaxis = list(title = ""),
                                yaxis = list(title = ""))),
            tags$hr(),
            fluidRow(plot_ly(yearly[Type %chin% c("rape")],
                             x = ~Variable, y = ~Value, type = 'scatter',
                             mode = 'lines+markers', hoverinfo = 'y',
                             showlegend = F) %>%
                         layout(title = paste0("Rape"),
                                xaxis = list(title = ""),
                                yaxis = list(title = ""))),
            tags$hr(),
            fluidRow(plot_ly(yearly[Type %chin% c("robbery")],
                             x = ~Variable, y = ~Value, type = 'scatter',
                             mode = 'lines+markers', hoverinfo = 'y',
                             showlegend = F) %>%
                         layout(title = paste0("Robbery (",
                                               changes[Type %chin% c("robbery"), Value],
                                               ")"),
                                xaxis = list(title = ""),
                                yaxis = list(title = ""))),
            tags$hr(),
            fluidRow(plot_ly(yearly[Type %chin% c("assault")],
                             x = ~Variable, y = ~Value, type = 'scatter',
                             mode = 'lines+markers', hoverinfo = 'y',
                             showlegend = F) %>%
                         layout(title = paste0("Aggravated Assault (",
                                               changes[Type %chin% c("assault"), Value],
                                               ")"),
                                xaxis = list(title = ""),
                                yaxis = list(title = ""))),
            fluidRow(
                tags$small(
                    tags$p(id = "tinytext",
                            "Source: U.S. Department of Justice Federal Bureau of Investigation. Crime in the United States. Federal Bureau of Investigation, 2007–2017.")))
        )
    })
    output$rates_chart2 <- renderUI({
        res <- setDT(get_rates_data()[["pop_area"]])[,
                                                     Value := as.numeric(sub("%", "", delta))]
        fluidPage(
            fluidRow(
                fluidRow(
                    column(width = 8,
                           tags$h4("Metropolitan Area"),
                           tags$small("population of 50,000+")),
                    column(width = 4,
                           tags$h3(unique(
                               res[`Pop Area` %chin% c("Metropolitan Statistical Area"), delta])))
                ),
                plot_ly(res[`Pop Area` %chin% c("Metropolitan Statistical Area")],
                        y = ~Year, x = ~CrimeRate, type = 'bar', hoverinfo = 'x',
                        showlegend = F) %>%
                    layout(xaxis = list(title = ""),
                           yaxis = list(title = ""))
            ),
            fluidRow(
                fluidRow(
                    column(width = 8,
                           tags$h4("Micropolitan Area"),
                           tags$small("population of 50,000+")),
                    column(width = 4,
                           tags$h3(unique(
                               res[`Pop Area` %chin% c("Micropolitan Statistical Area"), delta])))
                ),
                plot_ly(res[`Pop Area` %chin% c("Micropolitan Statistical Area")],
                        y = ~Year, x = ~CrimeRate, type = 'bar', hoverinfo = 'x',
                        showlegend = F) %>%
                    layout(xaxis = list(title = ""),
                           yaxis = list(title = ""))
            ),
            fluidRow(
                fluidRow(
                    column(width = 8,
                           tags$h4("Non-Metropolitan Area"),
                           tags$small("population of 50,000+")),
                    column(width = 4,
                           tags$h3(unique(
                               res[`Pop Area` %chin% c("Non-Metropolitan Areas"), delta])))
                ),
                plot_ly(res[`Pop Area` %chin% c("Non-Metropolitan Areas")],
                        y = ~Year, x = ~CrimeRate, type = 'bar', hoverinfo = 'x',
                        showlegend = F) %>%
                    layout(xaxis = list(title = ""),
                           yaxis = list(title = ""))
            )
        )
    })
    # tab_arrests ==============================================================
    output$arrests_map <- renderLeaflet({
        req <- states[states$State == input$arrests_state, "Abbrev"]
        res <- states_api(state = req)
        leaflet() %>%
            addProviderTiles(providers$OpenStreetMap) %>%
            addPolygons(data = res)
    })
    output$arrests_text1 <- renderUI({
        text <- setDT(get_arrests_data()[["bullets"]])[Type == 'arrests-bullets']
        HTML(sub("\"|\"\"|\"\"$", "", text[['""Description""']]))
    })
    output$arrests_box1 <- renderUI({
        text <- setDT(get_arrests_data()[["bullets"]])[Type == 'arrests-bullets'][, '""Title""' := sub("\"|\"\"|\"\"$", "", `""Title""`)]
        crimes  <- setDT(get_arrests_data()[["crimes"]])[Type == "reported-crime" & !Variable %like% "Percent Change"
                                                         ][, ':='("Variable" = as.Date(paste(Variable, 1, 1, sep = "-")),
                                                                  "Value" = as.numeric(Value))]
        arrests <- setDT(get_arrests_data()[["crimes"]])[Type == "arrests-crime" & !Variable %like% "Percent Change"
                                                         ][, ':='("Variable" = as.Date(paste(Variable, 1, 1, sep = "-")),
                                                                  "Value" = as.numeric(Value))]
        non_index <- setDT(get_arrests_data()[["arrests"]])[Type == "non-index-arrest" & !Variable %like% "Percent Change"
                                                            ][, ':='("Variable" = as.Date(paste(Variable, 1, 1, sep = "-")),
                                                                     "Value" = as.numeric(Value))]
        drug <- setDT(get_arrests_data()[["arrests"]])[Type == "drug-arrest" & !Variable %like% "Percent Change"
                                                       ][, ':='("Variable" = as.Date(paste(Variable, 1, 1, sep = "-")),
                                                                "Value" = as.numeric(Value))]
        group_crimes  <- setDT(get_arrests_data()[["crimes"]])[Type %chin% c("homicide-crime", "rape-crime", "robbery-crime", "assault-crime") & !Variable %like% "Percent Change"
                                                               ][, ':='("Variable" = as.Date(paste(Variable, 1, 1, sep = "-")),
                                                                        "Value" = as.numeric(Value))]
        group_arrests <- setDT(get_arrests_data()[["arrests"]])[Type %chin% c("homicide-arrests", "rape-arrests", "robbery-arrests", "assault-arrests") & !Variable %like% "Percent Change"
                                                                ][, ':='("Variable" = as.Date(paste(Variable, 1, 1, sep = "-")),
                                                                         "Value" = as.numeric(Value))]
        fluidPage(
            fluidRow(
                tags$h3(text[['""Title""']]),
                tags$h4(paste("Overall Violent Crime and Arrests in",
                             input$arrests_state,
                             "(Volume), 2007–2017")),
                plot_ly(data = arrests, x = ~Variable, y = ~Value, name = 'Arrests',
                        mode = 'lines+markers', type = 'scatter',
                        hoverinfo = 'y', showlegend = TRUE) %>%
                    add_trace(data = crimes, y = ~Value, name = 'Crimes',
                              mode = 'lines+markers', hoverinfo = 'y',
                              showlegend = TRUE) %>%
                    layout(xaxis = list(title = ""),
                           yaxis = list(title = ""))
            ),
            fluidRow(
                tags$h4(paste("Non-Index Crime Arrests in",
                             input$arrests_state,
                             "(Volume), 2007–2017")),
                plot_ly(data = non_index, x = ~Variable, y = ~Value,
                        type = 'scatter', mode = 'lines', fill = 'tozeroy',
                        hoverinfo = 'y', showlegend = TRUE,
                        name = "Other Non-Index Arrests") %>%
                    add_trace(data = drug, x = ~Variable, y = ~Value,
                              type = 'scatter', mode = 'lines', fill = 'tozeroy',
                              hoverinfo = 'y', showlegend = TRUE,
                              name = "Drug Arrests") %>%
                    layout(xaxis = list(title = ""),
                           yaxis = list(title = ""))
            ),
            fluidRow(
                column(width = 6,
                       column(width = 12,
                              tags$h4("Homicide"),
                              plot_ly(data = group_crimes[Type == "homicide-crime"],
                                      x = ~Variable, y = ~Value,
                                      type = 'scatter', mode = 'lines',
                                      hoverinfo = 'y', showlegend = TRUE,
                                      name = "Crimes") %>%
                                  add_trace(data = group_arrests[Type == "homicide-arrests"],
                                            x = ~Variable, y = ~Value,
                                            type = 'scatter', mode = 'lines',
                                            hoverinfo = 'y', showlegend = TRUE,
                                            name = "Arrests") %>%
                                  layout(xaxis = list(title = ""),
                                         yaxis = list(title = ""))),
                       column(width = 12,
                              tags$h4("Rape"),
                              plot_ly(data = group_crimes[Type == "robbery-crime"],
                                      x = ~Variable, y = ~Value,
                                      type = 'scatter', mode = 'lines',
                                      hoverinfo = 'y', showlegend = TRUE,
                                      name = "Crimes") %>%
                                  add_trace(data = group_arrests[Type == "robbery-arrests"],
                                            x = ~Variable, y = ~Value,
                                            type = 'scatter', mode = 'lines',
                                            hoverinfo = 'y', showlegend = TRUE,
                                            name = "Arrests") %>%
                                  layout(xaxis = list(title = ""),
                                         yaxis = list(title = "")))
                       ),
                column(width = 6,
                       column(width = 12,
                              tags$h4("Robbery"),
                              plot_ly(data = group_crimes[Type == "rape-crime"],
                                      x = ~Variable, y = ~Value,
                                      type = 'scatter', mode = 'lines',
                                      hoverinfo = 'y', showlegend = TRUE,
                                      name = "Crimes") %>%
                                  add_trace(data = group_arrests[Type == "rape-arrests"],
                                            x = ~Variable, y = ~Value,
                                            type = 'scatter', mode = 'lines',
                                            hoverinfo = 'y', showlegend = TRUE,
                                            name = "Arrests") %>%
                                  layout(xaxis = list(title = ""),
                                         yaxis = list(title = ""))),
                       column(width = 12,
                              tags$h4("Aggravated Assault"),
                              plot_ly(data = group_crimes[Type == "assault-crime"],
                                      x = ~Variable, y = ~Value,
                                      type = 'scatter', mode = 'lines',
                                      hoverinfo = 'y', showlegend = TRUE,
                                      name = "Crimes") %>%
                                  add_trace(data = group_arrests[Type == "assault-arrests"],
                                            x = ~Variable, y = ~Value,
                                            type = 'scatter', mode = 'lines',
                                            hoverinfo = 'y', showlegend = TRUE,
                                            name = "Arrests") %>%
                                  layout(xaxis = list(title = ""),
                                         yaxis = list(title = "")))
                       )
            ),
            fluidRow(
                tags$small(
                    tags$p(id = "tinytext",
                           "Source: U.S. Department of Justice Federal Bureau of Investigation. Crime in the United States. Federal Bureau of Investigation, 2007–2017.")))
        )
    })
})
