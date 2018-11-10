library(shinydashboard)
library(leaflet)
library(dplyr)
library(geojsonio)
library(DT)
library(stringr)
library(feather)
deptos <- geojsonio::geojson_read("json/peru_departamental_simple.geojson",
                                      what = "sp")
nombres_deptos <- data.frame(
  departamento = make.names(tolower(deptos$NOMBDEP))
)

cuadro <- read_feather("cuadro.feather")
cuadro$departamento <- make.names(tolower(cuadro$departamento))

nombres_deptos %>%
  anti_join(cuadro, by = c("departamento" = "departamento"))

cuadro <- cuadro %>%
  mutate(departamento = str_replace_all(departamento,
                                         pattern = 'í',
                                         replacement = 'i')) %>%
  mutate(departamento = str_replace_all(departamento,
                                         pattern = 'á',
                                         replacement = 'a')) %>%
  mutate(departamento = str_replace(departamento,
                                    replacement = 'callao',
                                    pattern = 'provincia.constitucional.del.callao')) %>%
  filter(departamento != 'provincia.de.lima') %>%
  filter(departamento != 'región.lima') %>%
  arrange(departamento)


deptos$buena <- cuadro$buena
deptos$mala <- cuadro$mala
deptos$respuesta <- cuadro$respuesta


function(input, output, session) {

  output$mapa <- renderLeaflet({

    class(deptos)

    m <- leaflet(deptos) %>%
      setView(-75, -10, 6) %>%
      addTiles()

    m %>% addPolygons()


    bins <- c(0, 10, 20, 30, 40, 50, 60, 70, 80, Inf)
    pal <- colorBin("RdYlGn", domain = deptos$buena, bins = bins)

    m %>% addPolygons(
      fillColor = ~pal(buena),
      weight = 1,
      opacity = 1,
      color = "white",
      dashArray = "3",
      fillOpacity = 0.7)


    labels <- sprintf(
      "<strong>%s</strong><br/>%g buena<br/>%g mala<br/>%g no sabe",
      deptos$NOMBDEP, deptos$buena, deptos$mala, deptos$respuesta
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
      Buena = deptos$buena,
      Mala = deptos$mala,
      `No sabe` = deptos$respuesta,
      Superficie = deptos$HECTARES,
      Conteo = deptos$COUNT
    )

    return(datos)

  })

}
