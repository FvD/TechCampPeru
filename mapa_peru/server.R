library(shinydashboard)
library(shiny)
library(leaflet)
library(dplyr)
library(geojsonio)
library(DT)

deptos <- geojsonio::geojson_read("json/peru_departamental_simple.geojson",
                                      what = "sp")

function(input, output, session) {

  output$mapa <- renderLeaflet({

    class(deptos)

    m <- leaflet(deptos) %>%
      setView(-75, -10, 6) %>%
      addTiles()

    m %>% addPolygons()


    bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
    pal <- colorBin("YlOrRd", domain = deptos$COUNT, bins = bins)

    m %>% addPolygons(
      fillColor = ~pal(COUNT),
      weight = 1,
      opacity = 1,
      color = "white",
      dashArray = "3",
      fillOpacity = 0.7)


    labels <- sprintf(
      "<strong>%s</strong><br/>%g people / mi<sup>2</sup>",
      deptos$NOMBDEP, deptos$COUNT
    ) %>% lapply(htmltools::HTML)



    m %>% addPolygons(
      fillColor = ~pal(COUNT),
      weight = 1,
      opacity = 1,
      color = "white",
      dashArray = "3",
      fillOpacity = 0.7,
      highlight = highlightOptions(
        weight = 5,
        color = "#666",
        dashArray = "",
        fillOpacity = 0.7,
        bringToFront = TRUE),
      label = labels,
      labelOptions = labelOptions(
        style = list("font-weight" = "normal", padding = "3px 8px"),
        textsize = "15px",
        direction = "auto"))

  })


  output$cuadro <- renderDataTable({

    datos <- data.frame(
      Nombres = deptos$NOMBDEP,
      Superficie = deptos$HECTARES,
      Conteo = deptos$COUNT
    )

    return(datos)

  })

}
