modal_about <- function() {
  showModal(
    modalDialog(
      box(
        width = 12,
        h4("Background"),
        p("This app was designed as a demostration. The original website, data, and content used in this application can be attributed to the Council of State Government Justice Center's 50-State Report on Public Safety, found",
          tags$a(id = "link", href = "https://50statespublicsafety.us/part-1/strategy-1/", "here.")),
        tags$hr(),
        h4("Disclaimer"),
        p("The data included in this app are all made freely available 'AS IS.' The author makes no warranties, express or implied, including without limitation, any implied warranties of merchantability and/or fitness for a particular purpose, regarding the accuracy, completeness, value, quality, validity, merchantability, suitability, and/or condition, of the data. Users of the data are hereby notified that current public primary information sources should be consulted for verification of the data and information contained herein. Since the data are dynamic, it will by its nature be inconsistent with the official assessment roll file, surveys, maps and/or other documents produced by relevant data providers. Any use of the data on this app is done exclusively at the risk of the party making such use."),
        tags$hr(),
        p("All code used for this app is available on", tags$a(id = "link", href = "https://github.com/cjcallag/ps50sr", "Github."), "For questions please email Chris Callaghan at cjcallaghan88@gmail.com.")
      )
    )
  )
}
