library(leaflet)
library(shiny)
library(shinydashboard)
library(dygraphs)

type <- c("Robbery" = "Robbery", "Theft of Vehicle"= "Theft of Vehicle",
  "Theft from Vehicle" =  "Theft from Vehicle", "Breaking & Entering" = "Breaking & Entering",
  "Theft" = "Theft", "Assault with Deadly Weapon" = "Assault with Deadly Weapon",
  "Sexual Assault" =  "Sexual Assault", "Homicide" = "Homicide","Arson" = "Arson")
header <- dashboardHeader(title = p("Crime Around You"),
                          titleWidth = 400)


body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")),
            fluidRow(
              column(width =4,
                     box(width = NULL, title =tagList(shiny::icon("filter",class = 'fa-lg'), "Filter Data") ,
                         solidHeader = T, collapsible = T, status = 'primary',
                         selectizeInput('crimeType','Crime Type', choices = type, width = 380,
                                        selected = c('Robbery', 'Theft of Vehicle',"Theft from Vehicle",
                                                     "Breaking & Entering","Theft","Assault with Deadly Weapon",
                                                     "Sexual Assault","Homicide","Arson"),multiple = T),
                         dateRangeInput('dates', label = "Date Range",width = 380,
                                        start = '2014-01-01', end = '2015-01-01',
                                        min = "2013-01-01", max = "2016-08-01"
                         ),
                         selectizeInput('day_of_week','Days of Week', width = 380,
                                        choices = c('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'),
                                        selected = c('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'),
                                        multiple = T),
                         sliderInput('time_of_day','Time of Day', min = 0, max = 23,width = 380,
                                     value = c(0,23), step = 1),
                         submitButton(text = "Submit",icon =icon('filter'))
                         ),
                     box(width = NULL,title = tagList(shiny::icon("info-circle",class = 'fa-lg'), "About Crime Around You"), solidHeader = T, collapsible = T, status = 'info',
                         strong("Crime Around You"),"is an interactive map built on shiny which allows you to cutomize
                         time range and incident type to filter out crime reports of a certain location you want. The",em("dygraph"),
                         "below the map allows you to explore incidents trend over period of time. The data is from", a('here.', href = 'https://moto.data.socrata.com/dataset/Washington-DC/2vfk-6rp4', target = "_blank")
                         ),
                     box(width = NULL,
                         icon('link', class = 'fa-lg'), a('Personal Website', href = 'https://Shu-Wan.github.io', target = '_blank'),
                         br(),
                         br(),
                         icon('github', class = 'fa-lg'), a('Source Code', href = 'https://github.com/Shu-Wan/crimearoundyou', target = "_blank"),
                         br(),
                         br(),
                         icon('github-alt', class = 'fa-lg'), a('My Github Page', href = 'https://github.com/Shu-Wan/', target = "_blank"),
                         br(),
                         br(),
                         icon('linkedin-square', class = 'fa-lg'), a('My Linkedin Page', href = 'https://www.linkedin.com/in/shu-wan-88153493', target = "_blank"))
                     ),
              column(width =8,
                     box(width = NULL, solidHeader = TRUE,
                         leafletOutput('crimeMap',height = 500)),
                     box(width = NULL, 
                         dygraphOutput('plot1')
              )
            )
            )
            )

                      
ui <- dashboardPage(skin = 'purple',
                    header,
                    dashboardSidebar(disable = T),
                    body
                    )
