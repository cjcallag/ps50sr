# dashboardHeader ==============================================================
header <- dashboardHeader(
    title      = "CSG Crime Trends",
    titleWidth = 200
)


# dashboardSidebar =============================================================
sidebar <- dashboardSidebar(
    collapsed = TRUE,
    width     = 200,
    sidebarMenu(
        id = "tabs",
        menuItem(text    = "About",
                 tabName = "background",
                 icon    = icon("info-circle")),
        menuItem(text    = "Violent Crime Rates Data",
                 tabName = "rates",
                 icon    = icon("chart-area")),
        menuItem(text    = "Violent Crime and Arrests",
                 tabName = "arrests",
                 icon    = icon("chart-bar")),
        menuItem(text    = "National v. State Crime",
                 tabName = "crime",
                 icon    = icon("compass"))
    )
)


# body =========================================================================
## Background tab --------------------------------------------------------------
tab_background <- tabItem(
    tabName = "background",
    fluidPage(
        # tags$style(type = "text/css",
        #            "#background-box {height: calc(100vh - 100px) !important;}"),
        box(id = "background-box",
            width = "100%",
            column(width = 12,
                   tags$h1("Use data to understand crime trends"),
                   tags$br(),
                   tags$p("Understanding the full extent of criminal activity in a community is challenging. To help policymakers get started, they need to consider data and trends across three measures, each with unique limitations:"),
                   tags$ol(
                       tags$li(tags$b("Crime data:"),
                               "which reflects incidents that are reported to law enforcement agencies, and represents only a portion of criminal activity."),
                       tags$li(tags$b("Arrest data:"),
                               "which law enforcement agencies record when a person is arrested, cited, or summoned for an offense and voluntarily provide to the Federal Bureau of Investigation (FBI), at times with gaps or inconsistencies in reporting."),
                       tags$li(tags$b("Victimization surveys:"),
                               "which collect data on people who have been victimized by crime and the frequency and types of certain crimes, both reported and not reported to the police. These surveys are given to only a representative sample of all households and produce estimates for the amount of certain types of crime.")
                       ),
                   tags$br(),
                   tags$style(type = "text/css",
                              "#bolded-text {color: #606060; margin: auto; width: 90%; padding: 10px;}"),
                   column(width = 6,
                          tags$hr(),
                          tags$h4(id = "bolded-text",
                                  "Crime data, arrest data, and victimization surveys are all necessary to understand criminal activity in a state."),
                          tags$hr(),
                          tags$br(),
                          tags$p("While a historical review of reported crime, arrest, and victimization trends at the national level provides a point of comparison for states, policymakers must understand how local dynamics are influencing trends in their states in order to develop effective policies that respond to these trends."),
                          tags$p("Without a clear, data-driven understanding of where crime is occurring, what types of crime are on the rise and in which jurisdictions, how the volume of arrests for those crimes has changed over time, and who is being victimized, law enforcement and other local criminal justice stakeholders cannot develop effective strategies to respond to crime in their communities. Insufficient data collection, reporting, and sharing between criminal justice agencies, along with limited analytical capacity within agencies, all hinder efforts to improve understanding of crime trends and to develop effective crime-prevention strategies.")
                          ),
                   column(width = 6,
                          tags$div(
                              style = "text-align: center;",
                              tags$img(src = "Graphic-1.1.png", width = "90%"))
                          )
                   )
            )
    )
)
## Rates tab -------------------------------------------------------------------
tab_rates <- tabItem(
    tabName = "rates",
    fluidRow(
        column(width = 12,
               tags$h1("Violent crime rates vary greatly across states.")),
        column(width = 6,
               box(width  = 12,
                   column(
                       width = 12,
                       tags$p("Select a state from the drop-down menu to see how violent crime rates have changed between 2007 and 2017."),
                       selectInput(inputId  = "rates_state",
                                   label    = "Get data for:",
                                   selected = "California",
                                   choices  = states[["State"]]),
                       uiOutput("rates_text1")
                   )),
               box(width = 12,
                   column(
                       width = 12,
                       uiOutput("rates_chart1")
                   ))
               ),
        column(width = 6,
               box(width = 12,
                   leafletOutput("rates_map")),
               box(width = 12,
                   uiOutput("rates_text2")),
               box(width = 12,
                   uiOutput("rates_chart2")))
    )
)
## Arrest tab ------------------------------------------------------------------
tab_arrests <- tabItem(
    tabName = "arrests",
    fluidRow(
        column(width = 12,
               tags$h1("Violent crime and arrest rates vary greatly by state.")),
        column(width = 6,
               box(width = 12,
                   height = "420px",
                   tags$p("Select a state from the drop-down menu to see how violent crime rates and arrest rates have changed between 2007 and 2017."),
                   selectInput(inputId  = "arrests_state",
                               label    = "Get data for:",
                               selected = "California",
                               choices  = states[["State"]]),
                   uiOutput("arrests_text1")
                   )),
        column(width = 6,
               box(width = 12,
                   height = "420px",
                   leafletOutput("arrests_map")))
    ),
    fluidRow(
        column(width = 12,
               box(width = 12,
                   uiOutput("arrests_box1")
                   ))
    )
)
## Crime tab -------------------------------------------------------------------
tab_crime <- tabItem(
    tabName = "crime",
    fluidPage(
        tags$style(type = "text/css",
                   "#video-box {height: calc(100vh - 100px) !important;}"),
        tags$style(type = "text/css",
                   "#video {height: calc(100vh - 300px) !important;}"),
        box(id = "video-box",
            width = "100%",
            fluidRow(
                column(width = 12,
                       tags$h1("States need to understand how their crime trends differ from national trends"),
                       tags$br(),
                       tags$p("View the video to learn more about understanding state crime trends."),
                       tags$iframe(id = "video",
                                   width = "100%",
                                   src = "https://www.youtube.com/embed/abevC4htKgY?rel=0&start=946&end=994&list=PLvoZLdtBgik0IqJ8zBHj7zgvjy3wFJ2GR",
                                   frameborder = "0",
                                   allow = "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture",
                                   allowfullscreen = TRUE)
                       )
            )))
)

## Build body ------------------------------------------------------------------
body <- dashboardBody(
    tabItems(
        tab_background,
        tab_rates,
        tab_arrests,
        tab_crime
    )
)


# dashboardPage ================================================================
dashboardPage(
    skin = "black",
    header,
    sidebar,
    body
)
