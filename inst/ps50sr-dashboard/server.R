shinyServer(function(input, output) {
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
        HTML("<h4>", text[['""Title""']], "</h4>",
             "<br/>",
             text[['""Description""']])
        })
    output$rates_text2 <- renderUI({
        text <- setDT(get_rates_data()[["bullets"]])[Type == 'crime-rates-bullets']
        HTML("<ul><li>", text[['""Bullet1""']], "</li>",
             "<li>", text[['""Bullet2""']], "</li>",
             "<li>",text[['""Footnote1""']], "</li></ul>")
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
        HTML(sub("\"|\"\"", "", text[['""Description""']]))
    })
})
