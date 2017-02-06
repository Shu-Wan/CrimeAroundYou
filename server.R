library(dplyr)
library(data.table)
library(leaflet)
library(shiny)
library(shinydashboard)
library(dygraphs)
library(xts)

# read data
data <- tbl_df(fread('Washington_DC.csv',header = T))
# modify data
data <- data %>%
  mutate(incident_date = as.Date(data$incident_datetime, format = "%m/%d/%Y")) %>%
  mutate(incidentType = as.factor(parent_incident_type)) %>%
  mutate(content = paste('<b>',incidentType,'</b>')) %>%
  mutate(content = paste(sep = '<br/>', content,incident_datetime,address_1)) %>%
  mutate(year_month = as.yearmon(incident_date))

# Customize icons
crimeIcons <- iconList(
  Robbery = makeIcon(iconUrl = './icon/Robbery.png',iconWidth = 35,iconHeight = 35),
  `Theft of Vehicle` = makeIcon(iconUrl = './icon/Theft of Vehicle.png', iconWidth = 35, iconHeight = 35),
  `Theft from Vehicle` = makeIcon(iconUrl = './icon/Theft from Vehicle.png', iconWidth = 35, iconHeight = 35),
  `Breaking & Entering` = makeIcon(iconUrl = './icon/Breaking & Entering.png', iconWidth = 35, iconHeight = 35),
  Theft = makeIcon(iconUrl = './icon/Theft.png', iconWidth = 35, iconHeight = 35),
  `Sexual Assault` = makeIcon(iconUrl = './icon/Sexual Assault.png', iconWidth = 35, iconHeight = 35),
  `Assault with Deadly Weapon` = makeIcon(iconUrl = './icon/Assault with Deadly Weapon.png', iconWidth = 35, iconHeight = 35),
  Homicide = makeIcon(iconUrl ='./icon/Homicide.png' ,iconWidth =35 ,iconHeight = 35),
  Arson = makeIcon(iconUrl ='./icon/Arson.png' ,iconWidth = 35 ,iconHeight = 35)
)


server <- function(input, output) {
  filteredData <- reactive({
    data %>%
      filter(parent_incident_type %in% input$crimeType ) %>%
      filter(incident_date > input$dates[1] & incident_date < input$dates[2]) %>%
      filter(day_of_week %in% input$day_of_week) %>%
      filter(hour_of_day >= input$time_of_day & hour_of_day <= input$time_of_day)
  })
    
  output$crimeMap <- renderLeaflet({
   leaflet(filteredData()) %>%
      addTiles(group = 'OSM') %>%
      addProviderTiles('Esri.WorldStreetMap', group = 'Esri') %>%
      addProviderTiles('CartoDB.Positron', group = 'CartoDB') %>%
      addMarkers(
        ~longitude, ~latitude, popup = ~content, 
        icon = ~crimeIcons[incidentType],clusterOptions = markerClusterOptions()
      ) %>%
      addLayersControl(
        baseGroups = c('OSM', 'Esri', 'CartoDB'),
        options = layersControlOptions(collapsed = FALSE)
      )
  })
  
  
  output$plot1 <- renderDygraph({
    dydf <- matrix()
    for (i in 1:length(input$crimeType)){
      temp <- filteredData() %>%
        filter(incidentType %in% input$crimeType[i]) %>%
        group_by(year_month) %>%
        summarise(count = n()) %>%
        arrange(year_month)
      temp1 <- xts(temp$count, temp$year_month)
      if(dim(temp1)[[1]] == 0) {
        temp1 <- 0
      }
      dydf <- cbind(dydf, temp1)
    }
    dydf <- dydf[,-1]
    dydf[is.na(dydf)] <- 0
    colnames(dydf) <- input$crimeType
    dygraph(dydf, main = 'Incidents Trend/Month') %>%
      dyOptions(colors = RColorBrewer::brewer.pal(9, "Set1"),
                drawPoints = TRUE, pointSize = 2) %>%
      dyHighlight(highlightCircleSize = 5, 
                  highlightSeriesBackgroundAlpha = 0.2,
                  hideOnMouseOut = FALSE,
                  highlightSeriesOpts = list(strokeWidth = 3)) %>%
      dyAxis("y", label = 'Count') %>%
      dyRangeSelector(fillColor = '#651365')
  })
}
